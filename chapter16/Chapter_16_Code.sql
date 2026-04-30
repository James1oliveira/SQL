-- ================================================================
-- CHAPTER 16: Using PostgreSQL from the Command Line
-- REFERENCE GUIDE
-- ================================================================
-- This chapter is about using psql (command line tool), not SQL code.
-- All commands below are run at your system command prompt (CMD on Windows),
-- NOT inside pgAdmin.


-- ================================================================
-- SETTING UP psql ON WINDOWS
-- ================================================================
-- 1. Open Control Panel > System > Advanced > Environment Variables
-- 2. Under User Variables, add or edit PATH:
--    Add: C:\Program Files\PostgreSQL\x.y\bin
--    (replace x.y with your PostgreSQL version number)
-- 3. Close and reopen Command Prompt for the change to take effect.


-- ================================================================
-- LAUNCHING psql
-- ================================================================
-- Connect to a database:
--   psql -d analysis -U postgres

-- Connect to a remote server:
--   psql -d analysis -U postgres -h example.com

-- Once connected, the prompt looks like:
--   analysis=#   (superuser)
--   analysis=>   (regular user)


-- ================================================================
-- HELP COMMANDS (type at the psql prompt)
-- ================================================================
-- \?              List all psql commands
-- \? options      Options for the psql command
-- \? variables    Variables used by psql
-- \h              List all SQL commands
-- \h INSERT       Detailed help for a specific SQL command


-- ================================================================
-- NAVIGATION AND DATABASE COMMANDS
-- ================================================================
-- Switch database:           \c gis_analysis
-- Switch user:               \c analysis postgres
-- List tables:               \dt
-- List tables + size:        \dt+
-- List tables matching name: \dt+ us*
-- List indexes:              \di
-- List views:                \dv
-- List users:                \du
-- List extensions:           \dx
-- Describe a table:          \d tablename


-- ================================================================
-- RUNNING SQL IN psql
-- ================================================================

-- Single line query:
-- analysis=# SELECT geo_name FROM us_counties_2010 LIMIT 3;

-- Multi-line query (executes when semicolon is reached):
-- analysis=# SELECT geo_name
-- analysis-# FROM us_counties_2010
-- analysis-# LIMIT 3;

-- Edit last query in text editor:
-- \e

-- Scroll through previous queries: Up/Down arrow keys


-- ================================================================
-- FORMATTING OUTPUT
-- ================================================================
-- Turn off paging (show all results at once):  \pset pager
-- Turn paging back on:                         \pset pager (again)
-- Set border style:     \pset border 2
-- Unaligned output:     \pset format unaligned
-- Set field separator:  \pset fieldsep ','
-- Toggle footer:        \pset footer
-- Show NULLs:           \pset null 'NULL'
-- Toggle aligned/unaligned: \a
-- Expanded (vertical) view: \x
-- Auto expanded view:        \x auto


-- ================================================================
-- IMPORTING AND EXPORTING WITH \copy
-- ================================================================
-- \copy works like SQL COPY but routes files from your local machine.
-- Use this when connected to a remote server.

-- Drop and recreate state_regions, then import:
-- analysis=# DROP TABLE state_regions;
-- analysis=# CREATE TABLE state_regions (
-- analysis(#   st varchar(2) CONSTRAINT st_key PRIMARY KEY,
-- analysis(#   region varchar(20) NOT NULL
-- analysis(# );
-- analysis=# \copy state_regions FROM 'C:\SQL\state_regions.csv'
--            WITH (FORMAT CSV, HEADER);


-- ================================================================
-- SAVING QUERY OUTPUT TO A FILE
-- ================================================================
-- Set output format to CSV-like:
-- \a \f , \pset footer

-- Direct all output to a file:
-- \o 'C:\SQL\query_output.csv'

-- Run query (output goes to file, not screen):
-- SELECT * FROM grades;

-- Stop saving to file:
-- \o


-- ================================================================
-- RUNNING A SQL FILE FROM THE COMMAND LINE
-- ================================================================
-- psql -d analysis -U postgres -f display-grades.sql


-- ================================================================
-- ADDITIONAL COMMAND LINE UTILITIES
-- ================================================================

-- Create a new database from the command line (not inside psql):
--   createdb -U postgres -e box_office
-- Then connect:
--   psql -d box_office -U postgres

-- Load a shapefile using shp2pgsql (all one line):
--   shp2pgsql -I -s 4269 -W Latin1 tl_2010_us_county10.shp
--   us_counties_2010_shp | psql -d gis_analysis -U postgres


-- ================================================================
-- USEFUL WINDOWS COMMAND PROMPT COMMANDS
-- ================================================================
-- cd C:\folder        Change directory
-- dir /p              List directory contents (one page at a time)
-- copy file1 file2    Copy a file
-- del *.csv           Delete files matching pattern
-- mkdir newfolder     Create a new directory
-- findstr "text" *.sql  Search for text in files


-- ================================================================
-- CHAPTER 16: Try It Yourself Exercise
-- ================================================================
-- Choose an example from any earlier chapter and work through it
-- using only the command line (psql). Chapter 14 is a good choice
-- because it also lets you practice shp2pgsql for loading shapefiles.
