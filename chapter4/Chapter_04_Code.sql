-- ================================================================
-- CHAPTER 4: Importing and Exporting Data
-- MAIN CODE
-- ================================================================


-- ----------------------------------------------------------------
-- Basic COPY Import Syntax
-- ----------------------------------------------------------------

-- COPY table_name
-- FROM 'C:\Users\33980\OneDrive\Desktop\code college\SQL\Classwork\chapter4'
-- WITH (FORMAT CSV, HEADER);


-- ----------------------------------------------------------------
-- Create the us_counties_2010 Table (abbreviated)
-- Download the full version at: https://www.nostarch.com/practicalSQL/
-- ----------------------------------------------------------------

-- CREATE TABLE us_counties_2010 (
--     geo_name varchar(90),
--     state_us_abbreviation varchar(2),
--     summary_level varchar(3),
--     region smallint,
--     division smallint,
--     state_fips varchar(2),
--     county_fips varchar(3),
--     area_land bigint,
--     area_water bigint,
--     population_count_100_percent integer,
--     housing_unit_count_100_percent integer,
--     internal_point_lat numeric(10,7),
--     internal_point_lon numeric(10,7),
--     p0010001 integer, p0010002 integer, p0010003 integer, p0010004 integer,
--     p0010005 integer, p0010006 integer, p0010007 integer, p0010008 integer,
--     p0010009 integer, p0010010 integer, p0010011 integer, p0010012 integer,
--     p0010013 integer, p0010014 integer, p0010015 integer, p0010016 integer,
--     p0010017 integer, p0010018 integer, p0010019 integer, p0010020 integer,
--     p0010021 integer, p0010022 integer, p0010023 integer, p0010024 integer,
--     p0010025 integer, p0010026 integer, p0010047 integer, p0010063 integer,
--     p0010070 integer,
--     p0020001 integer, p0020002 integer, p0020003 integer, p0020004 integer,
--     p0020005 integer, p0020006 integer, p0020007 integer, p0020008 integer,
--     p0020009 integer, p0020010 integer, p0020011 integer, p0020012 integer,
--     p0020028 integer, p0020049 integer, p0020065 integer, p0020072 integer,
--     p0030001 integer, p0030002 integer, p0030003 integer, p0030004 integer,
--     p0030005 integer, p0030006 integer, p0030007 integer, p0030008 integer,
--     p0030009 integer, p0030010 integer, p0030026 integer, p0030047 integer,
--     p0030063 integer, p0030070 integer,
--     p0040001 integer, p0040002 integer, p0040003 integer, p0040004 integer,
--     p0040005 integer, p0040006 integer, p0040007 integer, p0040008 integer,
--     p0040009 integer, p0040010 integer, p0040011 integer, p0040012 integer,
--     p0040028 integer, p0040049 integer, p0040065 integer, p0040072 integer,
--     h0010001 integer, h0010002 integer, h0010003 integer
-- );


-- ----------------------------------------------------------------
-- Import Census Data using COPY
-- ----------------------------------------------------------------

-- COPY us_counties_2010
-- FROM 'C:\Users\33980\OneDrive\Desktop\code college\SQL\Classwork\chapter4\us_counties_2010.csv'
-- WITH (FORMAT CSV, HEADER);


-- ----------------------------------------------------------------
-- Inspect Imported Data
-- ----------------------------------------------------------------

-- View all rows:
-- SELECT * FROM us_counties_2010;

-- Check top 3 counties with the largest land area:
-- SELECT geo_name, state_us_abbreviation, area_land
-- FROM us_counties_2010
-- ORDER BY area_land DESC
-- LIMIT 3;

-- Check top 5 easternmost counties by longitude:
-- SELECT geo_name, state_us_abbreviation, internal_point_lon
-- FROM us_counties_2010
-- ORDER BY internal_point_lon DESC
-- LIMIT 5;


-- ----------------------------------------------------------------
-- Create the supervisor_salaries Table
-- ----------------------------------------------------------------

-- CREATE TABLE supervisor_salaries (
--     town varchar(30),
--     county varchar(30),
--     supervisor varchar(30),
--     start_date date,
--     salary money,
--     benefits money
-- );


-- ----------------------------------------------------------------
-- Import a Subset of Columns (CSV has only 3 of the 6 columns)
-- ----------------------------------------------------------------

-- COPY supervisor_salaries (town, supervisor, salary)
-- FROM ''E:\school\SQL\Classwork\Book1\supervisor_salaries.csv'
-- WITH (FORMAT CSV, HEADER);


-- ----------------------------------------------------------------
-- Add a Default Value During Import Using a Temporary Table
-- ----------------------------------------------------------------

-- Step 1: Clear previous data:
-- DELETE FROM supervisor_salaries;

-- Step 2: Create a temporary table that mirrors the main table:
-- CREATE TEMPORARY TABLE supervisor_salaries_temp (LIKE supervisor_salaries);

-- Step 3: Import CSV into the temporary table:
-- COPY supervisor_salaries_temp (town, supervisor, salary)
-- FROM 'C:\YourDirectory\supervisor_salaries.csv'
-- WITH (FORMAT CSV, HEADER);

-- Step 4: Copy from temp table to main table, adding a county value:
-- INSERT INTO supervisor_salaries (town, county, supervisor, salary)
-- SELECT town, 'Some County', supervisor, salary
-- FROM supervisor_salaries_temp;

-- Step 5: Remove the temporary table:
-- DROP TABLE supervisor_salaries_temp;


-- ----------------------------------------------------------------
-- Export Data with COPY
-- ----------------------------------------------------------------

-- Export the entire table to a pipe-delimited file:
-- COPY us_counties_2010
-- TO ''E:\school\SQL\Classwork\Book1\us_counties_export.txt'
-- WITH (FORMAT CSV, HEADER, DELIMITER '|');

-- Export only selected columns:
-- COPY us_counties_2010 (geo_name, internal_point_lat, internal_point_lon)
-- TO 'E:\school\SQL\Classwork\Book1\us_counties_latlon_export.txt'
-- WITH (FORMAT CSV, HEADER, DELIMITER '|');

-- Export only the results of a query:
-- COPY (
--     SELECT geo_name, state_us_abbreviation
--     FROM us_counties_2010
--     WHERE geo_name ILIKE '%mill%'
-- )
-- TO 'C:\YourDirectory\us_counties_mill_export.txt'
-- WITH (FORMAT CSV, HEADER, DELIMITER '|');