CREATE OR REPLACE FUNCTION slice_language_tags(tags hstore)
RETURNS hstore AS $$
    SELECT slice(tags, ARRAY['name:ar', 'name:az', 'name:be', 'name:bg', 'name:br', 'name:bs', 'name:ca', 'name:cs', 'name:cy', 'name:da', 'name:de', 'name:el', 'name:en', 'name:es', 'name:et', 'name:fi', 'name:fr', 'name:fy', 'name:ga', 'name:gd', 'name:he', 'name:hr', 'name:hu', 'name:hy', 'name:is', 'name:it', 'name:ja', 'name:ja_kana', 'name:ja_rm', 'name:ka', 'name:kk', 'name:kn', 'name:ko', 'name:ko_rm', 'name:la', 'name:lb', 'name:lt', 'name:lv', 'name:mk', 'name:mt', 'name:nl', 'name:no', 'name:pl', 'name:pt', 'name:rm', 'name:ro', 'name:ru', 'name:sk', 'name:sl', 'name:sq', 'name:sr', 'name:sr-Latn', 'name:sv', 'name:th', 'name:tr', 'name:uk', 'name:zh', 'int_name', 'name'])
$$ LANGUAGE SQL IMMUTABLE;
DO $$ BEGIN RAISE NOTICE 'Layer water'; END$$;CREATE OR REPLACE FUNCTION water_class(waterway TEXT) RETURNS TEXT AS $$
    SELECT CASE WHEN waterway='' THEN 'lake' ELSE 'river' END;
$$ LANGUAGE SQL IMMUTABLE;



CREATE OR REPLACE VIEW water_z0 AS (
    -- etldoc:  ne_110m_ocean ->  water_z0
    SELECT geometry, 'ocean'::text AS class FROM ne_110m_ocean
    UNION ALL
    -- etldoc:  ne_110m_lakes ->  water_z0
    SELECT geometry, 'lake'::text AS class FROM ne_110m_lakes
);

CREATE OR REPLACE VIEW water_z1 AS (
    -- etldoc:  ne_110m_ocean ->  water_z1
    SELECT geometry, 'ocean'::text AS class FROM ne_110m_ocean
    UNION ALL
    -- etldoc:  ne_110m_lakes ->  water_z1
    SELECT geometry, 'lake'::text AS class FROM ne_110m_lakes
);

CREATE OR REPLACE VIEW water_z2 AS (
    -- etldoc:  ne_50m_ocean ->  water_z2
    SELECT geometry, 'ocean'::text AS class FROM ne_50m_ocean
    UNION ALL
    -- etldoc:  ne_50m_lakes ->  water_z2
    SELECT geometry, 'lake'::text AS class FROM ne_50m_lakes
);

CREATE OR REPLACE VIEW water_z4 AS (
    -- etldoc:  ne_50m_ocean ->  water_z4
    SELECT geometry, 'ocean'::text AS class FROM ne_50m_ocean
    UNION ALL
    -- etldoc:  ne_50m_lakes ->  water_z4
    SELECT geometry, 'lake'::text AS class FROM ne_50m_lakes
);

CREATE OR REPLACE VIEW water_z5 AS (
    -- etldoc:  ne_10m_ocean ->  water_z5
    SELECT geometry, 'ocean'::text AS class FROM ne_10m_ocean
    UNION ALL
    -- etldoc:  ne_10m_lakes ->  water_z5
    SELECT geometry, 'lake'::text AS class FROM ne_10m_lakes
);

CREATE OR REPLACE VIEW water_z6 AS (
    -- etldoc:  ne_10m_ocean ->  water_z6
    SELECT geometry, 'ocean'::text AS class FROM ne_10m_ocean
    UNION ALL
   -- etldoc:  osm_water_polygon_gen6 ->  water_z6
    SELECT geometry, 'lake' AS class FROM osm_water_polygon_gen6
);

CREATE OR REPLACE VIEW water_z7 AS (
    -- etldoc:  ne_10m_ocean ->  water_z7
    SELECT geometry, 'ocean'::text AS class FROM ne_10m_ocean
    UNION ALL
    -- etldoc:  osm_water_polygon_gen5 ->  water_z7
    SELECT geometry, 'lake' AS class FROM osm_water_polygon_gen5
);

CREATE OR REPLACE VIEW water_z8 AS (
    -- etldoc:  osm_ocean_polygon_gen4 ->  water_z8
    SELECT geometry, 'ocean'::text AS class FROM osm_ocean_polygon_gen4
    UNION ALL
    -- etldoc:  osm_water_polygon_gen4 ->  water_z8
    SELECT geometry, 'lake' AS class FROM osm_water_polygon_gen4
);

CREATE OR REPLACE VIEW water_z9 AS (
    -- etldoc:  osm_ocean_polygon_gen3 ->  water_z9
    SELECT geometry, 'ocean'::text AS class FROM osm_ocean_polygon_gen3
    UNION ALL
    -- etldoc:  osm_water_polygon_gen3 ->  water_z9
    SELECT geometry, 'lake'::text AS class FROM osm_water_polygon_gen3
);

CREATE OR REPLACE VIEW water_z10 AS (
    -- etldoc:  osm_ocean_polygon_gen2 ->  water_z10
    SELECT geometry, 'ocean'::text AS class FROM osm_ocean_polygon_gen2
    UNION ALL
    -- etldoc:  osm_water_polygon_gen2 ->  water_z10
    SELECT geometry, 'lake'::text AS class FROM osm_water_polygon_gen2
);

CREATE OR REPLACE VIEW water_z11 AS (
    -- etldoc:  osm_ocean_polygon_gen1 ->  water_z11
    SELECT geometry, 'ocean'::text AS class FROM osm_ocean_polygon_gen1
    UNION ALL
    -- etldoc:  osm_water_polygon_gen1 ->  water_z11
    SELECT geometry, water_class(waterway) AS class FROM osm_water_polygon_gen1
);

CREATE OR REPLACE VIEW water_z12 AS (
    -- etldoc:  osm_ocean_polygon_gen1 ->  water_z12
    SELECT geometry, 'ocean'::text AS class FROM osm_ocean_polygon
    UNION ALL
    -- etldoc:  osm_water_polygon ->  water_z12
    SELECT geometry, water_class(waterway) AS class FROM osm_water_polygon
);

CREATE OR REPLACE VIEW water_z13 AS (
    -- etldoc:  osm_ocean_polygon ->  water_z13
    SELECT geometry, 'ocean'::text AS class FROM osm_ocean_polygon
    UNION ALL
    -- etldoc:  osm_water_polygon ->  water_z13
    SELECT geometry, water_class(waterway) AS class FROM osm_water_polygon
);

CREATE OR REPLACE VIEW water_z14 AS (
    -- etldoc:  osm_ocean_polygon ->  water_z14
    SELECT geometry, 'ocean'::text AS class FROM osm_ocean_polygon
    UNION ALL
    -- etldoc:  osm_water_polygon ->  water_z14
    SELECT geometry, water_class(waterway) AS class FROM osm_water_polygon
);

-- etldoc: layer_water [shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_water |<z0> z0|<z1>z1|<z2>z2|<z3>z3 |<z4> z4|<z5>z5|<z6>z6|<z7>z7| <z8> z8 |<z9> z9 |<z10> z10 |<z11> z11 |<z12> z12|<z13> z13|<z14_> z14+" ] ;

CREATE OR REPLACE FUNCTION layer_water (bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, class text) AS $$
    SELECT geometry, class::text FROM (
        -- etldoc: water_z0 ->  layer_water:z0
        SELECT * FROM water_z0 WHERE zoom_level = 0
        UNION ALL
        -- etldoc: water_z1 ->  layer_water:z1
        SELECT * FROM water_z1 WHERE zoom_level = 1
        UNION ALL
        -- etldoc: water_z2 ->  layer_water:z2
        -- etldoc: water_z2 ->  layer_water:z3
        SELECT * FROM water_z2 WHERE zoom_level BETWEEN 2 AND 3
        UNION ALL
        -- etldoc: water_z4 ->  layer_water:z4
        SELECT * FROM water_z4 WHERE zoom_level = 4
        UNION ALL
        -- etldoc: water_z5 ->  layer_water:z5
        SELECT * FROM water_z5 WHERE zoom_level = 5
        UNION ALL
        -- etldoc: water_z6 ->  layer_water:z6
        SELECT * FROM water_z6 WHERE zoom_level = 6
        UNION ALL
        -- etldoc: water_z7 ->  layer_water:z7
        SELECT * FROM water_z7 WHERE zoom_level = 7
        UNION ALL
        -- etldoc: water_z8 ->  layer_water:z8
        SELECT * FROM water_z8 WHERE zoom_level = 8
        UNION ALL
        -- etldoc: water_z9 ->  layer_water:z9
        SELECT * FROM water_z9 WHERE zoom_level = 9
        UNION ALL
        -- etldoc: water_z10 ->  layer_water:z10
        SELECT * FROM water_z10 WHERE zoom_level = 10
        UNION ALL
        -- etldoc: water_z11 ->  layer_water:z11
        SELECT * FROM water_z11 WHERE zoom_level = 11
        UNION ALL
        -- etldoc: water_z12 ->  layer_water:z12
        SELECT * FROM water_z12 WHERE zoom_level = 12
        UNION ALL
        -- etldoc: water_z13 ->  layer_water:z13
        SELECT * FROM water_z13 WHERE zoom_level = 13
        UNION ALL
        -- etldoc: water_z14 ->  layer_water:z14_
        SELECT * FROM water_z14 WHERE zoom_level >= 14
    ) AS zoom_levels
    WHERE geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;
DO $$ BEGIN RAISE NOTICE 'Layer waterway'; END$$;DO $$
BEGIN
  update osm_waterway_linestring SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry);
  update osm_waterway_linestring_gen1 SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry);
  update osm_waterway_linestring_gen2 SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry);
  update osm_waterway_linestring_gen3 SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry);
END $$;
DROP TRIGGER IF EXISTS trigger_refresh ON osm_waterway_linestring;

DO $$
BEGIN
  update osm_waterway_linestring SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry);
  update osm_waterway_linestring_gen1 SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry);
  update osm_waterway_linestring_gen2 SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry);
  update osm_waterway_linestring_gen3 SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry);
END $$;


-- Handle updates

CREATE SCHEMA IF NOT EXISTS waterway_linestring;
CREATE OR REPLACE FUNCTION waterway_linestring.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE NOTICE 'Refresh waterway_linestring %', NEW.osm_id;
    NEW.tags = slice_language_tags(NEW.tags) || get_basic_names(NEW.tags, NEW.geometry);
    RETURN NEW;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_refresh
    BEFORE INSERT OR UPDATE ON osm_waterway_linestring
    FOR EACH ROW
    EXECUTE PROCEDURE waterway_linestring.refresh();
DROP TRIGGER IF EXISTS trigger_flag ON osm_waterway_linestring;
DROP TRIGGER IF EXISTS trigger_refresh ON waterway_important.updates;

-- We merge the waterways by name like the highways
-- This helps to drop not important rivers (since they do not have a name)
-- and also makes it possible to filter out too short rivers

-- etldoc: osm_waterway_linestring ->  osm_important_waterway_linestring
DROP MATERIALIZED VIEW IF EXISTS osm_important_waterway_linestring CASCADE;
DROP MATERIALIZED VIEW IF EXISTS osm_important_waterway_linestring_gen1 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS osm_important_waterway_linestring_gen2 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS osm_important_waterway_linestring_gen3 CASCADE;

CREATE INDEX IF NOT EXISTS osm_waterway_linestring_waterway_partial_idx
    ON osm_waterway_linestring(waterway)
    WHERE waterway = 'river';

CREATE INDEX IF NOT EXISTS osm_waterway_linestring_name_partial_idx
    ON osm_waterway_linestring(name)
    WHERE name <> '';

CREATE MATERIALIZED VIEW osm_important_waterway_linestring AS (
    SELECT
        (ST_Dump(geometry)).geom AS geometry,
        name, name_en, name_de, tags
    FROM (
        SELECT
            ST_LineMerge(ST_Union(geometry)) AS geometry,
            name, name_en, name_de, tags
        FROM osm_waterway_linestring
        WHERE name <> '' AND waterway = 'river'
        GROUP BY name, name_en, name_de, tags
    ) AS waterway_union
);
CREATE INDEX IF NOT EXISTS osm_important_waterway_linestring_geometry_idx ON osm_important_waterway_linestring USING gist(geometry);

-- etldoc: osm_important_waterway_linestring -> osm_important_waterway_linestring_gen1
CREATE MATERIALIZED VIEW osm_important_waterway_linestring_gen1 AS (
    SELECT ST_Simplify(geometry, 60) AS geometry, name, name_en, name_de, tags
    FROM osm_important_waterway_linestring
    WHERE ST_Length(geometry) > 1000
);
CREATE INDEX IF NOT EXISTS osm_important_waterway_linestring_gen1_geometry_idx ON osm_important_waterway_linestring_gen1 USING gist(geometry);

-- etldoc: osm_important_waterway_linestring_gen1 -> osm_important_waterway_linestring_gen2
CREATE MATERIALIZED VIEW osm_important_waterway_linestring_gen2 AS (
    SELECT ST_Simplify(geometry, 100) AS geometry, name, name_en, name_de, tags
    FROM osm_important_waterway_linestring_gen1
    WHERE ST_Length(geometry) > 4000
);
CREATE INDEX IF NOT EXISTS osm_important_waterway_linestring_gen2_geometry_idx ON osm_important_waterway_linestring_gen2 USING gist(geometry);

-- etldoc: osm_important_waterway_linestring_gen2 -> osm_important_waterway_linestring_gen3
CREATE MATERIALIZED VIEW osm_important_waterway_linestring_gen3 AS (
    SELECT ST_Simplify(geometry, 200) AS geometry, name, name_en, name_de, tags
    FROM osm_important_waterway_linestring_gen2
    WHERE ST_Length(geometry) > 8000
);
CREATE INDEX IF NOT EXISTS osm_important_waterway_linestring_gen3_geometry_idx ON osm_important_waterway_linestring_gen3 USING gist(geometry);

-- Handle updates

CREATE SCHEMA IF NOT EXISTS waterway_important;

CREATE TABLE IF NOT EXISTS waterway_important.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION waterway_important.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO waterway_important.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION waterway_important.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh waterway';
    REFRESH MATERIALIZED VIEW osm_important_waterway_linestring;
    REFRESH MATERIALIZED VIEW osm_important_waterway_linestring_gen1;
    REFRESH MATERIALIZED VIEW osm_important_waterway_linestring_gen2;
    REFRESH MATERIALIZED VIEW osm_important_waterway_linestring_gen3;
    DELETE FROM waterway_important.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_waterway_linestring
    FOR EACH STATEMENT
    EXECUTE PROCEDURE waterway_important.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON waterway_important.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE waterway_important.refresh();

-- etldoc: ne_110m_rivers_lake_centerlines ->  waterway_z3
CREATE OR REPLACE VIEW waterway_z3 AS (
    SELECT geometry, 'river'::text AS class, NULL::text AS name, NULL::text AS name_en, NULL::text AS name_de, NULL::hstore AS tags
    FROM ne_110m_rivers_lake_centerlines
    WHERE featurecla = 'River'
);

