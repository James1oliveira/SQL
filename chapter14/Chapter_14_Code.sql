-- ================================================================
-- CHAPTER 14: Analyzing Spatial Data with PostGIS
-- MAIN CODE + EXERCISES
-- Data files: C:\SQL\
-- ================================================================
-- REQUIRED FILES (download from nostarch.com):
--   farmers_markets.csv
--   Shapefiles: tl_2010_us_county10.zip, tl_2016_35049_linearwater.zip,
--               tl_2016_35049_roads.zip
-- NOTE: Chapter 14 uses the gis_analysis database, not analysis.


-- ================================================================
-- Set Up PostGIS
-- ================================================================

-- Create the gis_analysis database first in pgAdmin, then connect to it:
-- CREATE EXTENSION postgis;
-- SELECT postgis_full_version();


-- ================================================================
-- Spatial Data Types and WKT
-- ================================================================

-- Point:
-- SELECT ST_GeomFromText('POINT(-74.9233606 42.699992)', 4326);

-- Line:
-- SELECT ST_GeomFromText('LINESTRING(-74.9 42.7, -75.1 42.8)', 4326);

-- Polygon:
-- SELECT ST_GeomFromText('POLYGON((-74.9 42.7, -75.1 42.8,
--                                  -75.1 42.5, -74.9 42.7))', 4326);

-- MultiPolygon:
-- SELECT ST_GeomFromText('MULTIPOLYGON((
--     (-74.9 42.7, -75.1 42.8, -75.1 42.5, -74.9 42.7),
--     (-75.0 42.6, -75.2 42.7, -75.2 42.4, -75.0 42.6)))', 4326);

-- Creating Points, Lines, Polygons:
-- SELECT ST_PointFromText('POINT(-73.9813 40.7580)', 4326);
-- SELECT ST_GeogFromText('POINT(-73.9813 40.7580)');  -- geography type
-- SELECT ST_MakePoint(-74.9233606, 42.699992);
-- SELECT ST_LineFromText('LINESTRING(-105.90 35.67,-105.45 35.45)', 4326);
-- SELECT ST_MakeLine(ST_MakePoint(-74.9, 42.7), ST_MakePoint(-75.1, 42.8));
-- SELECT ST_PolygonFromText('POLYGON((-74.9 42.7,-75.1 42.8,-75.1 42.5,-74.9 42.7))', 4326);
-- SELECT ST_MakePolygon(ST_GeomFromText('LINESTRING(-74.9 42.7,-75.1 42.8,-75.1 42.5,-74.9 42.7)', 4326));
-- SELECT ST_MPolyFromText('MULTIPOLYGON(((-74.9 42.7,-75.1 42.8,-75.1 42.5,-74.9 42.7)))', 4326);

-- Convert geometry to WKT:
-- SELECT ST_AsText(ST_GeomFromText('POINT(-74.9233606 42.699992)', 4326));


-- ================================================================
-- Farmers Markets Analysis
-- ================================================================

-- Create and import farmers_markets table:
-- CREATE TABLE farmers_markets (
--     fmid bigint PRIMARY KEY,
--     market_name text NOT NULL,
--     street text, city text, county text, st text, zip text,
--     longitude numeric(10,7), latitude numeric(10,7),
--     organic text, bakedgoods text, cheese text, crafts text,
--     flowers text, eggs text, seafood text, herbs text,
--     vegetables text, honey text, jams text, maple text,
--     meat text, nursery text, nuts text, plants text,
--     poultry text, prepared text, soap text, trees text, wine text,
--     coffee text, beans text, fruits text, grains text,
--     juices text, mushrooms text, petfood text, tofu text,
--     wildharvested text, website text
-- );
-- COPY farmers_markets FROM 'C:\SQL\farmers_markets.csv'
-- WITH (FORMAT CSV, HEADER, DELIMITER ',');
-- SELECT count(*) FROM farmers_markets;

-- Add geography column and populate:
-- ALTER TABLE farmers_markets ADD COLUMN geog_point geography(POINT,4326);
-- UPDATE farmers_markets SET geog_point = ST_SetSRID(ST_MakePoint(longitude,latitude),4326)::geography;
-- CREATE INDEX market_pts_idx ON farmers_markets USING GIST (geog_point);

