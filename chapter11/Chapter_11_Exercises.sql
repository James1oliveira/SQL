Here's the fully uncommented code:

```sql
-- ================================================================
-- CHAPTER 11: Working with Dates and Times
-- TRY IT YOURSELF - EXERCISES
-- ================================================================


-- ================================================================
-- Exercise 1:
-- Calculate the length (duration) of each taxi ride using pickup
-- and drop-off timestamps. Sort from longest to shortest.
-- ================================================================

SET timezone TO 'US/Eastern';

SELECT
    trip_id,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    tpep_dropoff_datetime - tpep_pickup_datetime AS trip_duration
FROM nyc_yellow_taxi_trips_2016_06_01
ORDER BY trip_duration DESC;

-- NOTE: Inspect the longest and shortest results — you may notice
-- some extreme outliers (very long or negative durations) that
-- suggest data entry errors worth asking city officials about.


-- ================================================================
-- Exercise 2:
-- Show what date and time it is in London, Johannesburg, Moscow,
-- and Melbourne at the moment New Year's 2100 arrives in New York.
-- ================================================================

SELECT
    '2100-01-01 00:00:00' AT TIME ZONE 'US/Eastern' AS "New York (midnight)",
    '2100-01-01 00:00:00' AT TIME ZONE 'US/Eastern' AT TIME ZONE 'Europe/London'      AS "London",
    '2100-01-01 00:00:00' AT TIME ZONE 'US/Eastern' AT TIME ZONE 'Africa/Johannesburg' AS "Johannesburg",
    '2100-01-01 00:00:00' AT TIME ZONE 'US/Eastern' AT TIME ZONE 'Europe/Moscow'       AS "Moscow",
    '2100-01-01 00:00:00' AT TIME ZONE 'US/Eastern' AT TIME ZONE 'Australia/Melbourne' AS "Melbourne";


-- ================================================================
-- Exercise 3 (BONUS):
-- Use statistics functions from Chapter 10 to calculate:
-- 1. Correlation and r-squared of trip duration vs total_amount
-- 2. Correlation and r-squared of trip_distance vs total_amount
-- Limit to rides lasting 3 hours or less.
-- ================================================================

SET timezone TO 'US/Eastern';

SELECT
    round(corr(
        total_amount,
        date_part('epoch', tpep_dropoff_datetime - tpep_pickup_datetime)
    )::numeric, 3) AS trip_time_total_r,

    round(regr_r2(
        total_amount,
        date_part('epoch', tpep_dropoff_datetime - tpep_pickup_datetime)
    )::numeric, 3) AS trip_time_total_r2,

    round(corr(
        total_amount,
        trip_distance
    )::numeric, 3) AS trip_dist_total_r,

    round(regr_r2(
        total_amount,
        trip_distance
    )::numeric, 3) AS trip_dist_total_r2
FROM nyc_yellow_taxi_trips_2016_06_01
WHERE (tpep_dropoff_datetime - tpep_pickup_datetime) <= '3 hours'::interval;
```

All `--` comment markers were removed from the executable lines, while keeping the descriptive comments (exercise headers and the NOTE) intact since those are documentation, not commented-out code.