-- etldoc: ne_50m_rivers_lake_centerlines ->  waterway_z4
CREATE OR REPLACE VIEW waterway_z4 AS (
    SELECT geometry, 'river'::text AS class, NULL::text AS name, NULL::text AS name_en, NULL::text AS name_de, NULL::hstore AS tags
    FROM ne_50m_rivers_lake_centerlines
    WHERE featurecla = 'River'
);

-- etldoc: ne_10m_rivers_lake_centerlines ->  waterway_z6
CREATE OR REPLACE VIEW waterway_z6 AS (
    SELECT geometry, 'river'::text AS class, NULL::text AS name, NULL::text AS name_en, NULL::text AS name_de, NULL::hstore AS tags
    FROM ne_10m_rivers_lake_centerlines
    WHERE featurecla = 'River'
);

-- etldoc: osm_important_waterway_linestring_gen3 ->  waterway_z9
CREATE OR REPLACE VIEW waterway_z9 AS (
    SELECT geometry, 'river'::text AS class, name, name_en, name_de, tags FROM osm_important_waterway_linestring_gen3
);

-- etldoc: osm_important_waterway_linestring_gen2 ->  waterway_z10
CREATE OR REPLACE VIEW waterway_z10 AS (
    SELECT geometry, 'river'::text AS class, name, name_en, name_de, tags FROM osm_important_waterway_linestring_gen2
);

-- etldoc:osm_important_waterway_linestring_gen1 ->  waterway_z11
CREATE OR REPLACE VIEW waterway_z11 AS (
    SELECT geometry, 'river'::text AS class, name, name_en, name_de, tags FROM osm_important_waterway_linestring_gen1
);

-- etldoc: osm_waterway_linestring ->  waterway_z12
CREATE OR REPLACE VIEW waterway_z12 AS (
    SELECT geometry, waterway AS class, name, name_en, name_de, tags FROM osm_waterway_linestring
    WHERE waterway IN ('river', 'canal')
);

-- etldoc: osm_waterway_linestring ->  waterway_z13
CREATE OR REPLACE VIEW waterway_z13 AS (
    SELECT geometry, waterway::text AS class, name, name_en, name_de, tags FROM osm_waterway_linestring
    WHERE waterway IN ('river', 'canal', 'stream', 'drain', 'ditch')
);

-- etldoc: osm_waterway_linestring ->  waterway_z14
CREATE OR REPLACE VIEW waterway_z14 AS (
    SELECT geometry, waterway::text AS class, name, name_en, name_de, tags FROM osm_waterway_linestring
);

