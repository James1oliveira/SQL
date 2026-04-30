-- ================================================================
-- CHAPTER 10: Statistical Functions in SQL
-- TRY IT YOURSELF - EXERCISES
-- ================================================================


-- ================================================================
-- Exercise 1:
-- Find the correlation between pct_masters_higher and median_hh_income.
-- Is the r value higher or lower than pct_bachelors_higher (~0.68)?
-- ================================================================

-- SELECT round(
--     corr(median_hh_income, pct_masters_higher)::numeric, 2
-- ) AS masters_income_r
-- FROM acs_2011_2015_stats;

-- Expected: r value is slightly HIGHER (~0.70)
-- Reason: Master's degree holders tend to earn more than bachelor's only,
-- so the relationship between advanced education and income is stronger.


-- ================================================================
-- Exercise 2a:
-- Which cities (500k+ pop) have the highest motor vehicle theft rates?
-- ================================================================

-- SELECT
--     city,
--     st,
--     population,
--     motor_vehicle_theft,
--     round(
--         (motor_vehicle_theft::numeric / population) * 1000, 1
--     ) AS vehicle_theft_per_1000
-- FROM fbi_crime_data_2015
-- WHERE population >= 500000
-- ORDER BY vehicle_theft_per_1000 DESC;


-- ================================================================
-- Exercise 2b:
-- Which cities (500k+ pop) have the highest violent crime rates?
-- ================================================================

-- SELECT
--     city,
--     st,
--     population,
--     violent_crime,
--     round(
--         (violent_crime::numeric / population) * 1000, 1
--     ) AS violent_crime_per_1000
-- FROM fbi_crime_data_2015
-- WHERE population >= 500000
-- ORDER BY violent_crime_per_1000 DESC;


-- ================================================================
-- Exercise 3 (BONUS):
-- Rank library agencies (250k+ population served) by visit rate
-- per 1,000 population using pls_fy2014_pupld14a from Chapter 8.
-- Column popu_lsa = population served; visits = annual visits.
-- ================================================================

-- SELECT
--     libname,
--     stabr,
--     city,
--     popu_lsa,
--     visits,
--     round(
--         (visits::numeric / popu_lsa) * 1000, 1
--     ) AS visits_per_1000,
--     rank() OVER (ORDER BY (visits::numeric / popu_lsa) DESC) AS rank
-- FROM pls_fy2014_pupld14a
-- WHERE popu_lsa >= 250000
--   AND visits >= 0
-- ORDER BY visits_per_1000 DESC;
