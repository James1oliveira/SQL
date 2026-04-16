
-- ----------------------------------------------------------------
-- Exercise 1:
-- Track mileage to a tenth of a mile, max 999 miles per day.
-- Use numeric(5,1): 5 total digits, 1 digit after the decimal.
-- Example values: 123.4, 999.9, 0.5
-- ----------------------------------------------------------------

-- CREATE TABLE driver_mileage (
--     driver_id bigserial,
--     trip_date date,
--     miles_driven numeric(5,1)
-- );


-- ----------------------------------------------------------------
-- Exercise 2:
-- Store driver first and last names in separate varchar columns.
-- Separating them allows sorting/searching by last name independently.
-- ----------------------------------------------------------------

-- CREATE TABLE drivers (
--     driver_id bigserial,
--     first_name varchar(50),
--     last_name varchar(50)
-- );


-- ----------------------------------------------------------------
-- Exercise 3:
-- Try to CAST a malformed date string '4//2017' to timestamp.
-- PostgreSQL will return an error because the format is not valid.
-- ----------------------------------------------------------------

-- SELECT CAST('4//2017' AS timestamp);
-- ^ ERROR: invalid input syntax for type timestamp: "4//2017"
