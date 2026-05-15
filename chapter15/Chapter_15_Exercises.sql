-- ================================================================
-- CHAPTER 15: Saving Time with Views, Functions, and Triggers
-- TRY IT YOURSELF - EXERCISES
-- Data directory: C:\SQL\
-- ================================================================
-- Requires:
--   nyc_yellow_taxi_trips_2016_06_01  (Chapter 12 / taxi data)
--   meat_poultry_egg_inspect          (Chapter 9)
--   Chapter_15_Code.sql run first


-- ================================================================
-- EXERCISE 1
-- Create a view that shows the number of New York City taxi trips
-- per hour. Recreates the hourly-pickup analysis from Chapter 12
-- as a reusable view.
-- ================================================================

CREATE OR REPLACE VIEW nyc_taxi_trips_per_hour AS
    SELECT
        date_part('hour', tpep_pickup_datetime)::integer AS trip_hour,
        count(*) AS num_trips
    FROM nyc_yellow_taxi_trips_2016_06_01
    GROUP BY trip_hour
    ORDER BY trip_hour;

-- Query the view:
SELECT * FROM nyc_taxi_trips_per_hour;


-- ================================================================
-- EXERCISE 2
-- Write a rates_per_thousand() function that works the same way
-- as percent_change() from Listing 15-4, but multiplies by 1,000
-- instead of 100. It should accept:
--   observed_number  numeric  — the count being measured
--   base_number      numeric  — the population / total
--   decimal_places   integer  — rounding precision (default 1)
-- ================================================================

CREATE OR REPLACE FUNCTION rates_per_thousand(
    observed_number numeric,
    base_number     numeric,
    decimal_places  integer DEFAULT 1
)
RETURNS numeric AS
$$
    SELECT CASE
               WHEN base_number = 0 THEN NULL
               ELSE round((observed_number / base_number) * 1000,
                           decimal_places)
           END;
$$
LANGUAGE SQL IMMUTABLE RETURNS NULL ON NULL INPUT;

-- Test the function (expect 4.5):
SELECT rates_per_thousand(50, 11000, 2);

-- Example: use it against the FBI crime data
-- (assumes fbi_crime_data_2015 table exists from Chapter 8)
-- SELECT city,
--        st,
--        population,
--        property_crime,
--        rates_per_thousand(property_crime::numeric,
--                           population,
--                           2) AS property_crime_per_thousand
-- FROM fbi_crime_data_2015
-- WHERE population >= 100000
-- ORDER BY property_crime_per_thousand DESC;


-- ================================================================
-- EXERCISE 3
-- Add an inspection_date column to meat_poultry_egg_inspect,
-- then create a trigger that automatically sets inspection_date
-- to six months from now whenever a new row is inserted.
-- ================================================================

-- Step 1: Add the inspection_date column (IF NOT EXISTS avoids
--         an error if you run this script more than once).
ALTER TABLE meat_poultry_egg_inspect
    ADD COLUMN IF NOT EXISTS inspection_date date;

-- Step 2: Create the trigger function.
--         It runs BEFORE INSERT so it can set the column value
--         before the row is written to disk.
CREATE OR REPLACE FUNCTION set_inspection_date()
RETURNS trigger AS $$
BEGIN
    NEW.inspection_date := (now() + '6 months'::interval)::date;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 3: Attach the trigger to the table.
--         DROP first so re-running this file does not error.
DROP TRIGGER IF EXISTS inspection_date_insert
    ON meat_poultry_egg_inspect;

CREATE TRIGGER inspection_date_insert
    BEFORE INSERT ON meat_poultry_egg_inspect
    FOR EACH ROW EXECUTE FUNCTION set_inspection_date();

-- Step 4: Test — insert a row and verify inspection_date is set.
INSERT INTO meat_poultry_egg_inspect
    (est_number, company, street, city, st, zip, phone,
     grant_date, activities, dbas)
VALUES
    ('TEST001', 'Test Packing Co.', '123 Main St',
     'Testville', 'TX', '78000', '555-555-5555',
     '2024-01-01', 'Meat Processing', NULL);

-- Confirm the trigger populated inspection_date automatically:
SELECT est_number, company, grant_date, inspection_date
FROM meat_poultry_egg_inspect
WHERE est_number = 'TEST001';

-- Clean up the test row:
DELETE FROM meat_poultry_egg_inspect WHERE est_number = 'TEST001';