-- Find markets near a point (10km around downtown Des Moines):
-- SELECT market_name, city, st
-- FROM farmers_markets
-- WHERE ST_DWithin(geog_point,
--                  ST_GeogFromText('POINT(-93.6204386 41.5853202)'),
--                  10000)
-- ORDER BY market_name;

-- Distance between markets (meters to miles):
-- SELECT market_name, city,
--        round((ST_Distance(geog_point,
--               ST_GeogFromText('POINT(-93.6204386 41.5853202)')
--               ) / 1609.344)::numeric(8,5), 2) AS miles_from_dt
-- FROM farmers_markets
-- WHERE ST_DWithin(geog_point,
--                  ST_GeogFromText('POINT(-93.6204386 41.5853202)'),
--                  10000)
-- ORDER BY miles_from_dt ASC;


-- ================================================================
-- Shapefiles (load via PostGIS Shapefile Loader GUI)
-- ================================================================
-- Load tl_2010_us_county10.shp as table: us_counties_2010_shp  (SRID: 4269)
-- Load tl_2016_35049_linearwater.shp as table: santafe_linearwater_2016
-- Load tl_2016_35049_roads.shp as table: santafe_roads_2016

-- Check geometry type:
-- SELECT ST_AsText(geom) FROM us_counties_2010_shp LIMIT 1;

-- Find largest counties by area (square miles):
-- SELECT name10, statefp10 AS st,
--        round((ST_Area(geom::geography) / 2589988.110336)::numeric, 2) AS square_miles
-- FROM us_counties_2010_shp
-- ORDER BY square_miles DESC LIMIT 5;

-- Find county containing a specific point (Hollywood, CA):
-- SELECT name10, statefp10
-- FROM us_counties_2010_shp
-- WHERE ST_Within('SRID=4269;POINT(-118.3419063 34.0977076)'::geometry, geom);

-- Check geometry types for road/water tables:
-- SELECT ST_GeometryType(geom) FROM santafe_linearwater_2016 LIMIT 1;
-- SELECT ST_GeometryType(geom) FROM santafe_roads_2016 LIMIT 1;

-- Spatial join: roads crossing the Santa Fe River:
-- SELECT water.fullname AS waterway, roads.rttyp, roads.fullname AS road
-- FROM santafe_linearwater_2016 water JOIN santafe_roads_2016 roads
-- ON ST_Intersects(water.geom, roads.geom)
-- WHERE water.fullname = 'Santa Fe Riv'
-- ORDER BY roads.fullname;

-- Show exact intersection points:
-- SELECT water.fullname AS waterway, roads.rttyp, roads.fullname AS road,
--        ST_AsText(ST_Intersection(water.geom, roads.geom))
-- FROM santafe_linearwater_2016 water JOIN santafe_roads_2016 roads
-- ON ST_Intersects(water.geom, roads.geom)
-- WHERE water.fullname = 'Santa Fe Riv'
-- ORDER BY roads.fullname;


-- ================================================================
-- CHAPTER 14: Try It Yourself Exercises
-- ================================================================

-- Exercise 1: Area of each state in square miles. How many exceed Yukon-Koyukuk?
-- SELECT statefp10,
--        round((ST_Area(ST_Union(geom::geography)) / 2589988.110336)::numeric, 2) AS square_miles
-- FROM us_counties_2010_shp
-- GROUP BY statefp10
-- ORDER BY square_miles DESC;

-- Exercise 2: Distance between two farmers markets.
-- SELECT round((ST_Distance(a.geog_point, b.geog_point) / 1609.344)::numeric, 2) AS miles
-- FROM farmers_markets a, farmers_markets b
-- WHERE a.market_name = 'Oakleaf Greenmarket'
--   AND b.market_name = 'Columbia Farmers Market';

-- Exercise 3: Fill missing county names using spatial join.
-- UPDATE farmers_markets fm
-- SET county = (
--     SELECT c.namelsad10
--     FROM us_counties_2010_shp c
--     WHERE ST_Intersects(fm.geog_point::geometry,
--                         ST_SetSRID(c.geom, 4326))
--     LIMIT 1
-- )
-- WHERE fm.county IS NULL;
