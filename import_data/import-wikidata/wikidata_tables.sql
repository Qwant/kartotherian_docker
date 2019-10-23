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
RETURNS integer AS $$
    SELECT COALESCE(
        (
            SELECT MAX(wm_stats.views)
            FROM wm_stats
            JOIN wd_sitelinks ON (wm_stats.title = wd_sitelinks.title
                              AND wm_stats.lang = wd_sitelinks.lang)
            WHERE wd_sitelinks.id = tags->'wikidata'
        ),
        (
            CASE
                WHEN tags ? 'wikidata' THEN -500
                WHEN name = '' THEN -1000000
                ELSE -10 * poi_class_rank(poi_class(subclass, mapping_key))
            END
            + (
                SELECT COUNT(*)::integer
                FROM each(tags)
                WHERE key LIKE 'name:%'
            )
        )
    )
$$ LANGUAGE SQL IMMUTABLE;
