-- ================================================================
-- CHAPTER 10: Statistical Functions in SQL
-- MAIN CODE
-- File paths set to: C:\SQL\
-- ================================================================
-- NOTE: Download from https://www.nostarch.com/practicalSQL/
--   acs_2011_2015_stats.csv
--   fbi_crime_data_2015.csv


-- ================================================================
-- LISTING 10-1: Create and import the Census ACS stats table
-- ================================================================

-- CREATE TABLE acs_2011_2015_stats (
--     geoid varchar(14) CONSTRAINT geoid_key PRIMARY KEY,
--     county varchar(50) NOT NULL,
--     st varchar(20) NOT NULL,
--     pct_travel_60_min numeric(5,3) NOT NULL,
--     pct_bachelors_higher numeric(5,3) NOT NULL,
--     pct_masters_higher numeric(5,3) NOT NULL,
--     median_hh_income integer,
--     CHECK (pct_masters_higher <= pct_bachelors_higher)
-- );

-- COPY acs_2011_2015_stats
-- FROM 'C:\SQL\acs_2011_2015_stats.csv'
-- WITH (FORMAT CSV, HEADER, DELIMITER ',');

-- SELECT * FROM acs_2011_2015_stats;


-- ================================================================
-- LISTING 10-2: corr(Y, X) — Correlation between education and income
-- ================================================================

-- SELECT corr(median_hh_income, pct_bachelors_higher)
--        AS bachelors_income_r
-- FROM acs_2011_2015_stats;
-- Expected result: ~0.682 (strong positive correlation)


-- ================================================================
-- LISTING 10-3: corr() on additional variable pairs
-- ================================================================

-- SELECT
--     round(corr(median_hh_income, pct_bachelors_higher)::numeric, 2)
--         AS bachelors_income_r,
--     round(corr(pct_travel_60_min, median_hh_income)::numeric, 2)
--         AS income_travel_r,
--     round(corr(pct_travel_60_min, pct_bachelors_higher)::numeric, 2)
--         AS bachelors_travel_r
-- FROM acs_2011_2015_stats;


-- ================================================================
-- LISTING 10-4: Regression slope and y-intercept
-- ================================================================

-- SELECT
--     round(regr_slope(median_hh_income, pct_bachelors_higher)::numeric, 2)
--         AS slope,
--     round(regr_intercept(median_hh_income, pct_bachelors_higher)::numeric, 2)
--         AS y_intercept
-- FROM acs_2011_2015_stats;
-- Interpret: For every 1% increase in bachelor's degrees,
-- median household income increases by ~$927.


-- ================================================================
-- LISTING 10-5: r-squared (coefficient of determination)
-- ================================================================

-- SELECT round(
--     regr_r2(median_hh_income, pct_bachelors_higher)::numeric, 3
-- ) AS r_squared
-- FROM acs_2011_2015_stats;
-- Result: ~0.465 → education explains ~47% of income variation


-- ================================================================
-- LISTING 10-6: rank() and dense_rank() window functions
-- ================================================================

-- CREATE TABLE widget_companies (
--     id bigserial,
--     company varchar(30) NOT NULL,
--     widget_output integer NOT NULL
-- );

-- INSERT INTO widget_companies (company, widget_output)
-- VALUES
--     ('Morse Widgets', 125000),
--     ('Springfield Widget Masters', 143000),
--     ('Best Widgets', 196000),
--     ('Acme Inc.', 133000),
--     ('District Widget Inc.', 201000),
--     ('Clarke Amalgamated', 620000),
--     ('Stavesacre Industries', 244000),
--     ('Bowers Widget Emporium', 201000);

-- SELECT
--     company,
--     widget_output,
--     rank() OVER (ORDER BY widget_output DESC),
--     dense_rank() OVER (ORDER BY widget_output DESC)
-- FROM widget_companies;
-- rank() leaves a gap after a tie; dense_rank() does not.


-- ================================================================
-- LISTING 10-7: rank() with PARTITION BY (rank within groups)
-- ================================================================

-- CREATE TABLE store_sales (
--     store varchar(30),
--     category varchar(30) NOT NULL,
--     unit_sales bigint NOT NULL,
--     CONSTRAINT store_category_key PRIMARY KEY (store, category)
-- );

-- INSERT INTO store_sales (store, category, unit_sales)
-- VALUES
--     ('Broders', 'Cereal', 1104),
--     ('Wallace', 'Ice Cream', 1863),
--     ('Broders', 'Ice Cream', 2517),
--     ('Cramers', 'Ice Cream', 2112),
--     ('Broders', 'Beer', 641),
--     ('Cramers', 'Cereal', 1003),
--     ('Cramers', 'Beer', 640),
--     ('Wallace', 'Cereal', 980),
--     ('Wallace', 'Beer', 988);

-- SELECT
--     category,
--     store,
--     unit_sales,
--     rank() OVER (PARTITION BY category ORDER BY unit_sales DESC)
-- FROM store_sales;


-- ================================================================
-- LISTING 10-8: Create and import the 2015 FBI crime data table
-- ================================================================

-- CREATE TABLE fbi_crime_data_2015 (
--     st varchar(20),
--     city varchar(50),
--     population integer,
--     violent_crime integer,
--     property_crime integer,
--     burglary integer,
--     larceny_theft integer,
--     motor_vehicle_theft integer,
--     CONSTRAINT st_city_key PRIMARY KEY (st, city)
-- );

-- COPY fbi_crime_data_2015
-- FROM 'C:\SQL\fbi_crime_data_2015.csv'
-- WITH (FORMAT CSV, HEADER, DELIMITER ',');

-- SELECT * FROM fbi_crime_data_2015
-- ORDER BY population DESC;


-- ================================================================
-- LISTING 10-9: Property crime rate per 1,000 people (cities 500k+)
-- ================================================================

-- SELECT
--     city,
--     st,
--     population,
--     property_crime,
--     round(
--         (property_crime::numeric / population) * 1000, 1
--     ) AS pc_per_1000
-- FROM fbi_crime_data_2015
-- WHERE population >= 500000
-- ORDER BY (property_crime::numeric / population) DESC;
