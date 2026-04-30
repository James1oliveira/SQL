-- ================================================================
-- CHAPTER 6: Joining Tables in a Relational Database
-- TRY IT YOURSELF - EXERCISES
-- ================================================================


-- ----------------------------------------------------------------
-- Exercise 1:
-- Identify counties that exist in one table but not both.
-- us_counties_2010 has 3,143 rows; us_counties_2000 has 3,141 rows.
-- Use a FULL OUTER JOIN and filter for NULL values to find mismatches.
-- ----------------------------------------------------------------

-- Counties in 2010 but NOT in 2000:
-- SELECT c2010.geo_name AS geo_2010,
--        c2010.state_us_abbreviation AS st,
--        c2000.geo_name AS geo_2000
-- FROM us_counties_2010 c2010 FULL OUTER JOIN us_counties_2000 c2000
-- ON c2010.state_fips = c2000.state_fips
-- AND c2010.county_fips = c2000.county_fips
-- WHERE c2000.geo_name IS NULL;

-- Counties in 2000 but NOT in 2010:
-- SELECT c2010.geo_name AS geo_2010,
--        c2000.geo_name AS geo_2000,
--        c2000.state_us_abbreviation AS st
-- FROM us_counties_2010 c2010 FULL OUTER JOIN us_counties_2000 c2000
-- ON c2010.state_fips = c2000.state_fips
-- AND c2010.county_fips = c2000.county_fips
-- WHERE c2010.geo_name IS NULL;


-- ----------------------------------------------------------------
-- Exercise 2:
-- Find the median percent change in county population
-- across all counties in both census tables.
-- ----------------------------------------------------------------

-- SELECT percentile_cont(.5)
--        WITHIN GROUP (ORDER BY
--            round((CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
--                  / c2000.p0010001 * 100, 1)
--        ) AS median_pct_change
-- FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
-- ON c2010.state_fips = c2000.state_fips
-- AND c2010.county_fips = c2000.county_fips
-- AND c2010.p0010001 <> c2000.p0010001;


-- ----------------------------------------------------------------
-- Exercise 3:
-- Find the county with the greatest percentage LOSS of population
-- between 2000 and 2010.
-- (Hint: A major hurricane hit the Gulf Coast in 2005)
-- ----------------------------------------------------------------

-- SELECT c2010.geo_name,
--        c2010.state_us_abbreviation AS state,
--        c2010.p0010001 AS pop_2010,
--        c2000.p0010001 AS pop_2000,
--        round((CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
--              / c2000.p0010001 * 100, 1) AS pct_change
-- FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
-- ON c2010.state_fips = c2000.state_fips
-- AND c2010.county_fips = c2000.county_fips
-- AND c2010.p0010001 <> c2000.p0010001
-- ORDER BY pct_change ASC
-- LIMIT 5;
