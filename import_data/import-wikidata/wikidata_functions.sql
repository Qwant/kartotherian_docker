-- Compute a percentile on the set of page view counts for POIs for which a
-- Wikipedia page was found.
CREATE OR REPLACE FUNCTION poi_pageviews_percentile(fraction REAL)
RETURNS INTEGER AS
$$
    SELECT PERCENTILE_DISC(fraction) WITHIN GROUP (ORDER BY all_poi.max_views)
    FROM (
        SELECT MAX(stats.views) AS max_views
        FROM (
                SELECT osm_id, name, tags FROM osm_poi_polygon
                    UNION ALL
                SELECT osm_id, name, tags FROM osm_poi_point
            ) AS poi
        JOIN wd_sitelinks AS site
            ON site.id = poi.tags->'wikidata'
        JOIN wm_stats AS stats
            ON site.lang = stats.lang AND site.title = stats.title
        GROUP BY poi.osm_id
    ) AS all_poi
$$ LANGUAGE sql IMMUTABLE;

-- Override default `poi_display_weight` function from
-- https://github.com/QwantResearch/openmaptiles/.
--
-- Primarily, this function relies on the count of page views for the Wikipedia
-- pages of a POI, if no Wikipedia page is found, this will fallback on the
-- default implementation.
CREATE OR REPLACE FUNCTION poi_display_weight(
    name varchar,
    subclass varchar,
    mapping_key varchar,
    tags hstore
)
RETURNS REAL AS $$
    DECLARE
        -- Maximum rank for the class of a POI as defined in
        -- https://github.com/QwantResearch/openmaptiles/blob/master/layers/poi/class.sql
        max_rank  CONSTANT REAL := 1000.;

        -- Lower limit to the number of view of a Wikipedia page to consider it
        -- relevant. If a page generates less views than this limit, the output
        -- value will be computed as if this page doesn't exist.
        min_views CONSTANT REAL := poi_pageviews_percentile(0.1);

        -- Upper limit to the number of views of a Wikipedia page. Pages with a
        -- greater number of views will have a weight of 1.
        max_views CONSTANT REAL := poi_pageviews_percentile(0.999);

        views_count REAL;
    BEGIN
        SELECT INTO views_count
            CASE
                WHEN tags ? 'wikidata' THEN (
                    SELECT COALESCE(MAX(wm_stats.views)::real, 0)
                    FROM wm_stats
                    JOIN wd_sitelinks ON (wm_stats.title = wd_sitelinks.title
                                      AND wm_stats.lang = wd_sitelinks.lang)
                    WHERE wd_sitelinks.id = tags->'wikidata'
                ) ELSE
                    0
            END;
        RETURN CASE
            WHEN views_count > min_views AND max_views - min_views > 1 THEN
                0.5 + 0.5 * LOG(LEAST(max_views, views_count) - min_views)
                             / LOG(max_views - min_views)
            WHEN name <> '' THEN
                0.5 * (
                    1 - poi_class_rank(poi_class(subclass, mapping_key))::real / max_rank
                )
            ELSE
                0.0
        END;
    END
$$ LANGUAGE plpgsql IMMUTABLE;
