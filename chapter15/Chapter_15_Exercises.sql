-- ================================================================
-- CHAPTER 15: Saving Time with Views, Functions, and Triggers
-- TRY IT YOURSELF - EXERCISES
-- ================================================================
-- Requires: nyc_yellow_taxi_trips_2016_06_01, meat_poultry_egg_inspect tables


-- ----------------------------------------------------------------
-- Exercise 1:
-- Create a view called nyc_taxi_trips_per_hour that shows
-- the number of taxi pickups per hour of day on June 1, 2016.
-- Then query it.
-- ----------------------------------------------------------------

-- SET timezone TO 'US/Eastern';

-- CREATE OR REPLACE VIEW nyc_taxi_trips_per_hour AS
-- SELECT date_part('hour', tpep_pickup_datetime) AS trip_hour,
--        count(*) AS num_trips
-- FROM nyc_yellow_taxi_trips_2016_06_01
-- GROUP BY trip_hour
-- ORDER BY trip_hour;

-- Query the view:
-- SELECT * FROM nyc_taxi_trips_per_hour;


-- ----------------------------------------------------------------
-- Exercise 2:
-- Write a function called rates_per_thousand() that calculates
-- a rate per 1,000 population (or any base number).
-- Parameters:
--   observed_number  numeric  — the count being measured
--   base_number      numeric  — the population or total
--   decimal_places   integer  — rounding precision (DEFAULT 1)
-- ----------------------------------------------------------------

-- CREATE OR REPLACE FUNCTION
-- rates_per_thousand(observed_number numeric,
--                    base_number numeric,
--                    decimal_places integer DEFAULT 1)
-- RETURNS numeric AS
-- 'SELECT round((observed_number / base_number) * 1000, decimal_places);'
-- LANGUAGE SQL
-- IMMUTABLE
-- RETURNS NULL ON NULL INPUT;

-- Test the function:
-- SELECT rates_per_thousand(50, 11000, 2);
-- Expected: 4.55

-- Use it on library data from Chapter 8:
-- SELECT libname, stabr,
--        rates_per_thousand(visits::numeric, popu_lsa::numeric, 1)
--            AS visits_per_1000
-- FROM pls_fy2014_pupld14a
-- WHERE popu_lsa >= 250000 AND visits >= 0
-- ORDER BY visits_per_1000 DESC
-- LIMIT 10;


-- ----------------------------------------------------------------
-- Exercise 3:
-- Create a trigger on the meat_poultry_egg_inspect table that
-- automatically sets the inspection_date to 6 months from now
-- every time a new row is inserted.
-- Steps: 1) Write the function  2) Create the trigger  3) Test it.
-- ----------------------------------------------------------------

-- Step 1: Write the trigger function.
-- CREATE OR REPLACE FUNCTION set_inspection_date()
-- RETURNS trigger AS $$
-- BEGIN
--     NEW.inspection_date := now() + '6 months'::interval;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;


-- Step 2: Create the BEFORE INSERT trigger.
-- CREATE TRIGGER inspection_date_insert
-- BEFORE INSERT ON meat_poultry_egg_inspect
-- FOR EACH ROW EXECUTE PROCEDURE set_inspection_date();


-- Step 3: Test by inserting a new row and checking the result.
-- INSERT INTO meat_poultry_egg_inspect
--     (est_number, company, st, zip, activities)
-- VALUES
--     ('TEST001', 'Test Packing Co.', 'TX', '75001', 'Meat Processing');

-- SELECT est_number, company, inspection_date
-- FROM meat_poultry_egg_inspect
-- WHERE est_number = 'TEST001';

-- Expected: inspection_date = today's date + 6 months (set automatically).

-- Clean up the test row:
-- DELETE FROM meat_poultry_egg_inspect WHERE est_number = 'TEST001';