-- etldoc: layer_waterway[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_waterway | <z3> z3 |<z4_5> z4-z5 |<z6_8> z6-8 | <z9> z9 |<z10> z10 |<z11> z11 |<z12> z12|<z13> z13|<z14> z14+" ];

CREATE OR REPLACE FUNCTION layer_waterway(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, class text, name text, name_en text, name_de text, tags hstore) AS $$
    SELECT geometry, class,
        NULLIF(name, '') AS name,
        COALESCE(NULLIF(name_en, ''), name) AS name_en,
        COALESCE(NULLIF(name_de, ''), name, name_en) AS name_de,
        tags
    FROM (
        -- etldoc: waterway_z3 ->  layer_waterway:z3
        SELECT * FROM waterway_z3 WHERE zoom_level = 3
        UNION ALL
        -- etldoc: waterway_z4 ->  layer_waterway:z4_5
        SELECT * FROM waterway_z4 WHERE zoom_level BETWEEN 4 AND 5
        UNION ALL
        -- etldoc: waterway_z6 ->  layer_waterway:z6_8
        SELECT * FROM waterway_z6 WHERE zoom_level BETWEEN 6 AND 8
        UNION ALL
        -- etldoc: waterway_z9 ->  layer_waterway:z9
        SELECT * FROM waterway_z9 WHERE zoom_level = 9
        UNION ALL
        -- etldoc: waterway_z10 ->  layer_waterway:z10
        SELECT * FROM waterway_z10 WHERE zoom_level = 10
        UNION ALL
        -- etldoc: waterway_z11 ->  layer_waterway:z11
        SELECT * FROM waterway_z11 WHERE zoom_level = 11
        UNION ALL
        -- etldoc: waterway_z12 ->  layer_waterway:z12
        SELECT * FROM waterway_z12 WHERE zoom_level = 12
        UNION ALL
        -- etldoc: waterway_z13 ->  layer_waterway:z13
        SELECT * FROM waterway_z13 WHERE zoom_level = 13
        UNION ALL
        -- etldoc: waterway_z14 ->  layer_waterway:z14
        SELECT * FROM waterway_z14 WHERE zoom_level >= 14
    ) AS zoom_levels
    WHERE geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;
DO $$ BEGIN RAISE NOTICE 'Layer landcover'; END$$;--TODO: Find a way to nicely generalize landcover
--CREATE TABLE IF NOT EXISTS landcover_grouped_gen2 AS (
--	SELECT osm_id, ST_Simplify((ST_Dump(geometry)).geom, 600) AS geometry, landuse, "natural", wetland
--	FROM (
--	  SELECT max(osm_id) AS osm_id, ST_Union(ST_Buffer(geometry, 600)) AS geometry, landuse, "natural", wetland
--	  FROM osm_landcover_polygon_gen1
--	  GROUP BY LabelGrid(geometry, 15000000), landuse, "natural", wetland
--	) AS grouped_measurements
--);
--CREATE INDEX IF NOT EXISTS landcover_grouped_gen2_geometry_idx ON landcover_grouped_gen2 USING gist(geometry);

CREATE OR REPLACE FUNCTION landcover_class(landuse VARCHAR, "natural" VARCHAR, leisure VARCHAR, wetland VARCHAR) RETURNS TEXT AS $$
    SELECT CASE
         WHEN landuse IN ('farmland', 'farm', 'orchard', 'vineyard', 'plant_nursery') THEN 'farmland'
         WHEN "natural" IN ('glacier', 'ice_shelf') THEN 'ice'
         WHEN "natural"='wood' OR landuse IN ('forest') THEN 'wood'
         WHEN "natural" IN ('bare_rock', 'scree') THEN 'rock'
         WHEN "natural"='grassland' OR landuse IN ('grass', 'meadow', 'allotments', 'grassland', 'park', 'village_green', 'recreation_ground') OR leisure='park' THEN 'grass'
         WHEN "natural"='wetland' OR wetland IN ('bog', 'swamp', 'wet_meadow', 'marsh', 'reedbed', 'saltern', 'tidalflat', 'saltmarsh', 'mangrove') THEN 'wetland'
        ELSE NULL
    END;
$$ LANGUAGE SQL IMMUTABLE;

-- etldoc: ne_110m_glaciated_areas ->  landcover_z0
CREATE OR REPLACE VIEW landcover_z0 AS (
    SELECT NULL::bigint AS osm_id, geometry, NULL::text AS landuse, 'glacier'::text AS "natural", NULL::text AS leisure, NULL::text AS wetland FROM ne_110m_glaciated_areas
);

CREATE OR REPLACE VIEW landcover_z2 AS (
    -- etldoc: ne_50m_glaciated_areas ->  landcover_z2
    SELECT NULL::bigint AS osm_id, geometry, NULL::text AS landuse, 'glacier'::text AS "natural", NULL::text AS leisure, NULL::text AS wetland FROM ne_50m_glaciated_areas
    UNION ALL
    -- etldoc: ne_50m_antarctic_ice_shelves_polys ->  landcover_z2
    SELECT NULL::bigint AS osm_id, geometry, NULL::text AS landuse, 'ice_shelf'::text AS "natural", NULL::text AS leisure, NULL::text AS wetland FROM ne_50m_antarctic_ice_shelves_polys
);

CREATE OR REPLACE VIEW landcover_z5 AS (
    -- etldoc: ne_10m_glaciated_areas ->  landcover_z5
    SELECT NULL::bigint AS osm_id, geometry, NULL::text AS landuse, 'glacier'::text AS "natural", NULL::text AS leisure, NULL::text AS wetland FROM ne_10m_glaciated_areas
    UNION ALL
    -- etldoc: ne_10m_antarctic_ice_shelves_polys ->  landcover_z5
    SELECT NULL::bigint AS osm_id, geometry, NULL::text AS landuse, 'ice_shelf'::text AS "natural", NULL::text AS leisure, NULL::text AS wetland FROM ne_10m_antarctic_ice_shelves_polys
);

CREATE OR REPLACE VIEW landcover_z7 AS (
    -- etldoc: osm_landcover_polygon_gen7 ->  landcover_z7
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland FROM osm_landcover_polygon_gen7
);

CREATE OR REPLACE VIEW landcover_z8 AS (
    -- etldoc: osm_landcover_polygon_gen6 ->  landcover_z8
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland FROM osm_landcover_polygon_gen6
);

CREATE OR REPLACE VIEW landcover_z9 AS (
    -- etldoc: osm_landcover_polygon_gen5 ->  landcover_z9
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland FROM osm_landcover_polygon_gen5
);

CREATE OR REPLACE VIEW landcover_z10 AS (
    -- etldoc: osm_landcover_polygon_gen4 ->  landcover_z10
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland FROM osm_landcover_polygon_gen4
);

CREATE OR REPLACE VIEW landcover_z11 AS (
    -- etldoc: osm_landcover_polygon_gen3 ->  landcover_z11
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland FROM osm_landcover_polygon_gen3
);

CREATE OR REPLACE VIEW landcover_z12 AS (
    -- etldoc: osm_landcover_polygon_gen2 ->  landcover_z12
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland FROM osm_landcover_polygon_gen2
);

CREATE OR REPLACE VIEW landcover_z13 AS (
    -- etldoc: osm_landcover_polygon_gen1 ->  landcover_z13
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland FROM osm_landcover_polygon_gen1
);

CREATE OR REPLACE VIEW landcover_z14 AS (
    -- etldoc: osm_landcover_polygon ->  landcover_z14
    SELECT osm_id, geometry, landuse, "natural", leisure, wetland FROM osm_landcover_polygon
);

-- etldoc: layer_landcover[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_landcover | <z0_1> z0-z1 | <z2_4> z2-z4 | <z5_7> z5-z7 | <z8> z8 |<z9> z9 |<z10> z10 |<z11> z11 |<z12> z12|<z13> z13|<z14_> z14+" ] ;

CREATE OR REPLACE FUNCTION layer_landcover(bbox geometry, zoom_level int)
RETURNS TABLE(osm_id bigint, geometry geometry, class text, subclass text) AS $$
    SELECT osm_id, geometry,
        landcover_class(landuse, "natural", leisure, wetland) AS class,
        COALESCE(
            NULLIF("natural", ''), NULLIF(landuse, ''),
            NULLIF(leisure, ''), NULLIF(wetland, '')
        ) AS subclass
        FROM (
        -- etldoc:  landcover_z0 -> layer_landcover:z0_1
        SELECT * FROM landcover_z0
        WHERE zoom_level BETWEEN 0 AND 1 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z2 -> layer_landcover:z2_4
        SELECT * FROM landcover_z2
        WHERE zoom_level BETWEEN 2 AND 4 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z5 -> layer_landcover:z5_6
        SELECT * FROM landcover_z5
        WHERE zoom_level BETWEEN 5 AND 6 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z7 -> layer_landcover:z7
        SELECT *
        FROM landcover_z7 WHERE zoom_level = 7 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z8 -> layer_landcover:z8
        SELECT *
        FROM landcover_z8 WHERE zoom_level = 8 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z9 -> layer_landcover:z9
        SELECT *
        FROM landcover_z9 WHERE zoom_level = 9 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z10 -> layer_landcover:z10
        SELECT *
        FROM landcover_z10 WHERE zoom_level = 10 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z11 -> layer_landcover:z11
        SELECT *
        FROM landcover_z11 WHERE zoom_level = 11 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z12 -> layer_landcover:z12
        SELECT *
        FROM landcover_z12 WHERE zoom_level = 12 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z13 -> layer_landcover:z13
        SELECT *
        FROM landcover_z13 WHERE zoom_level = 13 AND geometry && bbox
        UNION ALL
        -- etldoc:  landcover_z14 -> layer_landcover:z14_
        SELECT *
        FROM landcover_z14 WHERE zoom_level >= 14 AND geometry && bbox
    ) AS zoom_levels;
$$ LANGUAGE SQL IMMUTABLE;
DO $$ BEGIN RAISE NOTICE 'Layer landuse'; END$$;-- etldoc: ne_50m_urban_areas -> landuse_z4
CREATE OR REPLACE VIEW landuse_z4 AS (
    SELECT NULL::bigint AS osm_id, geometry, 'residential'::text AS landuse, NULL::text AS amenity, NULL::text AS leisure, scalerank
    FROM ne_50m_urban_areas
    WHERE scalerank <= 2
);

-- etldoc: ne_50m_urban_areas -> landuse_z5
CREATE OR REPLACE VIEW landuse_z5 AS (
    SELECT NULL::bigint AS osm_id, geometry, 'residential'::text AS landuse, NULL::text AS amenity, NULL::text AS leisure, scalerank
    FROM ne_50m_urban_areas
);

-- etldoc: ne_10m_urban_areas -> landuse_z6
CREATE OR REPLACE VIEW landuse_z6 AS (
    SELECT NULL::bigint AS osm_id, geometry, 'residential'::text AS landuse, NULL::text AS amenity, NULL::text AS leisure, scalerank
    FROM ne_10m_urban_areas
);

-- etldoc: osm_landuse_polygon_gen5 -> landuse_z9
CREATE OR REPLACE VIEW landuse_z9 AS (
    SELECT osm_id, geometry, landuse, amenity, leisure, NULL::int as scalerank
    FROM osm_landuse_polygon_gen5
);

-- etldoc: osm_landuse_polygon_gen4 -> landuse_z10
CREATE OR REPLACE VIEW landuse_z10 AS (
    SELECT osm_id, geometry, landuse, amenity, leisure, NULL::int as scalerank
    FROM osm_landuse_polygon_gen4
);

-- etldoc: osm_landuse_polygon_gen3 -> landuse_z11
CREATE OR REPLACE VIEW landuse_z11 AS (
    SELECT osm_id, geometry, landuse, amenity, leisure, NULL::int as scalerank
    FROM osm_landuse_polygon_gen3
);

-- etldoc: osm_landuse_polygon_gen2 -> landuse_z12
CREATE OR REPLACE VIEW landuse_z12 AS (
    SELECT osm_id, geometry, landuse, amenity, leisure, NULL::int as scalerank
    FROM osm_landuse_polygon_gen2
);

-- etldoc: osm_landuse_polygon_gen1 -> landuse_z13
CREATE OR REPLACE VIEW landuse_z13 AS (
    SELECT osm_id, geometry, landuse, amenity, leisure, NULL::int as scalerank
    FROM osm_landuse_polygon_gen1
);

-- etldoc: osm_landuse_polygon -> landuse_z14
CREATE OR REPLACE VIEW landuse_z14 AS (
    SELECT osm_id, geometry, landuse, amenity, leisure, NULL::int as scalerank
    FROM osm_landuse_polygon
);

-- etldoc: layer_landuse[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_landuse |<z4> z4|<z5>z5|<z6>z6|<z7>z7| <z8> z8 |<z9> z9 |<z10> z10 |<z11> z11|<z12> z12|<z13> z13|<z14> z14+" ] ;

CREATE OR REPLACE FUNCTION layer_landuse(bbox geometry, zoom_level int)
RETURNS TABLE(osm_id bigint, geometry geometry, class text) AS $$
    SELECT osm_id, geometry,
        COALESCE(
            NULLIF(landuse, ''),
            NULLIF(amenity, ''),
            NULLIF(leisure, '')
        ) AS class
        FROM (
        -- etldoc: landuse_z4 -> layer_landuse:z4
        SELECT * FROM landuse_z4
        WHERE zoom_level = 4
        UNION ALL
        -- etldoc: landuse_z5 -> layer_landuse:z5
        SELECT * FROM landuse_z5
        WHERE zoom_level = 5
        UNION ALL
        -- etldoc: landuse_z6 -> layer_landuse:z6
        -- etldoc: landuse_z6 -> layer_landuse:z7
        -- etldoc: landuse_z6 -> layer_landuse:z8
        SELECT * FROM landuse_z6
        WHERE zoom_level BETWEEN 6 AND 8 AND scalerank-1 <= zoom_level
        UNION ALL
        -- etldoc: landuse_z9 -> layer_landuse:z9
        SELECT * FROM landuse_z9 WHERE zoom_level = 9
        UNION ALL
        -- etldoc: landuse_z10 -> layer_landuse:z10
        SELECT * FROM landuse_z10 WHERE zoom_level = 10
        UNION ALL
        -- etldoc: landuse_z11 -> layer_landuse:z11
        SELECT * FROM landuse_z11 WHERE zoom_level = 11
        UNION ALL
        -- etldoc: landuse_z12 -> layer_landuse:z12
        SELECT * FROM landuse_z12 WHERE zoom_level = 12
        UNION ALL
        -- etldoc: landuse_z13 -> layer_landuse:z13
        SELECT * FROM landuse_z13 WHERE zoom_level = 13
        UNION ALL
        -- etldoc: landuse_z14 -> layer_landuse:z14
        SELECT * FROM landuse_z14 WHERE zoom_level >= 14
    ) AS zoom_levels
    WHERE geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;

DO $$ BEGIN RAISE NOTICE 'Layer mountain_peak'; END$$;DROP TRIGGER IF EXISTS trigger_flag ON osm_peak_point;
DROP TRIGGER IF EXISTS trigger_refresh ON mountain_peak_point.updates;

-- etldoc:  osm_peak_point ->  osm_peak_point
CREATE OR REPLACE FUNCTION update_osm_peak_point() RETURNS VOID AS $$
BEGIN
  UPDATE osm_peak_point
  SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry)
  WHERE COALESCE(tags->'name:latin', tags->'name:nonlatin', tags->'name_int') IS NULL;

END;
$$ LANGUAGE plpgsql;

SELECT update_osm_peak_point();

-- Handle updates

CREATE SCHEMA IF NOT EXISTS mountain_peak_point;

CREATE TABLE IF NOT EXISTS mountain_peak_point.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION mountain_peak_point.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO mountain_peak_point.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION mountain_peak_point.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh mountain_peak_point';
    PERFORM update_osm_peak_point();
    DELETE FROM mountain_peak_point.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_peak_point
    FOR EACH STATEMENT
    EXECUTE PROCEDURE mountain_peak_point.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON mountain_peak_point.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE mountain_peak_point.refresh();

-- etldoc: layer_mountain_peak[shape=record fillcolor=lightpink,
-- etldoc:     style="rounded,filled", label="layer_mountain_peak | <z7_> z7+" ] ;

CREATE OR REPLACE FUNCTION layer_mountain_peak(bbox geometry, zoom_level integer, pixel_width numeric)
RETURNS TABLE(osm_id bigint, geometry geometry, name text, name_en text, name_de text, tags hstore, ele int, ele_ft int, "rank" int) AS $$
   -- etldoc: osm_peak_point -> layer_mountain_peak:z7_
   SELECT osm_id, geometry, name, name_en, name_de, tags, ele::int, ele_ft::int, rank::int
   FROM (
     SELECT osm_id, geometry, name,
     COALESCE(NULLIF(name_en, ''), name) AS name_en,
     COALESCE(NULLIF(name_de, ''), name, name_en) AS name_de,
     tags,
     substring(ele from E'^(-?\\d+)(\\D|$)')::int AS ele,
     round(substring(ele from E'^(-?\\d+)(\\D|$)')::int*3.2808399)::int AS ele_ft,
       row_number() OVER (
           PARTITION BY LabelGrid(geometry, 100 * pixel_width)
           ORDER BY (
             substring(ele from E'^(-?\\d+)(\\D|$)')::int +
             (CASE WHEN NULLIF(wikipedia, '') is not null THEN 10000 ELSE 0 END) +
             (CASE WHEN NULLIF(name, '') is not null THEN 10000 ELSE 0 END)
           ) DESC
       )::int AS "rank"
     FROM osm_peak_point
     WHERE geometry && bbox AND ele is not null AND ele ~ E'^-?\\d+'
   ) AS ranked_peaks
   WHERE zoom_level >= 7 AND (rank <= 5 OR zoom_level >= 14)
   ORDER BY "rank" ASC;

$$ LANGUAGE SQL IMMUTABLE;
DO $$ BEGIN RAISE NOTICE 'Layer park'; END$$;-- etldoc: layer_park[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_park |<z6> z6 |<z7> z7 |<z8> z8 |<z9> z9 |<z10> z10 |<z11> z11 |<z12> z12|<z13> z13|<z14> z14+" ] ;

CREATE OR REPLACE FUNCTION layer_park(bbox geometry, zoom_level int)
RETURNS TABLE(osm_id bigint, geometry geometry, class text) AS $$
    SELECT osm_id, geometry,
        COALESCE(NULLIF(leisure, ''), NULLIF(boundary, '')) AS class
        FROM (
        -- etldoc: osm_park_polygon_gen8 -> layer_park:z6
        SELECT osm_id, geometry, leisure, boundary, NULL::int as scalerank
        FROM osm_park_polygon_gen8
        WHERE zoom_level = 6
        UNION ALL
        -- etldoc: osm_park_polygon_gen7 -> layer_park:z7
        SELECT osm_id, geometry, leisure, boundary, NULL::int as scalerank
        FROM osm_park_polygon_gen7
        WHERE zoom_level = 7
        UNION ALL
        -- etldoc: osm_park_polygon_gen6 -> layer_park:z8
        SELECT osm_id, geometry, leisure, boundary, NULL::int as scalerank
        FROM osm_park_polygon_gen6
        WHERE zoom_level = 8
        UNION ALL
        -- etldoc: osm_park_polygon_gen5 -> layer_park:z9
        SELECT osm_id, geometry, leisure, boundary, NULL::int as scalerank
        FROM osm_park_polygon_gen5
        WHERE zoom_level = 9
        UNION ALL
        -- etldoc: osm_park_polygon_gen4 -> layer_park:z10
        SELECT osm_id, geometry, leisure, boundary, NULL::int as scalerank
        FROM osm_park_polygon_gen4
        WHERE zoom_level = 10
        UNION ALL
        -- etldoc: osm_park_polygon_gen3 -> layer_park:z11
        SELECT osm_id, geometry, leisure, boundary, NULL::int as scalerank
        FROM osm_park_polygon_gen3
        WHERE zoom_level = 11
        UNION ALL
        -- etldoc: osm_park_polygon_gen2 -> layer_park:z12
        SELECT osm_id, geometry, leisure, boundary, NULL::int as scalerank
        FROM osm_park_polygon_gen2
        WHERE zoom_level = 12
        UNION ALL
        -- etldoc: osm_park_polygon_gen1 -> layer_park:z13
        SELECT osm_id, geometry, leisure, boundary, NULL::int as scalerank
        FROM osm_park_polygon_gen1
        WHERE zoom_level = 13
        UNION ALL
        -- etldoc: osm_park_polygon -> layer_park:z14
        SELECT osm_id, geometry, leisure, boundary, NULL::int as scalerank
        FROM osm_park_polygon
        WHERE zoom_level >= 14
    ) AS zoom_levels
    WHERE geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;
DO $$ BEGIN RAISE NOTICE 'Layer boundary'; END$$;

-- etldoc: ne_110m_admin_0_boundary_lines_land  -> boundary_z0

CREATE OR REPLACE VIEW boundary_z0 AS (
    SELECT geometry, 2 AS admin_level, false AS disputed, false AS maritime
    FROM ne_110m_admin_0_boundary_lines_land
);

-- etldoc: ne_50m_admin_0_boundary_lines_land  -> boundary_z1
-- etldoc: ne_50m_admin_1_states_provinces_lines -> boundary_z1

CREATE OR REPLACE VIEW boundary_z1 AS (
    SELECT geometry, 2 AS admin_level, false AS disputed, false AS maritime
    FROM ne_50m_admin_0_boundary_lines_land
    UNION ALL
    SELECT geometry, 4 AS admin_level, false AS disputed, false AS maritime
    FROM ne_50m_admin_1_states_provinces_lines
    WHERE scalerank <= 2
);


-- etldoc: ne_50m_admin_0_boundary_lines_land -> boundary_z3
-- etldoc: ne_50m_admin_1_states_provinces_lines -> boundary_z3

CREATE OR REPLACE VIEW boundary_z3 AS (
    SELECT geometry, 2 AS admin_level, false AS disputed, false AS maritime
    FROM ne_50m_admin_0_boundary_lines_land
    UNION ALL
    SELECT geometry, 4 AS admin_level, false AS disputed, false AS maritime
    FROM ne_50m_admin_1_states_provinces_lines
);


-- etldoc: ne_10m_admin_0_boundary_lines_land -> boundary_z4
-- etldoc: ne_10m_admin_1_states_provinces_lines_shp -> boundary_z4
-- etldoc: osm_border_linestring_gen10 -> boundary_z4

CREATE OR REPLACE VIEW boundary_z4 AS (
    SELECT geometry, 2 AS admin_level, false AS disputed, false AS maritime
    FROM ne_10m_admin_0_boundary_lines_land
    UNION ALL
    SELECT geometry, 4 AS admin_level, false AS disputed, false AS maritime
    FROM ne_10m_admin_1_states_provinces_lines_shp
    WHERE scalerank <= 3 AND featurecla = 'Adm-1 boundary'
    UNION ALL
    SELECT geometry, admin_level, disputed, maritime
    FROM osm_border_linestring_gen10
    WHERE maritime=true AND admin_level <= 2
);

-- etldoc: ne_10m_admin_0_boundary_lines_land -> boundary_z5
-- etldoc: ne_10m_admin_1_states_provinces_lines_shp -> boundary_z5
-- etldoc: osm_border_linestring_gen9 -> boundary_z5

CREATE OR REPLACE VIEW boundary_z5 AS (
    SELECT geometry, 2 AS admin_level, false AS disputed, false AS maritime
    FROM ne_10m_admin_0_boundary_lines_land
    UNION ALL
    SELECT geometry, 4 AS admin_level, false AS disputed, false AS maritime
    FROM ne_10m_admin_1_states_provinces_lines_shp
    WHERE scalerank <= 7 AND featurecla = 'Adm-1 boundary'
    UNION ALL
    SELECT geometry, admin_level, disputed, maritime
    FROM osm_border_linestring_gen9
    WHERE maritime=true AND admin_level <= 2
);

-- etldoc: osm_border_linestring_gen8 -> boundary_z6
CREATE OR REPLACE VIEW boundary_z6 AS (
    SELECT geometry, admin_level, disputed, maritime
    FROM osm_border_linestring_gen8
    WHERE admin_level <= 4
);

-- etldoc: osm_border_linestring_gen7 -> boundary_z7
CREATE OR REPLACE VIEW boundary_z7 AS (
    SELECT geometry, admin_level, disputed, maritime
    FROM osm_border_linestring_gen7
    WHERE admin_level <= 4
);

-- etldoc: osm_border_linestring_gen6 -> boundary_z8
CREATE OR REPLACE VIEW boundary_z8 AS (
    SELECT geometry, admin_level, disputed, maritime
    FROM osm_border_linestring_gen6
    WHERE admin_level <= 4
);

-- etldoc: osm_border_linestring_gen5 -> boundary_z9
CREATE OR REPLACE VIEW boundary_z9 AS (
    SELECT geometry, admin_level, disputed, maritime
    FROM osm_border_linestring_gen5
    WHERE admin_level <= 6
);

-- etldoc: osm_border_linestring_gen4 -> boundary_z10
CREATE OR REPLACE VIEW boundary_z10 AS (
    SELECT geometry, admin_level, disputed, maritime
    FROM osm_border_linestring_gen4
    WHERE admin_level <= 6
);

-- etldoc: osm_border_linestring_gen3 -> boundary_z11
CREATE OR REPLACE VIEW boundary_z11 AS (
    SELECT geometry, admin_level, disputed, maritime
    FROM osm_border_linestring_gen3
    WHERE admin_level <= 8
);

-- etldoc: osm_border_linestring_gen2 -> boundary_z12
CREATE OR REPLACE VIEW boundary_z12 AS (
    SELECT geometry, admin_level, disputed, maritime
    FROM osm_border_linestring_gen2
);

-- etldoc: osm_border_linestring_gen1 -> boundary_z12
CREATE OR REPLACE VIEW boundary_z13 AS (
    SELECT geometry, admin_level, disputed, maritime
    FROM osm_border_linestring_gen1
);

-- etldoc: layer_boundary[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="<sql> layer_boundary |<z0> z0 |<z1_2> z1_2 | <z3> z3 | <z4> z4 | <z5> z5 | <z6> z6 | <z7> z7 | <z8> z8 | <z9> z9 |<z10> z10 |<z11> z11 |<z12> z12|<z13> z13+"]

CREATE OR REPLACE FUNCTION layer_boundary (bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, admin_level int, disputed int, maritime int) AS $$
    SELECT geometry, admin_level, disputed::int, maritime::int FROM (
        -- etldoc: boundary_z0 ->  layer_boundary:z0
        SELECT * FROM boundary_z0 WHERE geometry && bbox AND zoom_level = 0
        UNION ALL
        -- etldoc: boundary_z1 ->  layer_boundary:z1_2
        SELECT * FROM boundary_z1 WHERE geometry && bbox AND zoom_level BETWEEN 1 AND 2
        UNION ALL
        -- etldoc: boundary_z3 ->  layer_boundary:z3
        SELECT * FROM boundary_z3 WHERE geometry && bbox AND zoom_level = 3
        UNION ALL
        -- etldoc: boundary_z4 ->  layer_boundary:z4
        SELECT * FROM boundary_z4 WHERE geometry && bbox AND zoom_level = 4
        UNION ALL
        -- etldoc: boundary_z5 ->  layer_boundary:z5
        SELECT * FROM boundary_z5 WHERE geometry && bbox AND zoom_level = 5
        UNION ALL
        -- etldoc: boundary_z6 ->  layer_boundary:z6
        SELECT * FROM boundary_z6 WHERE geometry && bbox AND zoom_level = 6
        UNION ALL
        -- etldoc: boundary_z7 ->  layer_boundary:z7
        SELECT * FROM boundary_z7 WHERE geometry && bbox AND zoom_level = 7
        UNION ALL
        -- etldoc: boundary_z8 ->  layer_boundary:z8
        SELECT * FROM boundary_z8 WHERE geometry && bbox AND zoom_level = 8
        UNION ALL
        -- etldoc: boundary_z9 ->  layer_boundary:z9
        SELECT * FROM boundary_z9 WHERE geometry && bbox AND zoom_level = 9
        UNION ALL
        -- etldoc: boundary_z10 ->  layer_boundary:z10
        SELECT * FROM boundary_z10 WHERE geometry && bbox AND zoom_level = 10
        UNION ALL
        -- etldoc: boundary_z11 ->  layer_boundary:z11
        SELECT * FROM boundary_z11 WHERE geometry && bbox AND zoom_level = 11
        UNION ALL
        -- etldoc: boundary_z12 ->  layer_boundary:z12
        SELECT * FROM boundary_z12 WHERE geometry && bbox AND zoom_level = 12
        UNION ALL
        -- etldoc: boundary_z13 -> layer_boundary:z13
        SELECT * FROM boundary_z13 WHERE geometry && bbox AND zoom_level >= 13
    ) AS zoom_levels;
$$ LANGUAGE SQL IMMUTABLE;
DO $$ BEGIN RAISE NOTICE 'Layer aeroway'; END$$;-- etldoc: layer_aeroway[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_aeroway |<z11> z11|<z12> z12|<z13> z13|<z14_> z14+" ];

CREATE OR REPLACE FUNCTION layer_aeroway(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, class text, ref text) AS $$
    SELECT geometry, aeroway AS class, ref FROM (
        -- etldoc:  osm_aeroway_linestring -> layer_aeroway:z11
        -- etldoc:  osm_aeroway_linestring -> layer_aeroway:z12
        -- etldoc:  osm_aeroway_linestring -> layer_aeroway:z13
        -- etldoc:  osm_aeroway_linestring -> layer_aeroway:z14_
        SELECT geometry, aeroway, ref
        FROM osm_aeroway_linestring WHERE zoom_level >= 11
        UNION ALL
        -- etldoc:  osm_aeroway_polygon_gen2 -> layer_aeroway:z12
        SELECT geometry, aeroway, ref
        FROM osm_aeroway_polygon_gen2 WHERE zoom_level = 12
        UNION ALL
        -- etldoc:  osm_aeroway_polygon_gen1 -> layer_aeroway:z13
        SELECT geometry, aeroway, ref
        FROM osm_aeroway_polygon_gen1 WHERE zoom_level = 13
        UNION ALL
        -- etldoc:  osm_aeroway_polygon -> layer_aeroway:z14_
        SELECT geometry, aeroway, ref
        FROM osm_aeroway_polygon WHERE zoom_level >= 14
    ) AS zoom_levels
    WHERE geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;
DO $$ BEGIN RAISE NOTICE 'Layer transportation'; END$$;CREATE OR REPLACE FUNCTION brunnel(is_bridge BOOL, is_tunnel BOOL, is_ford BOOL) RETURNS TEXT AS $$
    SELECT CASE
        WHEN is_bridge THEN 'bridge'
        WHEN is_tunnel THEN 'tunnel'
        WHEN is_ford THEN 'ford'
        ELSE NULL
    END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- The classes for highways are derived from the classes used in ClearTables
-- https://github.com/ClearTables/ClearTables/blob/master/transportation.lua
CREATE OR REPLACE FUNCTION highway_class(highway TEXT) RETURNS TEXT AS $$
    SELECT CASE
        WHEN highway IN ('motorway', 'motorway_link') THEN 'motorway'
        WHEN highway IN ('trunk', 'trunk_link') THEN 'trunk'
        WHEN highway IN ('primary', 'primary_link') THEN 'primary'
        WHEN highway IN ('secondary', 'secondary_link') THEN 'secondary'
        WHEN highway IN ('tertiary', 'tertiary_link') THEN 'tertiary'
        WHEN highway IN ('unclassified', 'residential', 'living_street', 'road') THEN 'minor'
        WHEN highway IN ('service', 'track') THEN highway
        WHEN highway IN ('pedestrian', 'path', 'footway', 'cycleway', 'steps', 'bridleway', 'corridor') THEN 'path'
        WHEN highway = 'raceway' THEN 'raceway'
        ELSE NULL
    END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- The classes for railways are derived from the classes used in ClearTables
-- https://github.com/ClearTables/ClearTables/blob/master/transportation.lua
CREATE OR REPLACE FUNCTION railway_class(railway TEXT) RETURNS TEXT AS $$
    SELECT CASE
        WHEN railway IN ('rail', 'narrow_gauge', 'preserved', 'funicular') THEN 'rail'
        WHEN railway IN ('subway', 'light_rail', 'monorail', 'tram') THEN 'transit'
        ELSE NULL
    END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- Limit service to only the most important values to ensure
-- we always know the values of service
CREATE OR REPLACE FUNCTION service_value(service TEXT) RETURNS TEXT AS $$
    SELECT CASE
        WHEN service IN ('spur', 'yard', 'siding', 'crossover', 'driveway', 'alley', 'parking_aisle') THEN service
        ELSE NULL
    END;
$$ LANGUAGE SQL IMMUTABLE STRICT;
DROP MATERIALIZED VIEW IF EXISTS osm_transportation_merge_linestring CASCADE;
DROP MATERIALIZED VIEW IF EXISTS osm_transportation_merge_linestring_gen3 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS osm_transportation_merge_linestring_gen4 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS osm_transportation_merge_linestring_gen5 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS osm_transportation_merge_linestring_gen6 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS osm_transportation_merge_linestring_gen7 CASCADE;


DROP TRIGGER IF EXISTS trigger_flag_transportation ON osm_highway_linestring;
DROP TRIGGER IF EXISTS trigger_refresh ON transportation.updates;

-- Instead of using relations to find out the road names we
-- stitch together the touching ways with the same name
-- to allow for nice label rendering
-- Because this works well for roads that do not have relations as well


-- Improve performance of the sql in transportation_name/network_type.sql
CREATE INDEX IF NOT EXISTS osm_highway_linestring_highway_idx
  ON osm_highway_linestring(highway);

-- Improve performance of the sql below
CREATE INDEX IF NOT EXISTS osm_highway_linestring_highway_partial_idx
  ON osm_highway_linestring(highway)
  WHERE highway IN ('motorway','trunk', 'primary');

  -- etldoc: osm_highway_linestring ->  osm_transportation_merge_linestring
CREATE MATERIALIZED VIEW osm_transportation_merge_linestring AS (
    SELECT
        (ST_Dump(geometry)).geom AS geometry,
        NULL::bigint AS osm_id,
        highway,
        z_order
    FROM (
      SELECT
          ST_LineMerge(ST_Collect(geometry)) AS geometry,
          highway,
          min(z_order) AS z_order
      FROM osm_highway_linestring
      WHERE highway IN ('motorway','trunk', 'primary')
      group by highway
    ) AS highway_union
);
CREATE INDEX IF NOT EXISTS osm_transportation_merge_linestring_geometry_idx
  ON osm_transportation_merge_linestring USING gist(geometry);
CREATE INDEX IF NOT EXISTS osm_transportation_merge_linestring_highway_partial_idx
  ON osm_transportation_merge_linestring(highway)
  WHERE highway IN ('motorway','trunk', 'primary');

-- etldoc: osm_transportation_merge_linestring -> osm_transportation_merge_linestring_gen3
CREATE MATERIALIZED VIEW osm_transportation_merge_linestring_gen3 AS (
    SELECT ST_Simplify(geometry, 120) AS geometry, osm_id, highway, z_order
    FROM osm_transportation_merge_linestring
    WHERE highway IN ('motorway','trunk', 'primary')
);
CREATE INDEX IF NOT EXISTS osm_transportation_merge_linestring_gen3_geometry_idx
  ON osm_transportation_merge_linestring_gen3 USING gist(geometry);
CREATE INDEX IF NOT EXISTS osm_transportation_merge_linestring_gen3_highway_partial_idx
  ON osm_transportation_merge_linestring_gen3(highway)
  WHERE highway IN ('motorway','trunk', 'primary');

-- etldoc: osm_transportation_merge_linestring_gen3 -> osm_transportation_merge_linestring_gen4
CREATE MATERIALIZED VIEW osm_transportation_merge_linestring_gen4 AS (
    SELECT ST_Simplify(geometry, 200) AS geometry, osm_id, highway, z_order
    FROM osm_transportation_merge_linestring_gen3
    WHERE highway IN ('motorway','trunk', 'primary') AND ST_Length(geometry) > 50
);
CREATE INDEX IF NOT EXISTS osm_transportation_merge_linestring_gen4_geometry_idx
  ON osm_transportation_merge_linestring_gen4 USING gist(geometry);
CREATE INDEX IF NOT EXISTS osm_transportation_merge_linestring_gen4_highway_partial_idx
  ON osm_transportation_merge_linestring_gen4(highway)
  WHERE highway IN ('motorway','trunk', 'primary');

-- etldoc: osm_transportation_merge_linestring_gen4 -> osm_transportation_merge_linestring_gen5
CREATE MATERIALIZED VIEW osm_transportation_merge_linestring_gen5 AS (
    SELECT ST_Simplify(geometry, 500) AS geometry, osm_id, highway, z_order
    FROM osm_transportation_merge_linestring_gen4
    WHERE highway IN ('motorway','trunk') AND ST_Length(geometry) > 100
);
CREATE INDEX IF NOT EXISTS osm_transportation_merge_linestring_gen5_geometry_idx
  ON osm_transportation_merge_linestring_gen5 USING gist(geometry);
CREATE INDEX IF NOT EXISTS osm_transportation_merge_linestring_gen5_highway_partial_idx
  ON osm_transportation_merge_linestring_gen5(highway)
  WHERE highway IN ('motorway', 'trunk');

-- etldoc: osm_transportation_merge_linestring_gen5 -> osm_transportation_merge_linestring_gen6
CREATE MATERIALIZED VIEW osm_transportation_merge_linestring_gen6 AS (
    SELECT ST_Simplify(geometry, 1000) AS geometry, osm_id, highway, z_order
    FROM osm_transportation_merge_linestring_gen5
    WHERE highway IN ('motorway','trunk') AND ST_Length(geometry) > 500
);
CREATE INDEX IF NOT EXISTS osm_transportation_merge_linestring_gen6_geometry_idx
  ON osm_transportation_merge_linestring_gen6 USING gist(geometry);
CREATE INDEX IF NOT EXISTS osm_transportation_merge_linestring_gen6_highway_partial_idx
  ON osm_transportation_merge_linestring_gen6(highway)
  WHERE highway IN ('motorway','trunk');

-- etldoc: osm_transportation_merge_linestring_gen6 -> osm_transportation_merge_linestring_gen7
CREATE MATERIALIZED VIEW osm_transportation_merge_linestring_gen7 AS (
    SELECT ST_Simplify(geometry, 2000) AS geometry, osm_id, highway, z_order
    FROM osm_transportation_merge_linestring_gen6
    WHERE highway IN ('motorway') AND ST_Length(geometry) > 1000
);
CREATE INDEX IF NOT EXISTS osm_transportation_merge_linestring_gen7_geometry_idx
  ON osm_transportation_merge_linestring_gen7 USING gist(geometry);


-- Handle updates

CREATE SCHEMA IF NOT EXISTS transportation;

CREATE TABLE IF NOT EXISTS transportation.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION transportation.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO transportation.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION transportation.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE NOTICE 'Refresh transportation';
    REFRESH MATERIALIZED VIEW osm_transportation_merge_linestring;
    REFRESH MATERIALIZED VIEW osm_transportation_merge_linestring_gen3;
    REFRESH MATERIALIZED VIEW osm_transportation_merge_linestring_gen4;
    REFRESH MATERIALIZED VIEW osm_transportation_merge_linestring_gen5;
    REFRESH MATERIALIZED VIEW osm_transportation_merge_linestring_gen6;
    REFRESH MATERIALIZED VIEW osm_transportation_merge_linestring_gen7;
    DELETE FROM transportation.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag_transportation
    AFTER INSERT OR UPDATE OR DELETE ON osm_highway_linestring
    FOR EACH STATEMENT
    EXECUTE PROCEDURE transportation.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON transportation.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE transportation.refresh();
CREATE OR REPLACE FUNCTION highway_is_link(highway TEXT) RETURNS BOOLEAN AS $$
    SELECT highway LIKE '%_link';
$$ LANGUAGE SQL IMMUTABLE STRICT;


-- etldoc: layer_transportation[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="<sql> layer_transportation |<z4> z4 |<z5> z5 |<z6> z6 |<z7> z7 |<z8> z8 |<z9> z9 |<z10> z10 |<z11> z11 |<z12> z12|<z13> z13|<z14_> z14+" ] ;
CREATE OR REPLACE FUNCTION layer_transportation(bbox geometry, zoom_level int)
RETURNS TABLE(osm_id bigint, geometry geometry, class text, ramp int, oneway int, brunnel TEXT, service TEXT) AS $$
    SELECT
        osm_id, geometry,
        CASE
            WHEN highway IS NOT NULL THEN highway_class(highway)
            WHEN railway IS NOT NULL THEN railway_class(railway)
        END AS class,
        -- All links are considered as ramps as well
        CASE WHEN highway_is_link(highway) OR highway = 'steps'
             THEN 1 ELSE is_ramp::int END AS ramp,
        is_oneway::int AS oneway,
        brunnel(is_bridge, is_tunnel, is_ford) AS brunnel,
        NULLIF(service, '') AS service
    FROM (
        -- etldoc: osm_transportation_merge_linestring_gen7 -> layer_transportation:z4
        SELECT
            osm_id, geometry, highway, NULL AS railway, NULL AS service,
            NULL::boolean AS is_bridge, NULL::boolean AS is_tunnel,
            NULL::boolean AS is_ford,
            NULL::boolean AS is_ramp, NULL::boolean AS is_oneway,
            z_order
        FROM osm_transportation_merge_linestring_gen7
        WHERE zoom_level = 4
        UNION ALL

        -- etldoc: osm_transportation_merge_linestring_gen6 -> layer_transportation:z5
        SELECT
            osm_id, geometry, highway, NULL AS railway, NULL AS service,
            NULL::boolean AS is_bridge, NULL::boolean AS is_tunnel,
            NULL::boolean AS is_ford,
            NULL::boolean AS is_ramp, NULL::boolean AS is_oneway,
            z_order
        FROM osm_transportation_merge_linestring_gen6
        WHERE zoom_level = 5
        UNION ALL

        -- etldoc: osm_transportation_merge_linestring_gen5 -> layer_transportation:z6
        SELECT
            osm_id, geometry, highway, NULL AS railway, NULL AS service,
            NULL::boolean AS is_bridge, NULL::boolean AS is_tunnel,
            NULL::boolean AS is_ford,
            NULL::boolean AS is_ramp, NULL::boolean AS is_oneway,
            z_order
        FROM osm_transportation_merge_linestring_gen5
        WHERE zoom_level = 6
        UNION ALL

        -- etldoc: osm_transportation_merge_linestring_gen4  ->  layer_transportation:z7
        SELECT
            osm_id, geometry, highway, NULL AS railway, NULL AS service,
            NULL::boolean AS is_bridge, NULL::boolean AS is_tunnel,
            NULL::boolean AS is_ford,
            NULL::boolean AS is_ramp, NULL::boolean AS is_oneway,
            z_order
        FROM osm_transportation_merge_linestring_gen4
        WHERE zoom_level = 7
        UNION ALL

        -- etldoc: osm_transportation_merge_linestring_gen3  ->  layer_transportation:z8
        SELECT
            osm_id, geometry, highway, NULL AS railway, NULL AS service,
            NULL::boolean AS is_bridge, NULL::boolean AS is_tunnel,
            NULL::boolean AS is_ford,
            NULL::boolean AS is_ramp, NULL::boolean AS is_oneway,
            z_order
        FROM osm_transportation_merge_linestring_gen3
        WHERE zoom_level = 8
        UNION ALL

        -- etldoc: osm_highway_linestring_gen2  ->  layer_transportation:z9
        -- etldoc: osm_highway_linestring_gen2  ->  layer_transportation:z10
        SELECT
            osm_id, geometry, highway, NULL AS railway, NULL AS service,
            NULL::boolean AS is_bridge, NULL::boolean AS is_tunnel,
            NULL::boolean AS is_ford,
            NULL::boolean AS is_ramp, NULL::boolean AS is_oneway,
            z_order
        FROM osm_highway_linestring_gen2
        WHERE zoom_level BETWEEN 9 AND 10
          AND st_length(geometry)>zres(11)
        UNION ALL

        -- etldoc: osm_highway_linestring_gen1  ->  layer_transportation:z11
        SELECT
            osm_id, geometry, highway, NULL AS railway, NULL AS service,
            NULL::boolean AS is_bridge, NULL::boolean AS is_tunnel,
            NULL::boolean AS is_ford,
            NULL::boolean AS is_ramp, NULL::boolean AS is_oneway,
            z_order
        FROM osm_highway_linestring_gen1
        WHERE zoom_level = 11
          AND st_length(geometry)>zres(12)
        UNION ALL

        -- etldoc: osm_highway_linestring       ->  layer_transportation:z12
        -- etldoc: osm_highway_linestring       ->  layer_transportation:z13
        -- etldoc: osm_highway_linestring       ->  layer_transportation:z14_
        SELECT
            osm_id, geometry, highway, NULL AS railway,
            service_value(service) AS service,
            is_bridge, is_tunnel, is_ford, is_ramp, is_oneway, z_order
        FROM osm_highway_linestring
        WHERE NOT is_area AND (
            zoom_level = 12 AND (
                highway_class(highway) NOT IN ('track', 'path', 'minor')
                OR highway IN ('unclassified', 'residential')
            )
            OR zoom_level = 13 AND highway_class(highway) NOT IN ('track', 'path')
            OR zoom_level >= 14
        )
        UNION ALL

        -- etldoc: osm_railway_linestring_gen3  ->  layer_transportation:z10
        SELECT
            osm_id, geometry, NULL AS highway, railway,
            service_value(service) AS service,
            is_bridge, is_tunnel, is_ford, is_ramp, is_oneway, z_order
        FROM osm_railway_linestring_gen3
        WHERE zoom_level = 10 AND (railway='rail' AND service = '')
        UNION ALL

        -- etldoc: osm_railway_linestring_gen2  ->  layer_transportation:z11
        SELECT
            osm_id, geometry, NULL AS highway, railway,
            service_value(service) AS service,
            is_bridge, is_tunnel, is_ford, is_ramp, is_oneway, z_order
        FROM osm_railway_linestring_gen2
        WHERE zoom_level = 11 AND (railway='rail' AND service = '')
        UNION ALL

        -- etldoc: osm_railway_linestring_gen1  ->  layer_transportation:z12
        SELECT
            osm_id, geometry, NULL AS highway, railway,
            service_value(service) AS service,
            is_bridge, is_tunnel, is_ford, is_ramp, is_oneway, z_order
        FROM osm_railway_linestring_gen1
        WHERE zoom_level = 12 AND (railway='rail' AND service = '')
        UNION ALL

        -- etldoc: osm_railway_linestring       ->  layer_transportation:z13
        -- etldoc: osm_railway_linestring       ->  layer_transportation:z14_
        SELECT
            osm_id, geometry, NULL AS highway, railway,
            service_value(service) AS service,
            is_bridge, is_tunnel, is_ford, is_ramp, is_oneway, z_order
        FROM osm_railway_linestring
        WHERE zoom_level = 13 AND (railway='rail' AND service = '')
           OR zoom_Level >= 14
        UNION ALL

        -- NOTE: We limit the selection of polys because we need to be
        -- careful to net get false positives here because
        -- it is possible that closed linestrings appear both as
        -- highway linestrings and as polygon
        -- etldoc: osm_highway_polygon          ->  layer_transportation:z13
        -- etldoc: osm_highway_polygon          ->  layer_transportation:z14_
        SELECT
            osm_id, geometry,
            highway, NULL AS railway, NULL AS service,
            FALSE AS is_bridge, FALSE AS is_tunnel, FALSE AS is_ford,
            FALSE AS is_ramp, FALSE AS is_oneway, z_order
        FROM osm_highway_polygon
        -- We do not want underground pedestrian areas for now
        WHERE zoom_level >= 13 AND is_area AND COALESCE(layer, 0) >= 0
    ) AS zoom_levels
    WHERE geometry && bbox
    ORDER BY z_order ASC;
$$ LANGUAGE SQL IMMUTABLE;
DO $$ BEGIN RAISE NOTICE 'Layer building'; END$$;-- etldoc: layer_building[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_building | <z13> z13 | <z14_> z14+ " ] ;

CREATE OR REPLACE FUNCTION as_numeric(text) RETURNS NUMERIC AS $$
 -- Inspired by http://stackoverflow.com/questions/16195986/isnumeric-with-postgresql/16206123#16206123
DECLARE test NUMERIC;
BEGIN
     test = $1::NUMERIC;
     RETURN test;
EXCEPTION WHEN others THEN
     RETURN -1;
END;
$$ STRICT
LANGUAGE plpgsql IMMUTABLE;

CREATE INDEX IF NOT EXISTS osm_building_relation_building_idx ON osm_building_relation(building);
--CREATE INDEX IF NOT EXISTS osm_building_associatedstreet_role_idx ON osm_building_associatedstreet(role);
--CREATE INDEX IF NOT EXISTS osm_building_street_role_idx ON osm_building_street(role);

CREATE OR REPLACE VIEW osm_all_buildings AS (
         -- etldoc: osm_building_relation -> layer_building:z14_
         -- Buildings built from relations
         SELECT member AS osm_id,geometry,
                  COALESCE(nullif(as_numeric(height),-1),nullif(as_numeric(buildingheight),-1)) as height,
                  COALESCE(nullif(as_numeric(min_height),-1),nullif(as_numeric(buildingmin_height),-1)) as min_height,
                  COALESCE(nullif(as_numeric(levels),-1),nullif(as_numeric(buildinglevels),-1)) as levels,
                  COALESCE(nullif(as_numeric(min_level),-1),nullif(as_numeric(buildingmin_level),-1)) as min_level
         FROM
         osm_building_relation WHERE building = ''
         UNION ALL

         -- etldoc: osm_building_associatedstreet -> layer_building:z14_
         -- Buildings in associatedstreet relations
         SELECT member AS osm_id,geometry,
                  COALESCE(nullif(as_numeric(height),-1),nullif(as_numeric(buildingheight),-1)) as height,
                  COALESCE(nullif(as_numeric(min_height),-1),nullif(as_numeric(buildingmin_height),-1)) as min_height,
                  COALESCE(nullif(as_numeric(levels),-1),nullif(as_numeric(buildinglevels),-1)) as levels,
                  COALESCE(nullif(as_numeric(min_level),-1),nullif(as_numeric(buildingmin_level),-1)) as min_level
         FROM
         osm_building_associatedstreet WHERE role = 'house'
         UNION ALL
         -- etldoc: osm_building_street -> layer_building:z14_
         -- Buildings in street relations
         SELECT member AS osm_id,geometry,
                  COALESCE(nullif(as_numeric(height),-1),nullif(as_numeric(buildingheight),-1)) as height,
                  COALESCE(nullif(as_numeric(min_height),-1),nullif(as_numeric(buildingmin_height),-1)) as min_height,
                  COALESCE(nullif(as_numeric(levels),-1),nullif(as_numeric(buildinglevels),-1)) as levels,
                  COALESCE(nullif(as_numeric(min_level),-1),nullif(as_numeric(buildingmin_level),-1)) as min_level
         FROM
         osm_building_street WHERE role = 'house'
         UNION ALL

         -- etldoc: osm_building_polygon -> layer_building:z14_
         -- Buildings that are inner/outer
         SELECT osm_id,geometry,
                  COALESCE(nullif(as_numeric(height),-1),nullif(as_numeric(buildingheight),-1)) as height,
                  COALESCE(nullif(as_numeric(min_height),-1),nullif(as_numeric(buildingmin_height),-1)) as min_height,
                  COALESCE(nullif(as_numeric(levels),-1),nullif(as_numeric(buildinglevels),-1)) as levels,
                  COALESCE(nullif(as_numeric(min_level),-1),nullif(as_numeric(buildingmin_level),-1)) as min_level
         FROM
         osm_building_polygon obp WHERE EXISTS (SELECT 1 FROM osm_building_multipolygon obm WHERE obp.osm_id = obm.osm_id)
         UNION ALL
         -- etldoc: osm_building_polygon -> layer_building:z14_
         -- Standalone buildings
         SELECT osm_id,geometry,
                  COALESCE(nullif(as_numeric(height),-1),nullif(as_numeric(buildingheight),-1)) as height,
                  COALESCE(nullif(as_numeric(min_height),-1),nullif(as_numeric(buildingmin_height),-1)) as min_height,
                  COALESCE(nullif(as_numeric(levels),-1),nullif(as_numeric(buildinglevels),-1)) as levels,
                  COALESCE(nullif(as_numeric(min_level),-1),nullif(as_numeric(buildingmin_level),-1)) as min_level
         FROM
         osm_building_polygon WHERE osm_id >= 0
);

CREATE OR REPLACE FUNCTION layer_building(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, osm_id bigint, render_height int, render_min_height int) AS $$
    SELECT geometry, osm_id, render_height, render_min_height
    FROM (
        -- etldoc: osm_building_polygon_gen1 -> layer_building:z13
        SELECT
            osm_id, geometry,
            NULL::int AS render_height, NULL::int AS render_min_height
        FROM osm_building_polygon_gen1
        WHERE zoom_level = 13 AND geometry && bbox
        UNION ALL
        -- etldoc: osm_building_polygon -> layer_building:z14_
        SELECT DISTINCT ON (osm_id)
           osm_id, geometry,
           ceil( COALESCE(height, levels*3.66,5))::int AS render_height,
           floor(COALESCE(min_height, min_level*3.66,0))::int AS render_min_height FROM
        osm_all_buildings
        WHERE zoom_level >= 14 AND geometry && bbox
    ) AS zoom_levels
    ORDER BY render_height ASC, ST_YMin(geometry) DESC;
$$ LANGUAGE SQL IMMUTABLE;

-- not handled: where a building outline covers building parts

DO $$ BEGIN RAISE NOTICE 'Layer water_name'; END$$;DROP TRIGGER IF EXISTS trigger_flag ON osm_marine_point;
DROP TRIGGER IF EXISTS trigger_refresh ON water_name_marine.updates;

CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE OR REPLACE FUNCTION update_osm_marine_point() RETURNS VOID AS $$
BEGIN
  -- etldoc: osm_marine_point          -> osm_marine_point
  UPDATE osm_marine_point AS osm SET "rank" = NULL WHERE "rank" IS NOT NULL;

  -- etldoc: ne_10m_geography_marine_polys -> osm_marine_point
  -- etldoc: osm_marine_point              -> osm_marine_point

  WITH important_marine_point AS (
      SELECT osm.geometry, osm.osm_id, osm.name, osm.name_en, ne.scalerank
      FROM ne_10m_geography_marine_polys AS ne, osm_marine_point AS osm
      WHERE ne.name ILIKE osm.name
  )
  UPDATE osm_marine_point AS osm
  SET "rank" = scalerank
  FROM important_marine_point AS ne
  WHERE osm.osm_id = ne.osm_id;

  UPDATE osm_marine_point
  SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry)
  WHERE COALESCE(tags->'name:latin', tags->'name:nonlatin', tags->'name_int') IS NULL;

END;
$$ LANGUAGE plpgsql;

SELECT update_osm_marine_point();

CREATE INDEX IF NOT EXISTS osm_marine_point_rank_idx ON osm_marine_point("rank");

-- Handle updates
CREATE SCHEMA IF NOT EXISTS water_name_marine;

CREATE TABLE IF NOT EXISTS water_name_marine.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION water_name_marine.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO water_name_marine.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION water_name_marine.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh water_name_marine rank';
    PERFORM update_osm_marine_point();
    DELETE FROM water_name_marine.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_marine_point
    FOR EACH STATEMENT
    EXECUTE PROCEDURE water_name_marine.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON water_name_marine.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE water_name_marine.refresh();
DROP TRIGGER IF EXISTS trigger_flag_line ON osm_water_polygon;
DROP TRIGGER IF EXISTS trigger_refresh ON water_lakeline.updates;

-- etldoc:  osm_water_polygon ->  osm_water_lakeline
-- etldoc:  lake_centerline  ->  osm_water_lakeline
DROP MATERIALIZED VIEW IF EXISTS osm_water_lakeline CASCADE;

CREATE MATERIALIZED VIEW osm_water_lakeline AS (
	SELECT wp.osm_id,
		ll.wkb_geometry AS geometry,
		name, name_en, name_de,
		slice_language_tags(tags) || get_basic_names(tags, ll.wkb_geometry) AS tags,
		ST_Area(wp.geometry) AS area
    FROM osm_water_polygon AS wp
    INNER JOIN lake_centerline ll ON wp.osm_id = ll.osm_id
    WHERE wp.name <> ''
);
CREATE INDEX IF NOT EXISTS osm_water_lakeline_geometry_idx ON osm_water_lakeline USING gist(geometry);

-- Handle updates

CREATE SCHEMA IF NOT EXISTS water_lakeline;

CREATE TABLE IF NOT EXISTS water_lakeline.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION water_lakeline.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO water_lakeline.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION water_lakeline.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh water_lakeline';
    REFRESH MATERIALIZED VIEW osm_water_lakeline;
    DELETE FROM water_lakeline.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag_line
    AFTER INSERT OR UPDATE OR DELETE ON osm_water_polygon
    FOR EACH STATEMENT
    EXECUTE PROCEDURE water_lakeline.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON water_lakeline.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE water_lakeline.refresh();
DROP TRIGGER IF EXISTS trigger_flag_point ON osm_water_polygon;
DROP TRIGGER IF EXISTS trigger_refresh ON water_point.updates;

-- etldoc:  osm_water_polygon ->  osm_water_point
-- etldoc:  lake_centerline ->  osm_water_point
DROP MATERIALIZED VIEW IF EXISTS  osm_water_point CASCADE;

CREATE MATERIALIZED VIEW osm_water_point AS (
    SELECT
        wp.osm_id, ST_PointOnSurface(wp.geometry) AS geometry,
        wp.name, wp.name_en, wp.name_de,
        slice_language_tags(wp.tags) || get_basic_names(wp.tags, ST_PointOnSurface(wp.geometry)) AS tags,
        ST_Area(wp.geometry) AS area
    FROM osm_water_polygon AS wp
    LEFT JOIN lake_centerline ll ON wp.osm_id = ll.osm_id
    WHERE ll.osm_id IS NULL AND wp.name <> ''
);
CREATE INDEX IF NOT EXISTS osm_water_point_geometry_idx ON osm_water_point USING gist (geometry);

-- Handle updates

CREATE SCHEMA IF NOT EXISTS water_point;

CREATE TABLE IF NOT EXISTS water_point.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION water_point.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO water_point.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION water_point.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh water_point';
    REFRESH MATERIALIZED VIEW osm_water_point;
    DELETE FROM water_point.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag_point
    AFTER INSERT OR UPDATE OR DELETE ON osm_water_polygon
    FOR EACH STATEMENT
    EXECUTE PROCEDURE water_point.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON water_point.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE water_point.refresh();

DO $$ BEGIN RAISE NOTICE 'Layer transportation_name'; END$$;DROP MATERIALIZED VIEW IF EXISTS osm_transportation_name_network CASCADE;
DROP MATERIALIZED VIEW IF EXISTS osm_transportation_name_linestring CASCADE;
DROP MATERIALIZED VIEW IF EXISTS osm_transportation_name_linestring_gen1 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS osm_transportation_name_linestring_gen2 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS osm_transportation_name_linestring_gen3 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS osm_transportation_name_linestring_gen4 CASCADE;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'route_network_type') THEN
        CREATE TYPE route_network_type AS ENUM (
          'us-interstate', 'us-highway', 'us-state',
          'ca-transcanada',
          'gb-motorway', 'gb-trunk'
        );
    END IF;
END
$$
;

DO $$
    BEGIN
        BEGIN
            ALTER TABLE osm_route_member ADD COLUMN network_type route_network_type;
        EXCEPTION
            WHEN duplicate_column THEN RAISE NOTICE 'column network_type already exists in network_type.';
        END;
    END;
$$
;
DROP TRIGGER IF EXISTS trigger_flag_transportation_name ON osm_route_member;


-- create GBR relations (so we can use it in the same way as other relations)
CREATE OR REPLACE FUNCTION update_gbr_route_members() RETURNS VOID AS $$
DECLARE gbr_geom geometry;
BEGIN
  select st_buffer(geometry, 10000) into gbr_geom from ne_10m_admin_0_countries where iso_a2 = 'GB';
  delete from osm_route_member where network IN('omt-gb-motorway', 'omt-gb-trunk');

  insert into osm_route_member (member, ref, network)
    (
      SELECT hw.osm_id, substring(hw.ref from E'^[AM][0-9AM()]+'), 'omt-gb-motorway'
      from osm_highway_linestring hw
      where length(hw.ref)>0 and ST_Intersects(hw.geometry, gbr_geom)
        and hw.highway IN ('motorway')
    ) UNION (
      SELECT hw.osm_id, substring(hw.ref from E'^[AM][0-9AM()]+'), 'omt-gb-trunk'
      from osm_highway_linestring hw
      where length(hw.ref)>0 and ST_Intersects(hw.geometry, gbr_geom)
        and hw.highway IN ('trunk')
    )
  ;
END;
$$ LANGUAGE plpgsql;


-- etldoc:  osm_route_member ->  osm_route_member
CREATE OR REPLACE FUNCTION update_osm_route_member() RETURNS VOID AS $$
BEGIN
  PERFORM update_gbr_route_members();

  -- see http://wiki.openstreetmap.org/wiki/Relation:route#Road_routes
  UPDATE osm_route_member
  SET network_type =
      CASE
        WHEN network = 'US:I' THEN 'us-interstate'::route_network_type
        WHEN network = 'US:US' THEN 'us-highway'::route_network_type
        WHEN network LIKE 'US:__' THEN 'us-state'::route_network_type
        -- https://en.wikipedia.org/wiki/Trans-Canada_Highway
        -- TODO: improve hierarchical queries using
        --    http://www.openstreetmap.org/relation/1307243
        --    however the relation does not cover the whole Trans-Canada_Highway
        WHEN
            (network = 'CA:transcanada') OR
            (network = 'CA:BC:primary' AND ref IN ('16')) OR
            (name = 'Yellowhead Highway (AB)' AND ref IN ('16')) OR
            (network = 'CA:SK' AND ref IN ('16')) OR
            (network = 'CA:ON:primary' AND ref IN ('17', '417')) OR
            (name = 'Route Transcanadienne (QC)') OR
            (network = 'CA:NB' AND ref IN ('2', '16')) OR
            (network = 'CA:PEI' AND ref IN ('1')) OR
            (network = 'CA:NS' AND ref IN ('104', '105')) OR
            (network = 'CA:NL:R' AND ref IN ('1')) OR
            (name = '	Trans-Canada Highway (Super)')
          THEN 'ca-transcanada'::route_network_type
        WHEN network = 'omt-gb-motorway' THEN 'gb-motorway'::route_network_type
        WHEN network = 'omt-gb-trunk' THEN 'gb-trunk'::route_network_type
        ELSE NULL
      END
  ;

END;
$$ LANGUAGE plpgsql;

CREATE INDEX IF NOT EXISTS osm_route_member_network_idx ON osm_route_member("network");
CREATE INDEX IF NOT EXISTS osm_route_member_member_idx ON osm_route_member("member");
CREATE INDEX IF NOT EXISTS osm_route_member_name_idx ON osm_route_member("name");
CREATE INDEX IF NOT EXISTS osm_route_member_ref_idx ON osm_route_member("ref");

SELECT update_osm_route_member();

CREATE INDEX IF NOT EXISTS osm_route_member_network_type_idx ON osm_route_member("network_type");
DROP TRIGGER IF EXISTS trigger_flag_transportation_name ON osm_highway_linestring;
DROP TRIGGER IF EXISTS trigger_refresh ON transportation_name.updates;

-- Instead of using relations to find out the road names we
-- stitch together the touching ways with the same name
-- to allow for nice label rendering
-- Because this works well for roads that do not have relations as well


-- etldoc: osm_highway_linestring ->  osm_transportation_name_network
-- etldoc: osm_route_member ->  osm_transportation_name_network
CREATE MATERIALIZED VIEW osm_transportation_name_network AS (
  SELECT
      hl.geometry,
      hl.osm_id,
      CASE WHEN length(hl.name)>15 THEN osml10n_street_abbrev_all(hl.name) ELSE hl.name END AS "name",
      CASE WHEN length(hl.name_en)>15 THEN osml10n_street_abbrev_en(hl.name_en) ELSE hl.name_en END AS "name_en",
      CASE WHEN length(hl.name_de)>15 THEN osml10n_street_abbrev_de(hl.name_de) ELSE hl.name_de END AS "name_de",
      rm.network_type,
      CASE
        WHEN (rm.network_type is not null AND nullif(rm.ref::text, '') is not null)
          then rm.ref::text
        else hl.ref
      end as ref,
      hl.highway,
      ROW_NUMBER() OVER(PARTITION BY hl.osm_id
                                   ORDER BY rm.network_type) AS "rank",
      hl.z_order
  FROM osm_highway_linestring hl
  left join osm_route_member rm on (rm.member = hl.osm_id)
);
CREATE INDEX IF NOT EXISTS osm_transportation_name_network_geometry_idx ON osm_transportation_name_network USING gist(geometry);


-- etldoc: osm_transportation_name_network ->  osm_transportation_name_linestring
CREATE MATERIALIZED VIEW osm_transportation_name_linestring AS (
    SELECT
        (ST_Dump(geometry)).geom AS geometry,
        NULL::bigint AS osm_id,
        name,
        name_en,
        name_de,
        get_basic_names(delete_empty_keys(hstore(ARRAY['name',name,'name:en',name_en,'name:de',name_de])), geometry)
            || delete_empty_keys(hstore(ARRAY['name',name,'name:en',name_en,'name:de',name_de]))
            AS "tags",
        ref,
        highway,
        network_type AS network,
        z_order
    FROM (
      SELECT
          ST_LineMerge(ST_Collect(geometry)) AS geometry,
          name,
          name_en,
          name_de,
          ref,
          highway,
          network_type,
          min(z_order) AS z_order
      FROM osm_transportation_name_network
      WHERE ("rank"=1 OR "rank" is null)
        AND (name <> '' OR ref <> '')
        AND NULLIF(highway, '') IS NOT NULL
      group by name, name_en, name_de, ref, highway, network_type
    ) AS highway_union
);
CREATE INDEX IF NOT EXISTS osm_transportation_name_linestring_geometry_idx ON osm_transportation_name_linestring USING gist(geometry);

CREATE INDEX IF NOT EXISTS osm_transportation_name_linestring_highway_partial_idx
  ON osm_transportation_name_linestring(highway)
  WHERE highway IN ('motorway','trunk');

-- etldoc: osm_transportation_name_linestring -> osm_transportation_name_linestring_gen1
CREATE MATERIALIZED VIEW osm_transportation_name_linestring_gen1 AS (
    SELECT ST_Simplify(geometry, 50) AS geometry, osm_id, name, name_en, name_de, tags, ref, highway, network, z_order
    FROM osm_transportation_name_linestring
    WHERE highway IN ('motorway','trunk')  AND ST_Length(geometry) > 8000
);
CREATE INDEX IF NOT EXISTS osm_transportation_name_linestring_gen1_geometry_idx ON osm_transportation_name_linestring_gen1 USING gist(geometry);

CREATE INDEX IF NOT EXISTS osm_transportation_name_linestring_gen1_highway_partial_idx
  ON osm_transportation_name_linestring_gen1(highway)
  WHERE highway IN ('motorway','trunk');

-- etldoc: osm_transportation_name_linestring_gen1 -> osm_transportation_name_linestring_gen2
CREATE MATERIALIZED VIEW osm_transportation_name_linestring_gen2 AS (
    SELECT ST_Simplify(geometry, 120) AS geometry, osm_id, name, name_en, name_de, tags, ref, highway, network, z_order
    FROM osm_transportation_name_linestring_gen1
    WHERE highway IN ('motorway','trunk')  AND ST_Length(geometry) > 14000
);
CREATE INDEX IF NOT EXISTS osm_transportation_name_linestring_gen2_geometry_idx ON osm_transportation_name_linestring_gen2 USING gist(geometry);

CREATE INDEX IF NOT EXISTS osm_transportation_name_linestring_gen2_highway_partial_idx
  ON osm_transportation_name_linestring_gen2(highway)
  WHERE highway = 'motorway';

-- etldoc: osm_transportation_name_linestring_gen2 -> osm_transportation_name_linestring_gen3
CREATE MATERIALIZED VIEW osm_transportation_name_linestring_gen3 AS (
    SELECT ST_Simplify(geometry, 200) AS geometry, osm_id, name, name_en, name_de, tags, ref, highway, network, z_order
    FROM osm_transportation_name_linestring_gen2
    WHERE highway = 'motorway' AND ST_Length(geometry) > 20000
);
CREATE INDEX IF NOT EXISTS osm_transportation_name_linestring_gen3_geometry_idx ON osm_transportation_name_linestring_gen3 USING gist(geometry);

CREATE INDEX IF NOT EXISTS osm_transportation_name_linestring_gen3_highway_partial_idx
  ON osm_transportation_name_linestring_gen3(highway)
  WHERE highway = 'motorway';

-- etldoc: osm_transportation_name_linestring_gen3 -> osm_transportation_name_linestring_gen4
CREATE MATERIALIZED VIEW osm_transportation_name_linestring_gen4 AS (
    SELECT ST_Simplify(geometry, 500) AS geometry, osm_id, name, name_en, name_de, tags, ref, highway, network, z_order
    FROM osm_transportation_name_linestring_gen3
    WHERE highway = 'motorway' AND ST_Length(geometry) > 20000
);
CREATE INDEX IF NOT EXISTS osm_transportation_name_linestring_gen4_geometry_idx ON osm_transportation_name_linestring_gen4 USING gist(geometry);

-- Handle updates

CREATE SCHEMA IF NOT EXISTS transportation_name;

CREATE TABLE IF NOT EXISTS transportation_name.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION transportation_name.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO transportation_name.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION transportation_name.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh transportation_name';
    PERFORM update_osm_route_member();
    REFRESH MATERIALIZED VIEW osm_transportation_name_network;
    REFRESH MATERIALIZED VIEW osm_transportation_name_linestring;
    REFRESH MATERIALIZED VIEW osm_transportation_name_linestring_gen1;
    REFRESH MATERIALIZED VIEW osm_transportation_name_linestring_gen2;
    REFRESH MATERIALIZED VIEW osm_transportation_name_linestring_gen3;
    REFRESH MATERIALIZED VIEW osm_transportation_name_linestring_gen4;
    DELETE FROM transportation_name.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag_transportation_name
    AFTER INSERT OR UPDATE OR DELETE ON osm_route_member
    FOR EACH STATEMENT
    EXECUTE PROCEDURE transportation_name.flag();

CREATE TRIGGER trigger_flag_transportation_name
    AFTER INSERT OR UPDATE OR DELETE ON osm_highway_linestring
    FOR EACH STATEMENT
    EXECUTE PROCEDURE transportation_name.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON transportation_name.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE transportation_name.refresh();

-- etldoc: layer_transportation_name[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_transportation_name | <z6> z6 | <z7> z7 | <z8> z8 |<z9> z9 |<z10> z10 |<z11> z11 |<z12> z12|<z13> z13|<z14_> z14+" ] ;

CREATE OR REPLACE FUNCTION layer_transportation_name(bbox geometry, zoom_level integer)
RETURNS TABLE(osm_id bigint, geometry geometry, name text, name_en text, name_de text, tags hstore, ref text, ref_length int, network text, class text) AS $$
    SELECT osm_id, geometry,
      NULLIF(name, '') AS name,
      COALESCE(NULLIF(name_en, ''), name) AS name_en,
      COALESCE(NULLIF(name_de, ''), name, name_en) AS name_de,
      tags,
      NULLIF(ref, ''), NULLIF(LENGTH(ref), 0) AS ref_length,
      --TODO: The road network of the road is not yet implemented
      case
        when network is not null
          then network::text
        when length(coalesce(ref, ''))>0
          then 'road'
      end as network,
      highway_class(highway) AS class
    FROM (

        -- etldoc: osm_transportation_name_linestring_gen4 ->  layer_transportation_name:z6
        SELECT * FROM osm_transportation_name_linestring_gen4
        WHERE zoom_level = 6
        UNION ALL

        -- etldoc: osm_transportation_name_linestring_gen3 ->  layer_transportation_name:z7
        SELECT * FROM osm_transportation_name_linestring_gen3
        WHERE zoom_level = 7
        UNION ALL

        -- etldoc: osm_transportation_name_linestring_gen2 ->  layer_transportation_name:z8
        SELECT * FROM osm_transportation_name_linestring_gen2
        WHERE zoom_level = 8
        UNION ALL

        -- etldoc: osm_transportation_name_linestring_gen1 ->  layer_transportation_name:z9
        -- etldoc: osm_transportation_name_linestring_gen1 ->  layer_transportation_name:z10
        -- etldoc: osm_transportation_name_linestring_gen1 ->  layer_transportation_name:z11
        SELECT * FROM osm_transportation_name_linestring_gen1
        WHERE zoom_level BETWEEN 9 AND 11
        UNION ALL

        -- etldoc: osm_transportation_name_linestring ->  layer_transportation_name:z12
        SELECT * FROM osm_transportation_name_linestring
        WHERE zoom_level = 12
            AND LineLabel(zoom_level, COALESCE(NULLIF(name, ''), ref), geometry)
            AND highway_class(highway) NOT IN ('minor', 'track', 'path')
            AND NOT highway_is_link(highway)
        UNION ALL

        -- etldoc: osm_transportation_name_linestring ->  layer_transportation_name:z13
        SELECT * FROM osm_transportation_name_linestring
        WHERE zoom_level = 13
            AND LineLabel(zoom_level, COALESCE(NULLIF(name, ''), ref), geometry)
            AND highway_class(highway) NOT IN ('track', 'path')
        UNION ALL

        -- etldoc: osm_transportation_name_linestring ->  layer_transportation_name:z14_
        SELECT * FROM osm_transportation_name_linestring
        WHERE zoom_level >= 14

    ) AS zoom_levels
    WHERE geometry && bbox
    ORDER BY z_order ASC;
$$ LANGUAGE SQL IMMUTABLE;
DO $$ BEGIN RAISE NOTICE 'Layer place'; END$$;DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'city_place') THEN
        CREATE TYPE city_place AS ENUM ('city', 'town', 'village', 'hamlet', 'suburb', 'neighbourhood', 'isolated_dwelling');
    END IF;
END
$$;

ALTER TABLE osm_city_point ALTER COLUMN place TYPE city_place USING place::city_place;
CREATE OR REPLACE FUNCTION normalize_capital_level(capital TEXT)
RETURNS INT AS $$
    SELECT CASE
        WHEN capital IN ('yes', '2') THEN 2
        WHEN capital = '4' THEN 4
        ELSE NULL
    END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- etldoc: layer_city[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_city | <z2_14> z2-z14+" ] ;

-- etldoc: osm_city_point -> layer_city:z2_14
CREATE OR REPLACE FUNCTION layer_city(bbox geometry, zoom_level int, pixel_width numeric)
RETURNS TABLE(osm_id bigint, geometry geometry, name text, name_en text, name_de text, tags hstore, place city_place, "rank" int, capital int) AS $$
    SELECT osm_id, geometry, name,
    COALESCE(NULLIF(name_en, ''), name) AS name_en,
    COALESCE(NULLIF(name_de, ''), name, name_en) AS name_de,
    tags,
    place, "rank", normalize_capital_level(capital) AS capital
    FROM osm_city_point
    WHERE geometry && bbox
      AND ((zoom_level = 2 AND "rank" = 1)
        OR (zoom_level BETWEEN 3 AND 7 AND "rank" <= zoom_level + 1)
      )
    UNION ALL
    SELECT osm_id, geometry, name,
        COALESCE(NULLIF(name_en, ''), name) AS name_en,
        COALESCE(NULLIF(name_de, ''), name, name_en) AS name_de,
        tags,
        place,
        COALESCE("rank", gridrank + 10),
        normalize_capital_level(capital) AS capital
    FROM (
      SELECT osm_id, geometry, name,
      COALESCE(NULLIF(name_en, ''), name) AS name_en,
      COALESCE(NULLIF(name_de, ''), name, name_en) AS name_de,
      tags,
      place, "rank", capital,
      row_number() OVER (
        PARTITION BY LabelGrid(geometry, 128 * pixel_width)
        ORDER BY "rank" ASC NULLS LAST,
        place ASC NULLS LAST,
        population DESC NULLS LAST,
        length(name) ASC
      )::int AS gridrank
        FROM osm_city_point
        WHERE geometry && bbox
          AND ((zoom_level = 7 AND place <= 'town'::city_place
            OR (zoom_level BETWEEN 8 AND 10 AND place <= 'village'::city_place)

            OR (zoom_level BETWEEN 11 AND 13 AND place <= 'suburb'::city_place)
            OR (zoom_level >= 14)
          ))
    ) AS ranked_places
    WHERE (zoom_level BETWEEN 7 AND 8 AND (gridrank <= 4 OR "rank" IS NOT NULL))
       OR (zoom_level = 9 AND (gridrank <= 8 OR "rank" IS NOT NULL))
       OR (zoom_level = 10 AND (gridrank <= 12 OR "rank" IS NOT NULL))
       OR (zoom_level BETWEEN 11 AND 12 AND (gridrank <= 14 OR "rank" IS NOT NULL))
       OR (zoom_level >= 13);
$$ LANGUAGE SQL IMMUTABLE;
CREATE OR REPLACE FUNCTION island_rank(area REAL) RETURNS INT AS $$
    SELECT CASE
        WHEN area < 10000000 THEN 6
        WHEN area BETWEEN  1000000 AND 15000000 THEN 5
        WHEN area BETWEEN 15000000 AND 40000000 THEN 4
        WHEN area > 40000000 THEN 3
        ELSE 7
    END;
$$ LANGUAGE SQL IMMUTABLE STRICT;
DROP TRIGGER IF EXISTS trigger_flag ON osm_continent_point;
DROP TRIGGER IF EXISTS trigger_refresh ON place_continent_point.updates;

-- etldoc:  osm_continent_point ->  osm_continent_point
CREATE OR REPLACE FUNCTION update_osm_continent_point() RETURNS VOID AS $$
BEGIN
  UPDATE osm_continent_point
  SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry)
  WHERE COALESCE(tags->'name:latin', tags->'name:nonlatin', tags->'name_int') IS NULL;

END;
$$ LANGUAGE plpgsql;

SELECT update_osm_continent_point();

-- Handle updates

CREATE SCHEMA IF NOT EXISTS place_continent_point;

CREATE TABLE IF NOT EXISTS place_continent_point.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION place_continent_point.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO place_continent_point.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION place_continent_point.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh place_continent_point';
    PERFORM update_osm_continent_point();
    DELETE FROM place_continent_point.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_continent_point
    FOR EACH STATEMENT
    EXECUTE PROCEDURE place_continent_point.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON place_continent_point.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE place_continent_point.refresh();
DROP TRIGGER IF EXISTS trigger_flag ON osm_country_point;
DROP TRIGGER IF EXISTS trigger_refresh ON place_country.updates;

ALTER TABLE osm_country_point DROP CONSTRAINT IF EXISTS osm_country_point_rank_constraint;

-- etldoc: ne_10m_admin_0_countries   -> osm_country_point
-- etldoc: osm_country_point          -> osm_country_point

CREATE OR REPLACE FUNCTION update_osm_country_point() RETURNS VOID AS $$
BEGIN

  WITH important_country_point AS (
      SELECT osm.geometry, osm.osm_id, osm.name, COALESCE(NULLIF(osm.name_en, ''), ne.name) AS name_en, ne.scalerank, ne.labelrank
      FROM ne_10m_admin_0_countries AS ne, osm_country_point AS osm
      WHERE
      -- We only match whether the point is within the Natural Earth polygon
      -- because name matching is to difficult since OSM does not contain good
      -- enough coverage of ISO codesy
      ST_Within(osm.geometry, ne.geometry)
      -- We leave out tiny countries
      AND ne.scalerank <= 1
  )
  UPDATE osm_country_point AS osm
  -- Normalize both scalerank and labelrank into a ranking system from 1 to 6
  -- where the ranks are still distributed uniform enough across all countries
  SET "rank" = LEAST(6, CEILING((scalerank + labelrank)/2.0))
  FROM important_country_point AS ne
  WHERE osm.osm_id = ne.osm_id;

  UPDATE osm_country_point AS osm
  SET "rank" = 6
  WHERE "rank" IS NULL;

  -- TODO: This shouldn't be necessary? The rank function makes something wrong...
  UPDATE osm_country_point AS osm
  SET "rank" = 1
  WHERE "rank" = 0;

  UPDATE osm_country_point
  SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry)
  WHERE COALESCE(tags->'name:latin', tags->'name:nonlatin', tags->'name_int') IS NULL;

END;
$$ LANGUAGE plpgsql;

SELECT update_osm_country_point();

-- ALTER TABLE osm_country_point ADD CONSTRAINT osm_country_point_rank_constraint CHECK("rank" BETWEEN 1 AND 6);
CREATE INDEX IF NOT EXISTS osm_country_point_rank_idx ON osm_country_point("rank");

-- Handle updates

CREATE SCHEMA IF NOT EXISTS place_country;

CREATE TABLE IF NOT EXISTS place_country.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION place_country.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO place_country.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION place_country.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh place_country rank';
    PERFORM update_osm_country_point();
    DELETE FROM place_country.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_country_point
    FOR EACH STATEMENT
    EXECUTE PROCEDURE place_country.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON place_country.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE place_country.refresh();
DROP TRIGGER IF EXISTS trigger_flag ON osm_island_polygon;
DROP TRIGGER IF EXISTS trigger_refresh ON place_island_polygon.updates;

-- etldoc:  osm_island_polygon ->  osm_island_polygon
CREATE OR REPLACE FUNCTION update_osm_island_polygon() RETURNS VOID AS $$
BEGIN
  UPDATE osm_island_polygon  SET geometry=ST_PointOnSurface(geometry) WHERE ST_GeometryType(geometry) <> 'ST_Point';

  UPDATE osm_island_polygon
  SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry)
  WHERE COALESCE(tags->'name:latin', tags->'name:nonlatin', tags->'name_int') IS NULL;

  ANALYZE osm_island_polygon;
END;
$$ LANGUAGE plpgsql;

SELECT update_osm_island_polygon();

-- Handle updates

CREATE SCHEMA IF NOT EXISTS place_island_polygon;

CREATE TABLE IF NOT EXISTS place_island_polygon.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION place_island_polygon.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO place_island_polygon.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION place_island_polygon.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh place_island_polygon';
    PERFORM update_osm_island_polygon();
    DELETE FROM place_island_polygon.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_island_polygon
    FOR EACH STATEMENT
    EXECUTE PROCEDURE place_island_polygon.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON place_island_polygon.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE place_island_polygon.refresh();
DROP TRIGGER IF EXISTS trigger_flag ON osm_island_point;
DROP TRIGGER IF EXISTS trigger_refresh ON place_island_point.updates;

-- etldoc:  osm_island_point ->  osm_island_point
CREATE OR REPLACE FUNCTION update_osm_island_point() RETURNS VOID AS $$
BEGIN
  UPDATE osm_island_point
  SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry)
  WHERE COALESCE(tags->'name:latin', tags->'name:nonlatin', tags->'name_int') IS NULL;

