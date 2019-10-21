CREATE TABLE IF NOT EXISTS test_wikimedia_stats
(
    site      VARCHAR(64)     NOT NULL,
    title     VARCHAR(1024)   NOT NULL,
    views     INTEGER         NOT NULL,
    UNIQUE (site, title)
);

CREATE TABLE IF NOT EXISTS test_wikidata_labels
(
    id      VARCHAR(64)     NOT NULL,
    lang    VARCHAR(8)      NOT NULL,
    value   VARCHAR(1024)   NOT NULL,
    UNIQUE (id, lang)
);

CREATE TABLE IF NOT EXISTS wd_names
(
    id      VARCHAR(64)     UNIQUE,
    page    VARCHAR(200)    UNIQUE,
    labels  hstore
);

CREATE TABLE IF NOT EXISTS test_wikidata_sitelinks
(
    id      VARCHAR(64)     NOT NULL,
    site    VARCHAR(64)     NOT NULL,
    lang    VARCHAR(8)      NOT NULL,
    title   VARCHAR(1024)   NOT NULL,
    UNIQUE (id, site, lang)
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
            SELECT MAX(stats.count_views)
            FROM wikimedia_stats AS stats
            JOIN wikidata_sitelinks AS wikidata
            ON wikidata.title = stats.page_title
                AND wikidata.lang = stats.domain_code
            WHERE wikidata.id = tags->'wikidata'
        ),
        (
            CASE
                WHEN tags ? 'wikidata' THEN -500
                WHEN name = '' THEN -1000000
                ELSE -poi_class_rank(poi_class(subclass, mapping_key))
            END
            + (
                SELECT COUNT(*)::integer
                FROM each(tags)
                WHERE key LIKE 'name:%'
            )
        )
    )
$$ LANGUAGE SQL IMMUTABLE;

