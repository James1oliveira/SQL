-- ================================================================
-- CHAPTER 3: Understanding Data Types
-- MAIN CODE
-- ================================================================


-- ----------------------------------------------------------------
-- Character Data Types in Action
-- ----------------------------------------------------------------

-- CREATE TABLE char_data_types (
--     varchar_column varchar(10),
--     char_column char(10),
--     text_column text
-- );

-- INSERT INTO char_data_types
-- VALUES
--     ('abc', 'abc', 'abc'),
--     ('defghi', 'defghi', 'defghi');

-- Export to a file to compare how each type stores data:
-- COPY char_data_types TO 'C:\YourDirectory\typetest.txt'
-- WITH (FORMAT CSV, HEADER, DELIMITER '|');


-- ----------------------------------------------------------------
-- Number Data Types in Action
-- ----------------------------------------------------------------

-- CREATE TABLE number_data_types (
--     numeric_column numeric(20,5),
--     real_column real,
--     double_column double precision
-- );

-- INSERT INTO number_data_types
-- VALUES
--     (.7, .7, .7),
--     (2.13579, 2.13579, 2.13579),
--     (2.1357987654, 2.1357987654, 2.1357987654);

-- SELECT * FROM number_data_types;


-- ----------------------------------------------------------------
-- Floating-Point Rounding Issue (demonstration)
-- ----------------------------------------------------------------

-- SELECT
--     numeric_column * 10000000 AS "Fixed",
--     real_column * 10000000 AS "Float"
-- FROM number_data_types
-- WHERE numeric_column = .7;


-- ----------------------------------------------------------------
-- Date and Time Types in Action
-- ----------------------------------------------------------------

-- CREATE TABLE date_time_types (
--     timestamp_column timestamp with time zone,
--     interval_column interval
-- );

-- INSERT INTO date_time_types
-- VALUES
--     ('2018-12-31 01:00 EST', '2 days'),
--     ('2018-12-31 01:00 -8', '1 month'),
--     ('2018-12-31 01:00 Australia/Melbourne', '1 century'),
--     (now(), '1 week');

-- SELECT * FROM date_time_types;


-- ----------------------------------------------------------------
-- Using interval for Date Calculations
-- ----------------------------------------------------------------

-- SELECT
--     timestamp_column,
--     interval_column,
--     timestamp_column - interval_column AS new_date
-- FROM date_time_types;


-- ----------------------------------------------------------------
-- Type Conversion with CAST()
-- ----------------------------------------------------------------

-- Convert timestamp to varchar (keeps only first 10 characters = date):
-- SELECT timestamp_column, CAST(timestamp_column AS varchar(10))
-- FROM date_time_types;

-- Convert numeric to integer (rounds) and to varchar (truncates):
-- SELECT numeric_column,
--        CAST(numeric_column AS integer),
--        CAST(numeric_column AS varchar(6))
-- FROM number_data_types;

-- This will return an ERROR (cannot cast letters to integer):
-- SELECT CAST(char_column AS integer) FROM char_data_types;


-- ----------------------------------------------------------------
-- PostgreSQL Shortcut Notation for CAST (double colon ::)
-- ----------------------------------------------------------------

-- These two do the same thing:
-- SELECT timestamp_column, CAST(timestamp_column AS varchar(10))
-- FROM date_time_types;

-- SELECT timestamp_column::varchar(10)
-- FROM date_time_types;
