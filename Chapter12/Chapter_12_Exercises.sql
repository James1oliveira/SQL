-- ================================================================
-- CHAPTER 12: Advanced Query Techniques
-- TRY IT YOURSELF - EXERCISES
-- Data files: C:\SQL\
-- ================================================================
-- Requires: temperature_readings and ice_cream_survey tables
-- (created in Chapter_12_Code.sql)


-- ================================================================
-- EXERCISE 1 (Listing 12-15 revised)
-- Revise the CTE from Listing 12-15 to focus only on Waikiki.
-- Reclassify Waikiki's max daily temperatures into 7 groups
-- and count how many days fall into each group.
-- ================================================================

WITH temps_collapsed (station_name, max_temperature_group) AS
    (SELECT station_name,
            CASE WHEN max_temp >= 90             THEN '90 or more'
                 WHEN max_temp BETWEEN 88 AND 89 THEN '88-89'
                 WHEN max_temp BETWEEN 86 AND 87 THEN '86-87'
                 WHEN max_temp BETWEEN 84 AND 85 THEN '84-85'
                 WHEN max_temp BETWEEN 82 AND 83 THEN '82-83'
                 WHEN max_temp BETWEEN 80 AND 81 THEN '80-81'
                 ELSE '79 or less'
            END
     FROM temperature_readings
     WHERE station_name = 'WAIKIKI 717.2 HI US')   -- Waikiki only
SELECT station_name,
       max_temperature_group,
       count(*) AS frequency
FROM temps_collapsed
GROUP BY station_name, max_temperature_group
ORDER BY frequency DESC;


-- ================================================================
-- EXERCISE 2 (Listing 12-11 revised)
-- Flip the ice cream survey crosstab so that:
--   Rows    = flavor
--   Columns = office (Downtown, Midtown, Uptown)
-- Changes needed vs. Listing 12-11:
--   1. Swap the first two columns in the data subquery
--      (flavor first, then office — flavor becomes the row label)
--   2. Update the second subquery to return distinct offices
--   3. Update the AS column list to match the new layout
-- ================================================================

SELECT *
FROM crosstab('SELECT flavor,
                      office,
                      count(*)
               FROM ice_cream_survey
               GROUP BY flavor, office
               ORDER BY flavor',
              'SELECT DISTINCT office
               FROM ice_cream_survey
               ORDER BY office')
AS (flavor     varchar(20),
    downtown   bigint,
    midtown    bigint,
    uptown     bigint);