END;
$$ LANGUAGE plpgsql;

SELECT update_osm_island_point();

-- Handle updates

CREATE SCHEMA IF NOT EXISTS place_island_point;

CREATE TABLE IF NOT EXISTS place_island_point.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION place_island_point.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO place_island_point.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION place_island_point.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh place_island_point';
    PERFORM update_osm_island_point();
    DELETE FROM place_island_point.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_island_point
    FOR EACH STATEMENT
    EXECUTE PROCEDURE place_island_point.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON place_island_point.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE place_island_point.refresh();
DROP TRIGGER IF EXISTS trigger_flag ON osm_state_point;
DROP TRIGGER IF EXISTS trigger_refresh ON place_state.updates;

ALTER TABLE osm_state_point DROP CONSTRAINT IF EXISTS osm_state_point_rank_constraint;

-- etldoc: ne_10m_admin_1_states_provinces_shp   -> osm_state_point
-- etldoc: osm_state_point                       -> osm_state_point

CREATE OR REPLACE FUNCTION update_osm_state_point() RETURNS VOID AS $$
BEGIN

  WITH important_state_point AS (
      SELECT osm.geometry, osm.osm_id, osm.name, COALESCE(NULLIF(osm.name_en, ''), ne.name) AS name_en, ne.scalerank, ne.labelrank, ne.datarank
      FROM ne_10m_admin_1_states_provinces_shp AS ne, osm_state_point AS osm
      WHERE
      -- We only match whether the point is within the Natural Earth polygon
      -- because name matching is difficult
      ST_Within(osm.geometry, ne.geometry)
      -- We leave out leess important states
      AND ne.scalerank <= 3 AND ne.labelrank <= 2
  )
  UPDATE osm_state_point AS osm
  -- Normalize both scalerank and labelrank into a ranking system from 1 to 6.
  SET "rank" = LEAST(6, CEILING((scalerank + labelrank + datarank)/3.0))
  FROM important_state_point AS ne
  WHERE osm.osm_id = ne.osm_id;

  -- TODO: This shouldn't be necessary? The rank function makes something wrong...
  UPDATE osm_state_point AS osm
  SET "rank" = 1
  WHERE "rank" = 0;

  DELETE FROM osm_state_point WHERE "rank" IS NULL;

  UPDATE osm_state_point
  SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry)
  WHERE COALESCE(tags->'name:latin', tags->'name:nonlatin', tags->'name_int') IS NULL;

