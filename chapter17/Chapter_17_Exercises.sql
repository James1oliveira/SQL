-- ================================================================
-- CHAPTER 17: Maintaining Your Database
-- TRY IT YOURSELF - EXERCISES
-- ================================================================
-- These pg_dump / pg_restore commands are run at the
-- Windows Command Prompt (CMD), NOT inside pgAdmin or psql.


-- ----------------------------------------------------------------
-- Exercise 1:
-- Back up the gis_analysis database created in Chapter 14.
-- Then drop it and restore it from your backup file.
-- This confirms your backup is complete and usable.
-- ----------------------------------------------------------------

-- STEP 1: Back up the entire gis_analysis database.
-- Run at Command Prompt:
--   pg_dump -d gis_analysis -U postgres -Fc > "C:\SQL\gis_analysis_backup.dump"

-- -d gis_analysis   = which database to back up
-- -U postgres       = connect as this user
-- -Fc               = custom compressed format (recommended)
-- >                 = redirect output to the file on the right

-- STEP 2: Drop the original database to simulate a disaster.
-- WARNING: This permanently deletes the database.
--   dropdb -U postgres gis_analysis

-- STEP 3: Restore the database from your backup.
--   pg_restore -C -d postgres -U postgres "C:\SQL\gis_analysis_backup.dump"

-- -C   = create the database before restoring
-- -d postgres = connect to the postgres database first (needed when creating a new db)

-- STEP 4: Verify the restore worked.
-- Connect and check tables:
--   psql -d gis_analysis -U postgres
--   \dt+
--   SELECT count(*) FROM farmers_markets;


-- ----------------------------------------------------------------
-- Exercise 2:
-- Back up only the farmers_markets table (not the whole database).
-- Restore just that table into the gis_analysis database.
-- ----------------------------------------------------------------

-- Back up one table with -t flag:
--   pg_dump -t farmers_markets -d gis_analysis -U postgres -Fc > "C:\SQL\farmers_markets_backup.dump"

-- Drop just that table to test:
--   psql -d gis_analysis -U postgres -c "DROP TABLE farmers_markets;"

-- Restore just that table:
--   pg_restore -d gis_analysis -U postgres "C:\SQL\farmers_markets_backup.dump"

-- Verify:
--   psql -d gis_analysis -U postgres -c "SELECT count(*) FROM farmers_markets;"


-- ----------------------------------------------------------------
-- Exercise 3:
-- Open the backup dump file in a text editor to explore its structure.
-- Also try creating a plain-text SQL backup you can fully read.
-- ----------------------------------------------------------------

-- Create a plain-text (human-readable) backup with -Fp:
--   pg_dump -d analysis -U postgres -Fp > "C:\SQL\analysis_plain.sql"

-- Open analysis_plain.sql in Notepad or VS Code.
-- You will see:
--   -- CREATE TABLE statements for each table
--   -- COPY commands with the actual data rows
--   -- CREATE INDEX statements
--   -- ALTER TABLE statements for constraints
-- This format can be run directly in pgAdmin as a SQL script.

-- Compare size of plain vs compressed:
-- The -Fc (compressed) file will be much smaller than -Fp (plain text).


-- ----------------------------------------------------------------
-- Exercise 4 (BONUS):
-- Monitor the vacuum status of your vacuum_test table from Chapter 17.
-- Run the UPDATE to create dead rows, then check autovacuum stats.
-- ----------------------------------------------------------------

-- In pgAdmin or psql (analysis database):

-- Create and fill the test table:
-- CREATE TABLE vacuum_test (integer_column integer);
-- INSERT INTO vacuum_test SELECT * FROM generate_series(1,500000);

-- Check initial size:
-- SELECT pg_size_pretty(pg_total_relation_size('vacuum_test'));
-- Expected: ~17 MB

-- Update all rows (creates dead rows):
-- UPDATE vacuum_test SET integer_column = integer_column + 1;

-- Check size after update:
-- SELECT pg_size_pretty(pg_total_relation_size('vacuum_test'));
-- Expected: ~35 MB (dead rows still taking up space)

-- Check vacuum stats:
-- SELECT relname, last_vacuum, last_autovacuum, vacuum_count, autovacuum_count
-- FROM pg_stat_all_tables
-- WHERE relname = 'vacuum_test';

-- Run VACUUM FULL and check size again:
-- VACUUM FULL vacuum_test;
-- SELECT pg_size_pretty(pg_total_relation_size('vacuum_test'));
-- Expected: back to ~17 MB
