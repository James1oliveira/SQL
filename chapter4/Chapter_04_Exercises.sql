-- ================================================================
-- CHAPTER 4: Importing and Exporting Data
-- TRY IT YOURSELF - EXERCISES
-- ================================================================


-- ----------------------------------------------------------------
-- Exercise 1:
-- Write the WITH options for COPY to import this file:
--   id:movie:actor
--   50:#Mission: Impossible#:Tom Cruise

--The WITH statement in a COPY command is where you tell PostgreSQL 
-- how to read the file you are importing. 
-- Think of it as the “instructions” for understanding the file’s format.

-- ----------------------------------------------------------------

-- COPY movies
-- FROM 'C:\SQL'
-- WITH (FORMAT CSV, HEADER, DELIMITER ':', QUOTE '#');


-- ----------------------------------------------------------------
-- Exercise 2:
-- Export the 20 counties with the most housing units.
-- Only include county name, state abbreviation, and housing unit count.
-- (Housing units are in the column: housing_unit_count_100_percent)
-- ----------------------------------------------------------------

-- COPY (
--     SELECT geo_name, state_us_abbreviation, housing_unit_count_100_percent
--     FROM us_counties_2010
--     ORDER BY housing_unit_count_100_percent DESC
--     LIMIT 20
-- )
-- TO 'C:\SQL\us_counties_top20_housing.txt'
-- WITH (FORMAT CSV, HEADER, DELIMITER '|');


-- ----------------------------------------------------------------
-- Exercise 3:
-- Will numeric(3,8) work for values like 17519.668?
-- NO — numeric(3,8) means 3 total digits with 8 after the decimal.
-- That is impossible: 8 decimal digits cannot fit inside 3 total digits.
-- PostgreSQL will return an error when you try to create this column.
--
-- The correct data type for 17519.668 is numeric(8,3):
-- 8 total digits, 3 after the decimal (e.g., 17519.668).
-- ----------------------------------------------------------------

-- Correct column definition for this kind of value:
-- CREATE TABLE measurement_example (
--     value numeric(8,3)
-- );