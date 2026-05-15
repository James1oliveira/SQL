Chapter 8 covers summary functions (`count()`, `sum()`, `max()`, `min()`) and `GROUP BY` to 
analyze data, 
using U.S. library visits as the example. The key lesson: group your data,
 watch for dirty values, and use `HAVING` (not `WHERE`) to filter grouped results.
 
 -- ================================================================
-- CHAPTER 8: Extracting Information by Grouping and Summarizing
-- TRY IT YOURSELF - EXERCISES
-- ================================================================


-- ----------------------------------------------------------------
-- Exercise 1:
-- Calculate the percent change in the sum of gpterms
-- (internet-connected computers) and pitusr (public computer uses)
-- between 2009 and 2014, grouped by state.
-- Remember to exclude negative placeholder values.
-- ----------------------------------------------------------------

SELECT pls14.stabr,
       sum(pls14.gpterms) AS gpterms_2014,
       sum(pls09.gpterms) AS gpterms_2009,
       round((CAST(sum(pls14.gpterms) AS decimal(10,1)) - sum(pls09.gpterms))
             / sum(pls09.gpterms) * 100, 2) AS pct_change_gpterms,
       sum(pls14.pitusr) AS pitusr_2014,
       sum(pls09.pitusr) AS pitusr_2009,
       round((CAST(sum(pls14.pitusr) AS decimal(10,1)) - sum(pls09.pitusr))
             / sum(pls09.pitusr) * 100, 2) AS pct_change_pitusr
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.gpterms >= 0 AND pls09.gpterms >= 0
AND pls14.pitusr >= 0 AND pls09.pitusr >= 0
GROUP BY pls14.stabr
ORDER BY pct_change_pitusr DESC;


-- ----------------------------------------------------------------
-- Exercise 2:
-- Calculate percent change in visits grouped by U.S. region
-- using the obereg column.
-- Bonus: create a lookup table and join it for region names.
-- ----------------------------------------------------------------

Basic version (shows region codes):

SELECT pls14.obereg,
       sum(pls14.visits) AS visits_2014,
       sum(pls09.visits) AS visits_2009,
       round((CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits))
             / sum(pls09.visits) * 100, 2) AS pct_change
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.visits >= 0 AND pls09.visits >= 0
GROUP BY pls14.obereg
ORDER BY pct_change DESC;



Bonus: Create region lookup table and join it:

CREATE TABLE obereg_codes (
    obereg varchar(2) CONSTRAINT obereg_key PRIMARY KEY,
    region varchar(50) NOT NULL
);

INSERT INTO obereg_codes (obereg, region)
VALUES ('01', 'New England'),
       ('02', 'Mid East'),
       ('03', 'Great Lakes'),
       ('04', 'Plains'),
       ('05', 'Southeast'),
       ('06', 'Southwest'),
       ('07', 'Rocky Mountains'),
       ('08', 'Far West'),
       ('09', 'Outlying Areas');

SELECT ob.region,
       sum(pls14.visits) AS visits_2014,
       sum(pls09.visits) AS visits_2009,
       round((CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits))
             / sum(pls09.visits) * 100, 2) AS pct_change
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
JOIN obereg_codes ob ON pls14.obereg = ob.obereg
WHERE pls14.visits >= 0 AND pls09.visits >= 0
GROUP BY ob.region
ORDER BY pct_change DESC;


-- ----------------------------------------------------------------
-- Exercise 3:
-- Use a FULL OUTER JOIN to show all rows from both tables,
-- then add IS NULL to find agencies not in one or the other.
-- ----------------------------------------------------------------

SELECT pls14.libname AS name_2014,
       pls09.libname AS name_2009,
       pls14.fscskey AS key_2014,
       pls09.fscskey AS key_2009
FROM pls_fy2014_pupld14a pls14
FULL OUTER JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.fscskey IS NULL OR pls09.fscskey IS NULL;
