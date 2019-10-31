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
        max_views CONSTANT REAL := 1e6;
        min_views CONSTANT REAL := 50.;
        views_count real;
    BEGIN
        SELECT INTO views_count
            COALESCE(MAX(wm_stats.views)::real, 0)
            FROM wm_stats
            JOIN wd_sitelinks ON (wm_stats.title = wd_sitelinks.title
                              AND wm_stats.lang = wd_sitelinks.lang)
            WHERE wd_sitelinks.id = tags->'wikidata';
        RETURN CASE
            WHEN views_count > min_views THEN
                0.5 * (1 + LOG(LEAST(max_views, views_count)) / LOG(max_views))
            WHEN name <> '' THEN
                0.5 * (1 - poi_class_rank(poi_class(subclass, mapping_key))::real / 1000)
            ELSE
                0.0
        END;
    END
$$ LANGUAGE plpgsql IMMUTABLE;
