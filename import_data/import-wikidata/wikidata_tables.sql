-- View counts for Wikipedia pages.
CREATE TABLE IF NOT EXISTS wm_stats
(
    lang    VARCHAR(8)      NOT NULL,
    title   VARCHAR(1024)   NOT NULL,
    views   INTEGER         NOT NULL,
    UNIQUE (lang, title)
);

-- Sitelinks for wikidata items, currently only Wikipedia items may be
-- imported, in that case `site` is always set to "wiki".
CREATE TABLE IF NOT EXISTS wd_sitelinks
(
    id      VARCHAR(64)     NOT NULL,
    site    VARCHAR(64)     NOT NULL,
    lang    VARCHAR(8)      NOT NULL,
    title   VARCHAR(1024)   NOT NULL,
    UNIQUE (id, site, lang)
);

-- This table is used by openmaptiles to widen the available translations. It
-- uses the same schema as in https://github.com/openmaptiles/import-wikidata.
CREATE TABLE IF NOT EXISTS wd_names
(
    id      VARCHAR(64)     UNIQUE,
    page    VARCHAR(200)    UNIQUE,
    labels  hstore
);

-- Compute the weight of an OSM POI, primarily this function relies on the
-- count of page views for the Wikipedia pages of this POI.
CREATE OR REPLACE FUNCTION poi_weight(
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
            WHEN name = '' THEN
                0.0
            ELSE
                0.5 * (
                    1 - poi_class_rank(poi_class(subclass, mapping_key))::real / 2000
                )
        END;
    END
$$ LANGUAGE plpgsql IMMUTABLE;
