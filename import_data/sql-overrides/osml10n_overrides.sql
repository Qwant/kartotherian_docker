/*
    Disable Kanji transliteration (produces invalid utf8)
*/
CREATE OR REPLACE FUNCTION osml10n_kanji_transcript(text) RETURNS text AS $$
    SELECT NULL::text
$$ LANGUAGE SQL IMMUTABLE PARALLEL SAFE;


/*
    Override get_country: the original function provided by mapnik-german-l10n is too slow
    # See https://github.com/giggls/mapnik-german-l10n/issues/54 for more details;
    # the issue also mentions an alternative fix, not yet available on the latest release (v2.5.9)
*/
CREATE OR REPLACE FUNCTION osml10n_get_country(feature geometry)
    RETURNS text
    LANGUAGE plpgsql
    STABLE PARALLEL SAFE STRICT
AS $function$
    DECLARE
        transformed_feature geometry;
        country text;
    BEGIN
        transformed_feature := st_centroid(st_transform(feature,4326));
        SELECT country_code INTO country
        FROM country_osm_grid
        WHERE st_contains(geometry, transformed_feature)
        ORDER BY area
        LIMIT 1;
    RETURN country;
    END;
$function$;
