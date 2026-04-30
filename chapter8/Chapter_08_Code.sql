-- ================================================================
-- CHAPTER 8: Extracting Information by Grouping and Summarizing
-- MAIN CODE
-- ================================================================


-- ----------------------------------------------------------------
-- Create the 2014 Library Survey Table (abbreviated)
-- Full version at: https://www.nostarch.com/practicalSQL/
-- ----------------------------------------------------------------

-- CREATE TABLE pls_fy2014_pupld14a (
--     stabr varchar(2) NOT NULL,
--     fscskey varchar(6) CONSTRAINT fscskey2014_key PRIMARY KEY,
--     libid varchar(20) NOT NULL,
--     libname varchar(100) NOT NULL,
--     obereg varchar(2) NOT NULL,
--     rstatus integer NOT NULL,
--     statstru varchar(2) NOT NULL,
--     statname varchar(2) NOT NULL,
--     stataddr varchar(2) NOT NULL,
--     -- snip: full table has 72 columns --
--     wifisess integer NOT NULL,
--     yr_sub integer NOT NULL
-- );

-- CREATE INDEX libname2014_idx ON pls_fy2014_pupld14a (libname);
-- CREATE INDEX stabr2014_idx ON pls_fy2014_pupld14a (stabr);
-- CREATE INDEX city2014_idx ON pls_fy2014_pupld14a (city);
-- CREATE INDEX visits2014_idx ON pls_fy2014_pupld14a (visits);

-- COPY pls_fy2014_pupld14a
-- FROM 'C:\SQL\pls_fy2014_pupld14a.csv'
-- WITH (FORMAT CSV, HEADER);


-- ----------------------------------------------------------------
-- Create the 2009 Library Survey Table (abbreviated)
-- ----------------------------------------------------------------

-- CREATE TABLE pls_fy2009_pupld09a (
--     stabr varchar(2) NOT NULL,
--     fscskey varchar(6) CONSTRAINT fscskey2009_key PRIMARY KEY,
--     libid varchar(20) NOT NULL,
--     libname varchar(100) NOT NULL,
--     address varchar(35) NOT NULL,
--     city varchar(20) NOT NULL,
--     zip varchar(5) NOT NULL,
--     zip4 varchar(4) NOT NULL,
--     cnty varchar(20) NOT NULL,
--     -- snip --
--     fipsst varchar(2) NOT NULL,
--     fipsco varchar(3) NOT NULL
-- );

-- CREATE INDEX libname2009_idx ON pls_fy2009_pupld09a (libname);
-- CREATE INDEX stabr2009_idx ON pls_fy2009_pupld09a (stabr);
-- CREATE INDEX city2009_idx ON pls_fy2009_pupld09a (city);
-- CREATE INDEX visits2009_idx ON pls_fy2009_pupld09a (visits);

-- COPY pls_fy2009_pupld09a
-- FROM 'C:\SQL\pls_fy2009_pupld09a.csv'
-- WITH (FORMAT CSV, HEADER);


-- ----------------------------------------------------------------
-- count() — Count Rows and Values
-- ----------------------------------------------------------------

-- Count all rows in each table:
-- SELECT count(*) FROM pls_fy2014_pupld14a;
-- SELECT count(*) FROM pls_fy2009_pupld09a;

-- Count rows where salaries column has a value (not NULL):
-- SELECT count(salaries) FROM pls_fy2014_pupld14a;

-- Count distinct library names:
-- SELECT count(libname) FROM pls_fy2014_pupld14a;
-- SELECT count(DISTINCT libname) FROM pls_fy2014_pupld14a;


-- ----------------------------------------------------------------
-- max() and min()
-- ----------------------------------------------------------------

-- Find the most and fewest visits (note: negative values are codes!):
-- SELECT max(visits), min(visits)
-- FROM pls_fy2014_pupld14a;


-- ----------------------------------------------------------------
-- GROUP BY
-- ----------------------------------------------------------------

-- Group by state abbreviation (no aggregation — like DISTINCT):
-- SELECT stabr
-- FROM pls_fy2014_pupld14a
-- GROUP BY stabr
-- ORDER BY stabr;

-- Group by city and state:
-- SELECT city, stabr
-- FROM pls_fy2014_pupld14a
-- GROUP BY city, stabr
-- ORDER BY city, stabr;

-- Count agencies by state (GROUP BY + count()):
-- SELECT stabr, count(*)
-- FROM pls_fy2014_pupld14a
-- GROUP BY stabr
-- ORDER BY count(*) DESC;

-- Count agencies per state per address-change status:
-- SELECT stabr, stataddr, count(*)
-- FROM pls_fy2014_pupld14a
-- GROUP BY stabr, stataddr
-- ORDER BY stabr ASC, count(*) DESC;


-- ----------------------------------------------------------------
-- sum() — Total Library Visits
-- ----------------------------------------------------------------

-- Total visits in 2014 (exclude negative placeholder values):
-- SELECT sum(visits) AS visits_2014
-- FROM pls_fy2014_pupld14a
-- WHERE visits >= 0;

-- Total visits in 2009:
-- SELECT sum(visits) AS visits_2009
-- FROM pls_fy2009_pupld09a
-- WHERE visits >= 0;

-- Total visits from JOINED tables (agencies in both years only):
-- SELECT sum(pls14.visits) AS visits_2014,
--        sum(pls09.visits) AS visits_2009
-- FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
-- ON pls14.fscskey = pls09.fscskey
-- WHERE pls14.visits >= 0 AND pls09.visits >= 0;


-- ----------------------------------------------------------------
-- GROUP BY with Percent Change (by state)
-- ----------------------------------------------------------------

-- SELECT pls14.stabr,
--        sum(pls14.visits) AS visits_2014,
--        sum(pls09.visits) AS visits_2009,
--        round((CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits))
--              / sum(pls09.visits) * 100, 2) AS pct_change
-- FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
-- ON pls14.fscskey = pls09.fscskey
-- WHERE pls14.visits >= 0 AND pls09.visits >= 0
-- GROUP BY pls14.stabr
-- ORDER BY pct_change DESC;


-- ----------------------------------------------------------------
-- HAVING — Filter on Aggregated Results
-- ----------------------------------------------------------------

-- Only show states with more than 50 million visits in 2014:
-- SELECT pls14.stabr,
--        sum(pls14.visits) AS visits_2014,
--        sum(pls09.visits) AS visits_2009,
--        round((CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits))
--              / sum(pls09.visits) * 100, 2) AS pct_change
-- FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
-- ON pls14.fscskey = pls09.fscskey
-- WHERE pls14.visits >= 0 AND pls09.visits >= 0
-- GROUP BY pls14.stabr
-- HAVING sum(pls14.visits) > 50000000
-- ORDER BY pct_change DESC;
