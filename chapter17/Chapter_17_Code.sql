-- ================================================================
-- CHAPTER 17: Maintaining Your Database
-- MAIN CODE + EXERCISES
-- ================================================================


-- ================================================================
-- VACUUM: Recovering Unused Space
-- ================================================================

-- Create a test table:
-- CREATE TABLE vacuum_test (integer_column integer);

-- Check size (should be 0 bytes when empty):
-- SELECT pg_size_pretty(pg_total_relation_size('vacuum_test'));

-- Or via command line in psql:
-- \dt+ vacuum_test

-- Insert 500,000 rows:
-- INSERT INTO vacuum_test SELECT * FROM generate_series(1,500000);

-- Check size (should be ~17 MB):
-- SELECT pg_size_pretty(pg_total_relation_size('vacuum_test'));

-- Update all rows (creates dead rows — size doubles to ~35 MB):
-- UPDATE vacuum_test SET integer_column = integer_column + 1;
-- SELECT pg_size_pretty(pg_total_relation_size('vacuum_test'));

-- Check autovacuum activity:
-- SELECT relname, last_vacuum, last_autovacuum, vacuum_count, autovacuum_count
-- FROM pg_stat_all_tables
-- WHERE relname = 'vacuum_test';

-- Run VACUUM manually:
-- VACUUM vacuum_test;

-- Run VACUUM FULL (returns space to disk, table goes back to ~17 MB):
-- VACUUM FULL vacuum_test;
-- SELECT pg_size_pretty(pg_total_relation_size('vacuum_test'));

-- VACUUM with VERBOSE output:
-- VACUUM VERBOSE vacuum_test;

-- VACUUM entire database:
-- VACUUM;

-- VACUUM with ANALYZE (also updates query planner statistics):
-- VACUUM ANALYZE vacuum_test;


-- ================================================================
-- CHANGING SERVER SETTINGS (postgresql.conf)
-- ================================================================

-- Find the location of postgresql.conf:
-- SHOW config_file;

-- Find the data directory:
-- SHOW data_directory;

-- View current timezone setting:
-- SHOW timezone;

-- View current date style:
-- SHOW datestyle;

-- Some key settings inside postgresql.conf:
--   datestyle = 'iso, mdy'              -- Date display format
--   timezone = 'US/Eastern'             -- Server time zone
--   default_text_search_config = 'pg_catalog.english'  -- Full text language
--   autovacuum = on                     -- Enable auto vacuum (default)

-- After editing postgresql.conf, reload settings from command line (not psql):
-- Windows:   pg_ctl reload -D "C:\path\to\data\"
-- macOS/Linux: pg_ctl reload -D '/path/to/data/'


-- ================================================================
-- BACKING UP AND RESTORING (run from system command prompt, not psql)
-- ================================================================

-- Back up entire analysis database (custom compressed format):
--   pg_dump -d analysis -U postgres -Fc > analysis_backup.sql

-- Back up a single table:
--   pg_dump -t 'train_rides' -d analysis -U postgres -Fc > train_backup.sql

-- Restore the analysis database:
--   pg_restore -C -d postgres -U postgres analysis_backup.sql

-- Additional pg_dump options:
--   -Fp   Plain text output (readable SQL)
--   -Fc   Custom compressed format (default recommendation)
--   -Fd   Directory format
--   -Ft   Tar format


-- ================================================================
-- CHAPTER 17: Try It Yourself Exercise
-- ================================================================

-- Back up the gis_analysis database created in Chapter 14:
--   pg_dump -d gis_analysis -U postgres -Fc > gis_analysis_backup.sql

-- Drop the original (to practice restore):
--   dropdb -U postgres gis_analysis

-- Restore it:
--   pg_restore -C -d postgres -U postgres gis_analysis_backup.sql

-- Also try backing up individual tables:
--   pg_dump -t 'farmers_markets' -d gis_analysis -U postgres -Fc > farmers_markets_backup.sql

-- Open the backup file in a text editor to see how pg_dump organizes:
-- - CREATE TABLE statements
-- - COPY commands for inserting data
-- - Index creation statements
-- - Constraint definitions
