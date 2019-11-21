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
