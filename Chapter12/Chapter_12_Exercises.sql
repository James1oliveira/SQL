-- ================================================================
-- CHAPTER 12: Advanced Query Techniques
-- TRY IT YOURSELF - EXERCISES
-- ================================================================
-- Requires: us_counties_2010 and pls_fy2014_pupld14a tables


-- ----------------------------------------------------------------
-- Exercise 1:
-- Using a CTE, find all counties where the population is at or
-- above the 90th percentile FOR THEIR OWN STATE.
-- Each state's 90th percentile is calculated separately.
-- Show: county name, state, population, and the state's 90th percentile.
-- ----------------------------------------------------------------

-- WITH county_pcts AS (
--     SELECT state_us_abbreviation AS st,
--            percentile_cont(.9)
--                WITHIN GROUP (ORDER BY p0010001) AS pct_90
--     FROM us_counties_2010
--     GROUP BY state_us_abbreviation
-- )
-- SELECT c.geo_name,
--        c.state_us_abbreviation AS st,
--        c.p0010001 AS pop,
--        cp.pct_90
-- FROM us_counties_2010 c
-- JOIN county_pcts cp
--     ON c.state_us_abbreviation = cp.st
-- WHERE c.p0010001 >= cp.pct_90
-- ORDER BY st, pop DESC;


-- ----------------------------------------------------------------
-- Exercise 2:
-- Using a CTE and the 2014 library survey, find all agencies
-- whose visit count is BELOW their own state's median.
-- Show: library name, state, visits, and the state's median.
-- Exclude negative visit values.
-- ----------------------------------------------------------------

-- WITH state_median AS (
--     SELECT stabr,
--            percentile_cont(.5)
--                WITHIN GROUP (ORDER BY visits) AS median_visits
--     FROM pls_fy2014_pupld14a
--     WHERE visits >= 0
--     GROUP BY stabr
-- )
-- SELECT p.libname,
--        p.stabr,
--        p.visits,
--        sm.median_visits
-- FROM pls_fy2014_pupld14a p
-- JOIN state_median sm ON p.stabr = sm.stabr
-- WHERE p.visits < sm.median_visits
--   AND p.visits >= 0
-- ORDER BY p.stabr, p.visits DESC;


-- ----------------------------------------------------------------
-- Exercise 3:
-- Use a CASE statement inside sum() to count counties by
-- population size class (large/medium/small) PER STATE.
-- Large  = 100,000 or more
-- Medium = 25,000 to 99,999
-- Small  = under 25,000
-- ----------------------------------------------------------------

-- SELECT state_us_abbreviation AS st,
--        sum(CASE WHEN p0010001 >= 100000
--                 THEN 1 ELSE 0 END) AS large,
--        sum(CASE WHEN p0010001 BETWEEN 25000 AND 99999
--                 THEN 1 ELSE 0 END) AS medium,
--        sum(CASE WHEN p0010001 < 25000
--                 THEN 1 ELSE 0 END) AS small
-- FROM us_counties_2010
-- GROUP BY state_us_abbreviation
-- ORDER BY state_us_abbreviation;

-- This technique is called conditional aggregation.
-- CASE returns 1 when the condition is true, 0 when false.
-- sum() adds up the 1s to get a count per category.
