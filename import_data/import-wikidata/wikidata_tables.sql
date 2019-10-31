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
