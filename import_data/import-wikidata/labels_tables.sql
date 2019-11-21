-- This table is used by openmaptiles to widen the available translations. It
-- uses the same schema as in https://github.com/openmaptiles/import-wikidata.
CREATE TABLE IF NOT EXISTS wd_names
(
    id      VARCHAR(64)     UNIQUE,
    page    VARCHAR(200)    UNIQUE,
    labels  hstore
);
