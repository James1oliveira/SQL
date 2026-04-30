-- ================================================================
-- CHAPTER 16: Using PostgreSQL from the Command Line
-- TRY IT YOURSELF - EXERCISE
-- ================================================================
-- These commands are run at the Windows Command Prompt (CMD),
-- NOT inside pgAdmin. Open CMD and navigate to your PostgreSQL
-- bin folder or ensure it is on your PATH.


-- ----------------------------------------------------------------
-- Exercise:
-- Choose an example from an earlier chapter and complete it
-- entirely using the psql command line tool.
-- Chapter 14 (PostGIS) is recommended because you can also
-- practice loading shapefiles using shp2pgsql.
-- Below is a full walkthrough using the Chapter 9 data as an example.
-- ----------------------------------------------------------------


-- ================================================================
-- STEP 1: Connect to your database from the command line
-- ================================================================
-- Open Command Prompt and type:
--   psql -d analysis -U postgres

-- You will see the prompt: analysis=#


-- ================================================================
-- STEP 2: Check your tables are present
-- ================================================================
-- At the psql prompt, type:
--   \dt+
-- You should see meat_poultry_egg_inspect and other tables.


-- ================================================================
-- STEP 3: Run a query directly at the prompt
-- ================================================================
-- analysis=# SELECT st, count(*) AS st_count
-- analysis-# FROM meat_poultry_egg_inspect
-- analysis-# GROUP BY st
-- analysis-# ORDER BY st
-- analysis-# LIMIT 10;


-- ================================================================
-- STEP 4: Toggle expanded view for wide tables
-- ================================================================
-- analysis=# \x
-- Now run:
-- analysis=# SELECT * FROM meat_poultry_egg_inspect LIMIT 1;
-- Toggle back: \x


-- ================================================================
-- STEP 5: Export query results to a CSV file using \o
-- ================================================================
-- Set unaligned output with comma separator:
-- analysis=# \a
-- analysis=# \f ,
-- analysis=# \pset footer

-- Direct output to a file:
-- analysis=# \o 'C:\SQL\state_counts.csv'

-- Run the query (output goes to file, not screen):
-- analysis=# SELECT st, count(*) AS st_count
-- analysis-# FROM meat_poultry_egg_inspect
-- analysis-# GROUP BY st ORDER BY st;

-- Stop saving:
-- analysis=# \o

-- Reset formatting:
-- analysis=# \a
-- analysis=# \pset format aligned
-- analysis=# \pset footer


-- ================================================================
-- STEP 6: Import a file using \copy
-- ================================================================
-- analysis=# DROP TABLE IF EXISTS state_regions;
-- analysis=# CREATE TABLE state_regions (
-- analysis(#   st varchar(2) CONSTRAINT st_key PRIMARY KEY,
-- analysis(#   region varchar(20) NOT NULL
-- analysis(# );
-- analysis=# \copy state_regions FROM 'C:\SQL\state_regions.csv' WITH (FORMAT CSV, HEADER);
-- analysis=# SELECT * FROM state_regions LIMIT 5;


-- ================================================================
-- STEP 7 (BONUS - Chapter 14): Load a shapefile from command line
-- ================================================================
-- Run this at the Windows Command Prompt (not inside psql):
--   shp2pgsql -I -s 4269 -W Latin1 "C:\SQL\tl_2010_us_county10.shp" us_counties_2010_shp | psql -d gis_analysis -U postgres
-- This converts the shapefile to SQL and pipes it directly into PostgreSQL.


-- ================================================================
-- STEP 8: Quit psql
-- ================================================================
-- analysis=# \q