END;
$$ LANGUAGE plpgsql;

SELECT update_osm_state_point();

-- ALTER TABLE osm_state_point ADD CONSTRAINT osm_state_point_rank_constraint CHECK("rank" BETWEEN 1 AND 6);
CREATE INDEX IF NOT EXISTS osm_state_point_rank_idx ON osm_state_point("rank");

-- Handle updates

CREATE SCHEMA IF NOT EXISTS place_state;

CREATE TABLE IF NOT EXISTS place_state.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION place_state.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO place_state.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION place_state.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh place_state rank';
    PERFORM update_osm_state_point();
    DELETE FROM place_state.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_state_point
    FOR EACH STATEMENT
    EXECUTE PROCEDURE place_state.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON place_state.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE place_state.refresh();
DROP TRIGGER IF EXISTS trigger_flag ON osm_city_point;
DROP TRIGGER IF EXISTS trigger_refresh ON place_city.updates;

CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE OR REPLACE FUNCTION update_osm_city_point() RETURNS VOID AS $$
BEGIN

  -- Clear  OSM key:rank ( https://github.com/openmaptiles/openmaptiles/issues/108 )
  -- etldoc: osm_city_point          -> osm_city_point
  UPDATE osm_city_point AS osm  SET "rank" = NULL WHERE "rank" IS NOT NULL;

  -- etldoc: ne_10m_populated_places -> osm_city_point
  -- etldoc: osm_city_point          -> osm_city_point

  WITH important_city_point AS (
      SELECT osm.geometry, osm.osm_id, osm.name, osm.name_en, ne.scalerank, ne.labelrank
      FROM ne_10m_populated_places AS ne, osm_city_point AS osm
      WHERE
      (
          ne.name ILIKE osm.name OR
          ne.name ILIKE osm.name_en OR
          ne.namealt ILIKE osm.name OR
          ne.namealt ILIKE osm.name_en OR
          ne.meganame ILIKE osm.name OR
          ne.meganame ILIKE osm.name_en OR
          ne.gn_ascii ILIKE osm.name OR
          ne.gn_ascii ILIKE osm.name_en OR
          ne.nameascii ILIKE osm.name OR
          ne.nameascii ILIKE osm.name_en OR
          ne.name = unaccent(osm.name)
      )
      AND osm.place IN ('city', 'town', 'village')
      AND ST_DWithin(ne.geometry, osm.geometry, 50000)
  )
  UPDATE osm_city_point AS osm
  -- Move scalerank to range 1 to 10 and merge scalerank 5 with 6 since not enough cities
  -- are in the scalerank 5 bucket
  SET "rank" = CASE WHEN scalerank <= 5 THEN scalerank + 1 ELSE scalerank END
  FROM important_city_point AS ne
  WHERE osm.osm_id = ne.osm_id;

  UPDATE osm_city_point
  SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry)
  WHERE COALESCE(tags->'name:latin', tags->'name:nonlatin', tags->'name_int') IS NULL;

