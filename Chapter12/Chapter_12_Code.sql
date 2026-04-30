-- ================================================================
-- CHAPTER 12: Advanced Query Techniques
-- MAIN CODE + EXERCISES
-- Data files: C:\SQL\
-- ================================================================
-- REQUIRED FILE (download from nostarch.com):
--   temperature_data.csv  (or use the INSERT statements below)


-- ================================================================
-- Subqueries
-- ================================================================

-- Subquery in WHERE clause (counties with above-average population):
-- SELECT geo_name, state_us_abbreviation AS st, p0010001 AS pop
-- FROM us_counties_2010
-- WHERE p0010001 >= (SELECT percentile_cont(.9) WITHIN GROUP
--                   (ORDER BY p0010001) FROM us_counties_2010)
-- ORDER BY p0010001 DESC;

-- Subquery as a derived table in FROM clause:
-- SELECT round(calcs.average, 0) AS average,
--        calcs.median,
--        round(calcs.average - calcs.median, 0) AS median_average_diff
-- FROM (SELECT avg(p0010001) AS average,
--              percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)::numeric AS median
--       FROM us_counties_2010) AS calcs;

-- Subquery as a column in SELECT:
-- SELECT geo_name,
--        state_us_abbreviation AS st,
--        p0010001 AS total_pop,
--        (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
--         FROM us_counties_2010) AS us_median
-- FROM us_counties_2010;

-- Subquery with column math:
-- SELECT geo_name,
--        state_us_abbreviation AS st,
--        p0010001 AS total_pop,
--        (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
--         FROM us_counties_2010) AS us_median,
--        p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
--                    FROM us_counties_2010) AS diff_from_median
-- FROM us_counties_2010
-- WHERE (p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
--                    FROM us_counties_2010)) BETWEEN -1000 AND 1000;


-- ================================================================
-- Common Table Expressions (CTE)
-- ================================================================

-- Simple CTE:
-- WITH large_counties (geo_name, st, pop) AS (
--     SELECT geo_name, state_us_abbreviation, p0010001
--     FROM us_counties_2010 WHERE p0010001 >= 100000
-- )
-- SELECT st, count(*) FROM large_counties GROUP BY st ORDER BY count(*) DESC;

-- CTE rewriting the derived table example:
-- WITH us_median AS (
--     SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)::numeric AS us_median_pop
--     FROM us_counties_2010
-- )
-- SELECT geo_name,
--        state_us_abbreviation AS st,
--        p0010001 AS total_pop,
--        us_median_pop,
--        p0010001 - us_median_pop AS diff_from_median
-- FROM us_counties_2010 CROSS JOIN us_median
-- WHERE (p0010001 - us_median_pop) BETWEEN -1000 AND 1000;


-- ================================================================
-- Cross Tabulations (crosstab)
-- ================================================================

-- Enable tablefunc module first:
-- CREATE EXTENSION tablefunc;

-- Temperature data table:
-- CREATE TABLE ice_cream_survey (
--     response_id integer PRIMARY KEY,
--     office varchar(20),
--     flavor varchar(20)
-- );
-- INSERT INTO ice_cream_survey VALUES
--     (1,'Downtown','Chocolate'),(2,'Downtown','Chocolate'),
--     (3,'Downtown','Strawberry'),(4,'Midtown','Chocolate'),
--     (5,'Midtown','Strawberry'),(6,'Midtown','Vanilla'),
--     (7,'Uptown','Vanilla'),(8,'Uptown','Vanilla'),
--     (9,'Uptown','Chocolate');

-- Crosstab of flavor votes by office:
-- SELECT *
-- FROM crosstab('SELECT office, flavor, count(*) FROM ice_cream_survey
--                GROUP BY office, flavor ORDER BY office',
--               'SELECT DISTINCT flavor FROM ice_cream_survey ORDER BY flavor')
-- AS (office varchar(20), chocolate bigint, strawberry bigint, vanilla bigint);


-- ================================================================
-- CASE Statement
-- ================================================================

-- Reclassify census population into groups:
-- SELECT geo_name, state_us_abbreviation AS st, p0010001 AS pop,
--        CASE WHEN p0010001 >= 100000 THEN 'large'
--             WHEN p0010001 BETWEEN 25000 AND 99999 THEN 'medium'
--             ELSE 'small' END AS pop_class
-- FROM us_counties_2010
-- ORDER BY state_us_abbreviation, geo_name;

-- CASE in WHERE clause:
-- SELECT geo_name, state_us_abbreviation AS st, p0010001 AS pop
-- FROM us_counties_2010
-- WHERE CASE WHEN state_us_abbreviation = 'NY' THEN p0010001 >= 100000
--            WHEN state_us_abbreviation = 'CA' THEN p0010001 >= 200000
--            ELSE p0010001 >= 50000 END
-- ORDER BY state_us_abbreviation, geo_name;


-- ================================================================
-- CHAPTER 12: Try It Yourself Exercises
-- ================================================================

-- Exercise 1: Using a CTE, find counties with population in the
-- 90th percentile for their state.
-- WITH county_pcts AS (
--     SELECT state_us_abbreviation AS st,
--            percentile_cont(.9) WITHIN GROUP (ORDER BY p0010001) AS pct_90
--     FROM us_counties_2010 GROUP BY state_us_abbreviation
-- )
-- SELECT c.geo_name, c.state_us_abbreviation AS st, c.p0010001 AS pop, cp.pct_90
-- FROM us_counties_2010 c JOIN county_pcts cp ON c.state_us_abbreviation = cp.st
-- WHERE c.p0010001 >= cp.pct_90
-- ORDER BY st, pop DESC;


-- Exercise 2: Using a CTE and the 2014 library data, find agencies
-- where the number of visits is below the state median.
-- WITH state_median AS (
--     SELECT stabr,
--            percentile_cont(.5) WITHIN GROUP (ORDER BY visits) AS median_visits
--     FROM pls_fy2014_pupld14a WHERE visits >= 0 GROUP BY stabr
-- )
-- SELECT p.libname, p.stabr, p.visits, sm.median_visits
-- FROM pls_fy2014_pupld14a p JOIN state_median sm ON p.stabr = sm.stabr
-- WHERE p.visits < sm.median_visits AND p.visits >= 0
-- ORDER BY p.stabr, p.visits DESC;


-- Exercise 3: Use CASE in a query to reclassify county populations
-- and count counties in each class per state.
-- SELECT state_us_abbreviation AS st,
--        sum(CASE WHEN p0010001 >= 100000 THEN 1 ELSE 0 END) AS large,
--        sum(CASE WHEN p0010001 BETWEEN 25000 AND 99999 THEN 1 ELSE 0 END) AS medium,
--        sum(CASE WHEN p0010001 < 25000 THEN 1 ELSE 0 END) AS small
-- FROM us_counties_2010
-- GROUP BY state_us_abbreviation ORDER BY state_us_abbreviation;
