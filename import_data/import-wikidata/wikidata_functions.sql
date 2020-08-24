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
        min_views CONSTANT REAL := {{ min_views }};

        -- Upper limit to the number of views of a Wikipedia page. Pages with a
        -- greater number of views will have a weight of 1.
        max_views CONSTANT REAL := {{ max_views }};

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