END;
$$ LANGUAGE plpgsql;

SELECT update_osm_city_point();

CREATE INDEX IF NOT EXISTS osm_city_point_rank_idx ON osm_city_point("rank");

-- Handle updates

CREATE SCHEMA IF NOT EXISTS place_city;

CREATE TABLE IF NOT EXISTS place_city.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION place_city.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO place_city.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION place_city.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh place_city rank';
    PERFORM update_osm_city_point();
    DELETE FROM place_city.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_city_point
    FOR EACH STATEMENT
    EXECUTE PROCEDURE place_city.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON place_city.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE place_city.refresh();

-- etldoc: layer_place[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_place | <z0_3> z0-3|<z4_7> z4-7|<z8_11> z8-11| <z12_14> z12-z14+" ] ;

CREATE OR REPLACE FUNCTION layer_place(bbox geometry, zoom_level int, pixel_width numeric)
RETURNS TABLE(osm_id bigint, geometry geometry, name text, name_en text, name_de text, tags hstore, class text, "rank" int, capital INT) AS $$

    -- etldoc: osm_continent_point -> layer_place:z0_3
    SELECT
        osm_id, geometry, name,
        COALESCE(NULLIF(name_en, ''), name) AS name_en,
        COALESCE(NULLIF(name_de, ''), name, name_en) AS name_de,
        tags,
        'continent' AS class, 1 AS "rank", NULL::int AS capital
    FROM osm_continent_point
    WHERE geometry && bbox AND zoom_level < 4
    UNION ALL

    -- etldoc: osm_country_point -> layer_place:z0_3
    -- etldoc: osm_country_point -> layer_place:z4_7
    -- etldoc: osm_country_point -> layer_place:z8_11
    -- etldoc: osm_country_point -> layer_place:z12_14
    SELECT
        osm_id, geometry, name,
        COALESCE(NULLIF(name_en, ''), name) AS name_en,
        COALESCE(NULLIF(name_de, ''), name, name_en) AS name_de,
        tags,
        'country' AS class, "rank", NULL::int AS capital
    FROM osm_country_point
    WHERE geometry && bbox AND "rank" <= zoom_level + 1 AND name <> ''
    UNION ALL

    -- etldoc: osm_state_point  -> layer_place:z0_3
    -- etldoc: osm_state_point  -> layer_place:z4_7
    -- etldoc: osm_state_point  -> layer_place:z8_11
    -- etldoc: osm_state_point  -> layer_place:z12_14
    SELECT
        osm_id, geometry, name,
        COALESCE(NULLIF(name_en, ''), name) AS name_en,
        COALESCE(NULLIF(name_de, ''), name, name_en) AS name_de,
        tags,
        'state' AS class, "rank", NULL::int AS capital
    FROM osm_state_point
    WHERE geometry && bbox AND
          name <> '' AND
          ("rank" + 2 <= zoom_level) AND (
              zoom_level >= 5 OR
              is_in_country IN ('United Kingdom', 'USA', 'Россия', 'Brasil', 'China', 'India') OR
              is_in_country_code IN ('AU', 'CN', 'IN', 'BR', 'US'))
    UNION ALL

    -- etldoc: osm_island_point    -> layer_place:z12_14
    SELECT
        osm_id, geometry, name,
        COALESCE(NULLIF(name_en, ''), name) AS name_en,
        COALESCE(NULLIF(name_de, ''), name, name_en) AS name_de,
        tags,
        'island' AS class, 7 AS "rank", NULL::int AS capital
    FROM osm_island_point
    WHERE zoom_level >= 12
        AND geometry && bbox
    UNION ALL

    -- etldoc: osm_island_polygon  -> layer_place:z8_11
    -- etldoc: osm_island_polygon  -> layer_place:z12_14
    SELECT
        osm_id, geometry, name,
        COALESCE(NULLIF(name_en, ''), name) AS name_en,
        COALESCE(NULLIF(name_de, ''), name, name_en) AS name_de,
        tags,
        'island' AS class, island_rank(area) AS "rank", NULL::int AS capital
    FROM osm_island_polygon
    WHERE geometry && bbox AND
        ((zoom_level = 8 AND island_rank(area) <= 3)
        OR (zoom_level = 9 AND island_rank(area) <= 4)
        OR (zoom_level >= 10))
    UNION ALL

    -- etldoc: layer_city          -> layer_place:z0_3
    -- etldoc: layer_city          -> layer_place:z4_7
    -- etldoc: layer_city          -> layer_place:z8_11
    -- etldoc: layer_city          -> layer_place:z12_14
    SELECT
        osm_id, geometry, name, name_en, name_de,
        tags,
        place::text AS class, "rank", capital
    FROM layer_city(bbox, zoom_level, pixel_width)
    ORDER BY "rank" ASC
$$ LANGUAGE SQL IMMUTABLE;
DO $$ BEGIN RAISE NOTICE 'Layer housenumber'; END$$;DROP TRIGGER IF EXISTS trigger_flag ON osm_housenumber_point;
DROP TRIGGER IF EXISTS trigger_refresh ON housenumber.updates;

-- etldoc: osm_housenumber_point -> osm_housenumber_point
CREATE OR REPLACE FUNCTION convert_housenumber_point() RETURNS VOID AS $$
BEGIN
  UPDATE osm_housenumber_point
  SET geometry =
           CASE WHEN ST_NPoints(ST_ConvexHull(geometry))=ST_NPoints(geometry)
           THEN ST_Centroid(geometry)
           ELSE ST_PointOnSurface(geometry)
    END
  WHERE ST_GeometryType(geometry) <> 'ST_Point';
END;
$$ LANGUAGE plpgsql;

SELECT convert_housenumber_point();

-- Handle updates

CREATE SCHEMA IF NOT EXISTS housenumber;

CREATE TABLE IF NOT EXISTS housenumber.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION housenumber.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO housenumber.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION housenumber.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh housenumber';
    PERFORM convert_housenumber_point();
    DELETE FROM housenumber.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_housenumber_point
    FOR EACH STATEMENT
    EXECUTE PROCEDURE housenumber.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON housenumber.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE housenumber.refresh();

-- etldoc: layer_housenumber[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_housenumber | <z15_> z15+" ] ;

CREATE OR REPLACE FUNCTION layer_housenumber(bbox geometry, zoom_level integer)
RETURNS TABLE(osm_id bigint, geometry geometry, housenumber text) AS $$
   -- etldoc: osm_housenumber_point -> layer_housenumber:z15_
    SELECT osm_id, geometry, housenumber FROM osm_housenumber_point
    WHERE zoom_level >= 15 AND geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;
DO $$ BEGIN RAISE NOTICE 'Layer poi'; END$$;DROP TRIGGER IF EXISTS trigger_flag ON osm_poi_polygon;
DROP TRIGGER IF EXISTS trigger_refresh ON poi_polygon.updates;

-- etldoc:  osm_poi_polygon ->  osm_poi_polygon

CREATE OR REPLACE FUNCTION update_poi_polygon() RETURNS VOID AS $$
BEGIN
  UPDATE osm_poi_polygon
  SET geometry =
           CASE WHEN ST_NPoints(ST_ConvexHull(geometry))=ST_NPoints(geometry)
           THEN ST_Centroid(geometry)
           ELSE ST_PointOnSurface(geometry)
    END
  WHERE ST_GeometryType(geometry) <> 'ST_Point';

  UPDATE osm_poi_polygon
  SET subclass = 'subway'
  WHERE station = 'subway' and subclass='station';

  UPDATE osm_poi_polygon
  SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry)
  WHERE COALESCE(tags->'name:latin', tags->'name:nonlatin', tags->'name_int') IS NULL;

  ANALYZE osm_poi_polygon;
END;
$$ LANGUAGE plpgsql;

SELECT update_poi_polygon();

-- Handle updates

CREATE SCHEMA IF NOT EXISTS poi_polygon;

CREATE TABLE IF NOT EXISTS poi_polygon.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION poi_polygon.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO poi_polygon.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION poi_polygon.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh poi_polygon';
    PERFORM update_poi_polygon();
    DELETE FROM poi_polygon.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_poi_polygon
    FOR EACH STATEMENT
    EXECUTE PROCEDURE poi_polygon.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON poi_polygon.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE poi_polygon.refresh();
DROP TRIGGER IF EXISTS trigger_flag ON osm_poi_point;
DROP TRIGGER IF EXISTS trigger_refresh ON poi_point.updates;

-- etldoc:  osm_poi_point ->  osm_poi_point
CREATE OR REPLACE FUNCTION update_osm_poi_point() RETURNS VOID AS $$
BEGIN
  UPDATE osm_poi_point
    SET subclass = 'subway'
    WHERE station = 'subway' and subclass='station';

  UPDATE osm_poi_point
  SET tags = slice_language_tags(tags) || get_basic_names(tags, geometry)
  WHERE COALESCE(tags->'name:latin', tags->'name:nonlatin', tags->'name_int') IS NULL;

END;
$$ LANGUAGE plpgsql;

SELECT update_osm_poi_point();

-- Handle updates

CREATE SCHEMA IF NOT EXISTS poi_point;

CREATE TABLE IF NOT EXISTS poi_point.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION poi_point.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO poi_point.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION poi_point.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh poi_point';
    PERFORM update_osm_poi_point();
    DELETE FROM poi_point.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_poi_point
    FOR EACH STATEMENT
    EXECUTE PROCEDURE poi_point.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON poi_point.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE poi_point.refresh();
CREATE OR REPLACE FUNCTION poi_class_rank(class TEXT)
RETURNS INT AS $$
    SELECT CASE class
        WHEN 'hospital' THEN 20
        WHEN 'park' THEN 25
        WHEN 'cemetery' THEN 30
        WHEN 'railway' THEN 40
        WHEN 'bus' THEN 50
        WHEN 'attraction' THEN 70
        WHEN 'harbor' THEN 75
        WHEN 'college' THEN 80
        WHEN 'school' THEN 85
        WHEN 'stadium' THEN 90
        WHEN 'zoo' THEN 95
        WHEN 'town_hall' THEN 100
        WHEN 'campsite' THEN 110
        WHEN 'cemetery' THEN 115
        WHEN 'park' THEN 120
        WHEN 'library' THEN 130
        WHEN 'police' THEN 135
        WHEN 'post' THEN 140
        WHEN 'golf' THEN 150
        WHEN 'shop' THEN 400
        WHEN 'grocery' THEN 500
        WHEN 'fast_food' THEN 600
        WHEN 'clothing_store' THEN 700
        WHEN 'bar' THEN 800
        ELSE 1000
    END;
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION poi_class(subclass TEXT, mapping_key TEXT)
RETURNS TEXT AS $$
    SELECT CASE
        WHEN subclass IN ('accessories','antiques','art','beauty','bed','boutique','camera','carpet','charity','chemist','chocolate','coffee','computer','confectionery','convenience','copyshop','cosmetics','garden_centre','doityourself','erotic','electronics','fabric','florist','furniture','video_games','video','general','gift','hardware','hearing_aids','hifi','ice_cream','interior_decoration','jewelry','kiosk','lamps','mall','massage','motorcycle','mobile_phone','newsagent','optician','outdoor','perfumery','perfume','pet','photo','second_hand','shoes','sports','stationery','tailor','tattoo','ticket','tobacco','toys','travel_agency','watches','weapons','wholesale') THEN 'shop'
        WHEN subclass IN ('townhall','public_building','courthouse','community_centre') THEN 'town_hall'
        WHEN subclass IN ('golf','golf_course','miniature_golf') THEN 'golf'
        WHEN subclass IN ('fast_food','food_court') THEN 'fast_food'
        WHEN subclass IN ('park','bbq') THEN 'park'
        WHEN subclass IN ('bus_stop','bus_station') THEN 'bus'
        -- because 'station' might be from both aeroway and railway
        WHEN (subclass='station' AND mapping_key = 'railway') OR subclass IN ('halt', 'tram_stop', 'subway') THEN 'railway'
        WHEN subclass IN ('camp_site','caravan_site') THEN 'campsite'
        WHEN subclass IN ('laundry','dry_cleaning') THEN 'laundry'
        WHEN subclass IN ('supermarket','deli','delicatessen','department_store','greengrocer','marketplace') THEN 'grocery'
        WHEN subclass IN ('books','library') THEN 'library'
        WHEN subclass IN ('university','college') THEN 'college'
        WHEN subclass IN ('hotel','motel','bed_and_breakfast','guest_house','hostel','chalet','alpine_hut','camp_site') THEN 'lodging'
        WHEN subclass IN ('chocolate','confectionery') THEN 'ice_cream'
        WHEN subclass IN ('post_box','post_office') THEN 'post'
        WHEN subclass IN ('cafe') THEN 'cafe'
        WHEN subclass IN ('school','kindergarten') THEN 'school'
        WHEN subclass IN ('alcohol','beverages','wine') THEN 'alcohol_shop'
        WHEN subclass IN ('bar','nightclub') THEN 'bar'
        WHEN subclass IN ('marina','dock') THEN 'harbor'
        WHEN subclass IN ('car','car_repair','taxi') THEN 'car'
        WHEN subclass IN ('hospital','nursing_home', 'doctors', 'clinic') THEN 'hospital'
        WHEN subclass IN ('grave_yard','cemetery') THEN 'cemetery'
        WHEN subclass IN ('attraction','viewpoint') THEN 'attraction'
        WHEN subclass IN ('biergarten','pub') THEN 'beer'
        WHEN subclass IN ('music','musical_instrument') THEN 'music'
        WHEN subclass IN ('american_football','stadium','soccer','pitch') THEN 'stadium'
        WHEN subclass IN ('accessories','antiques','art','artwork','gallery','arts_centre') THEN 'art_gallery'
        WHEN subclass IN ('bag','clothes') THEN 'clothing_store'
        WHEN subclass IN ('swimming_area','swimming') THEN 'swimming'
        ELSE subclass
    END;
$$ LANGUAGE SQL IMMUTABLE;

-- etldoc: layer_poi[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_poi | <z14_> z14+" ] ;

CREATE OR REPLACE FUNCTION layer_poi(bbox geometry, zoom_level integer, pixel_width numeric)
RETURNS TABLE(osm_id bigint, geometry geometry, name text, name_en text, name_de text, tags hstore, class text, subclass text, "rank" int) AS $$
    SELECT osm_id, geometry, NULLIF(name, '') AS name,
    COALESCE(NULLIF(name_en, ''), name) AS name_en,
    COALESCE(NULLIF(name_de, ''), name, name_en) AS name_de,
    tags,
    poi_class(subclass, mapping_key) AS class, subclass,
        row_number() OVER (
            PARTITION BY LabelGrid(geometry, 100 * pixel_width)
            ORDER BY CASE WHEN name = '' THEN 2000 ELSE poi_class_rank(poi_class(subclass, mapping_key)) END ASC
        )::int AS "rank"
    FROM (
        -- etldoc: osm_poi_point ->  layer_poi:z14_
        SELECT * FROM osm_poi_point
            WHERE geometry && bbox
                AND zoom_level >= 14
        UNION ALL
        -- etldoc: osm_poi_polygon ->  layer_poi:z14_
        SELECT * FROM osm_poi_polygon
            WHERE geometry && bbox
                AND zoom_level >= 14
        ) as poi_union
    ORDER BY "rank"
    ;
$$ LANGUAGE SQL IMMUTABLE;
