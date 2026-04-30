-- ================================================================
-- CHAPTER 14: Analyzing Spatial Data with PostGIS
-- TRY IT YOURSELF - EXERCISES
-- ================================================================
-- Requires: us_counties_2010_shp, farmers_markets tables
-- Run in the gis_analysis database (not analysis)
-- PostGIS extension must be installed: CREATE EXTENSION postgis;


-- ----------------------------------------------------------------
-- Exercise 1:
-- Calculate the area of each state in square miles by combining
-- (ST_Union) all county geometries for each state.
-- How many states are larger than the Yukon-Koyukuk Census Area
-- (the largest county in the US by area)?
-- ----------------------------------------------------------------

-- State areas in square miles:
-- SELECT statefp10,
--        round(
--            (ST_Area(ST_Union(geom::geography)) / 2589988.110336)::numeric,
--            2
--        ) AS square_miles
-- FROM us_counties_2010_shp
-- GROUP BY statefp10
-- ORDER BY square_miles DESC;

-- Note: ST_Union() merges all county polygons into one state polygon.
-- Division by 2589988.110336 converts square meters to square miles.
-- Alaska (02) will be the largest by far.


-- ----------------------------------------------------------------
-- Exercise 2:
-- Find the distance in miles between two specific farmers markets:
--   'Oakleaf Greenmarket' and 'Columbia Farmers Market'
-- Use ST_Distance() and convert meters to miles by dividing by 1609.344.
-- ----------------------------------------------------------------

-- SELECT round(
--     (ST_Distance(a.geog_point, b.geog_point) / 1609.344)::numeric,
--     2
-- ) AS miles_apart
-- FROM farmers_markets a,
--      farmers_markets b
-- WHERE a.market_name = 'Oakleaf Greenmarket'
--   AND b.market_name = 'Columbia Farmers Market';

-- Note: This is a CROSS JOIN filtered to exactly two rows.
-- The result is the straight-line (as the crow flies) distance.


-- ----------------------------------------------------------------
-- Exercise 3:
-- Some rows in farmers_markets are missing a county value.
-- Use a spatial join with ST_Intersects() to fill in the missing
-- county names from the us_counties_2010_shp shapefile.
-- ----------------------------------------------------------------

-- First: check how many are missing county:
-- SELECT count(*) FROM farmers_markets WHERE county IS NULL;

-- Fill missing county names with a spatial join UPDATE:
-- UPDATE farmers_markets fm
-- SET county = (
--     SELECT c.namelsad10
--     FROM us_counties_2010_shp c
--     WHERE ST_Intersects(
--         fm.geog_point::geometry,
--         ST_SetSRID(c.geom, 4326)
--     )
--     LIMIT 1
-- )
-- WHERE fm.county IS NULL;

-- Verify the fix:
-- SELECT market_name, city, st, county
-- FROM farmers_markets
-- WHERE county IS NOT NULL
-- ORDER BY st, county
-- LIMIT 10;

-- Note: ST_SetSRID(c.geom, 4326) ensures both geometries use the same
-- coordinate system before comparing. geog_point uses 4326 (WGS 84),
-- and so does the shapefile when projected correctly.
