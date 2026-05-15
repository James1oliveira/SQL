-- ================================================================
-- CHAPTER 8: Extracting Information by Grouping and Summarizing
-- Practical SQL by Anthony DeBarros
-- ================================================================


-- ----------------------------------------------------------------
-- Listing 8-1: Create and fill the 2014 Public Libraries Survey table
-- ----------------------------------------------------------------

CREATE TABLE pls_fy2014_pupld14a (
    stabr varchar(2) NOT NULL,
    fscskey varchar(6) CONSTRAINT fscskey2014_key PRIMARY KEY,
    libid varchar(20) NOT NULL,
    libname varchar(100) NOT NULL,
    obereg varchar(2) NOT NULL,
    rstatus integer NOT NULL,
    statstru varchar(2) NOT NULL,
    statname varchar(2) NOT NULL,
    stataddr varchar(2) NOT NULL,
    longitud numeric(10,7) NOT NULL,
    latitude numeric(10,7) NOT NULL,
    fipsst varchar(2) NOT NULL,
    fipsco varchar(3) NOT NULL,
    address varchar(35) NOT NULL,
    city varchar(20) NOT NULL,
    zip varchar(5) NOT NULL,
    zip4 varchar(4) NOT NULL,
    cnty varchar(20) NOT NULL,
    phone varchar(10) NOT NULL,
    c_relatn varchar(2) NOT NULL,
    c_legbas varchar(2) NOT NULL,
    c_admin varchar(2) NOT NULL,
    geocode varchar(3) NOT NULL,
    lsabound varchar(1) NOT NULL,
    startdat varchar(10),
    enddate varchar(10),
    popu_lsa integer NOT NULL,
    centlib integer NOT NULL,
    branlib integer NOT NULL,
    bkmob integer NOT NULL,
    master numeric(8,2) NOT NULL,
    libraria numeric(8,2) NOT NULL,
    totstaff numeric(8,2) NOT NULL,
    locgvt integer NOT NULL,
    stgvt integer NOT NULL,
    fedgvt integer NOT NULL,
    totincm integer NOT NULL,
    salaries integer,
    benefit integer,
    staffexp integer,
    prmatexp integer NOT NULL,
    elmatexp integer NOT NULL,
    totexpco integer NOT NULL,
    totopexp integer NOT NULL,
    lcap_rev integer NOT NULL,
    scap_rev integer NOT NULL,
    fcap_rev integer NOT NULL,
    cap_rev integer NOT NULL,
    capital integer NOT NULL,
    bkvol integer NOT NULL,
    ebook integer NOT NULL,
    audio_ph integer NOT NULL,
    audio_dl float NOT NULL,
    video_ph integer NOT NULL,
    video_dl float NOT NULL,
    databases integer NOT NULL,
    subscrip integer NOT NULL,
    hrs_open integer NOT NULL,
    visits integer NOT NULL,
    referenc integer NOT NULL,
    regbor integer NOT NULL,
    totcir integer NOT NULL,
    kidcircl integer NOT NULL,
    elmatcir integer NOT NULL,
    loanto integer NOT NULL,
    loanfm integer NOT NULL,
    totpro integer NOT NULL,
    totatten integer NOT NULL,
    gpterms integer NOT NULL,
    pitusr integer NOT NULL,
    wifisess integer NOT NULL,
    yr_sub integer NOT NULL
);

CREATE INDEX libname2014_idx ON pls_fy2014_pupld14a (libname);
CREATE INDEX stabr2014_idx ON pls_fy2014_pupld14a (stabr);
CREATE INDEX city2014_idx ON pls_fy2014_pupld14a (city);
CREATE INDEX visits2014_idx ON pls_fy2014_pupld14a (visits);

-- PATH FIXED: files are in C:\SQL\ directly
COPY pls_fy2014_pupld14a
FROM 'C:\SQL\pls_fy2014_pupld14a.csv'
WITH (FORMAT CSV, HEADER);


-- ----------------------------------------------------------------
-- Listing 8-2: Create and fill the 2009 Public Libraries Survey table
-- ----------------------------------------------------------------
DROP TABLE IF EXISTS pls_fy2009_pupld09a;

CREATE TABLE pls_fy2009_pupld09a (
    stabr varchar(2) NOT NULL,
    fscskey varchar(6) CONSTRAINT fscskey2009_key PRIMARY KEY,
    libid varchar(20) NOT NULL,
    libname varchar(100) NOT NULL,
    address varchar(35) NOT NULL,
    city varchar(20) NOT NULL,
    zip varchar(5) NOT NULL,
    zip4 varchar(4) NOT NULL,
    cnty varchar(20) NOT NULL,
    phone varchar(10) NOT NULL,
    c_relatn varchar(2) NOT NULL,
    c_legbas varchar(2) NOT NULL,
    c_admin varchar(2) NOT NULL,
    geocode varchar(3) NOT NULL,
    lsabound varchar(1) NOT NULL,
    startdat varchar(10),
    enddate varchar(10),
    popu_lsa integer NOT NULL,
    centlib integer NOT NULL,
    branlib integer NOT NULL,
    bkmob integer NOT NULL,
    master numeric(8,2) NOT NULL,
    libraria numeric(8,2) NOT NULL,
    totstaff numeric(8,2) NOT NULL,
    locgvt integer NOT NULL,
    stgvt integer NOT NULL,
    fedgvt integer NOT NULL,
    totincm integer NOT NULL,
    salaries integer,
    benefit integer,
    staffexp integer,
    prmatexp integer NOT NULL,
    elmatexp integer NOT NULL,
    totexpco integer NOT NULL,
    totopexp integer NOT NULL,
    lcap_rev integer NOT NULL,
    scap_rev integer NOT NULL,
    fcap_rev integer NOT NULL,
    cap_rev integer NOT NULL,
    capital integer NOT NULL,
    bkvol integer NOT NULL,
    ebook integer NOT NULL,
    audio integer NOT NULL,
    video integer NOT NULL,
    databases integer NOT NULL,
    subscrip integer NOT NULL,
    hrs_open integer NOT NULL,
    visits integer NOT NULL,
    referenc integer NOT NULL,
    regbor integer NOT NULL,
    totcir integer NOT NULL,
    kidcircl integer NOT NULL,
    loanto integer NOT NULL,
    loanfm integer NOT NULL,
    totpro integer NOT NULL,
    totatten integer NOT NULL,
    gpterms integer NOT NULL,
    pitusr integer NOT NULL,
    yr_sub integer NOT NULL,
    obereg varchar(2) NOT NULL,
    rstatus integer NOT NULL,
    statstru varchar(2) NOT NULL,
    statname varchar(2) NOT NULL,
    stataddr varchar(2) NOT NULL,
    longitud numeric(10,7) NOT NULL,
    latitude numeric(10,7) NOT NULL,
    fipsst varchar(2) NOT NULL,
    fipsco varchar(3) NOT NULL
);

CREATE INDEX libname2009_idx ON pls_fy2009_pupld09a (libname);
CREATE INDEX stabr2009_idx ON pls_fy2009_pupld09a (stabr);
CREATE INDEX city2009_idx ON pls_fy2009_pupld09a (city);
CREATE INDEX visits2009_idx ON pls_fy2009_pupld09a (visits);

-- PATH FIXED: files are in C:\SQL\ directly
COPY pls_fy2009_pupld09a
FROM 'C:\SQL\pls_fy2009_pupld09a.csv'
WITH (FORMAT CSV, HEADER);


-- ----------------------------------------------------------------
-- Listing 8-3: count() -- row counts for both tables
-- ----------------------------------------------------------------

SELECT count(*) FROM pls_fy2014_pupld14a;
-- Expected: 9305

SELECT count(*) FROM pls_fy2009_pupld09a;
-- Expected: 9299


-- ----------------------------------------------------------------
-- Listing 8-4: count() -- rows with a value in salaries column
-- ----------------------------------------------------------------

SELECT count(salaries)
FROM pls_fy2014_pupld14a;
-- Expected: 5983


-- ----------------------------------------------------------------
-- Listing 8-5: count() with DISTINCT -- distinct library names
-- ----------------------------------------------------------------

SELECT count(libname)
FROM pls_fy2014_pupld14a;
-- Expected: 9305

SELECT count(DISTINCT libname)
FROM pls_fy2014_pupld14a;
-- Expected: 8515


-- ----------------------------------------------------------------
-- Listing 8-6: max() and min() on visits
-- Note: negative values (-1, -3) are survey placeholder codes,
-- NOT real visit counts. Filter them out in analysis queries.
-- ----------------------------------------------------------------

SELECT max(visits), min(visits)
FROM pls_fy2014_pupld14a;
-- max: 17729020  |  min: -3


-- ----------------------------------------------------------------
-- Listing 8-7: GROUP BY on a single column (state abbreviation)
-- ----------------------------------------------------------------

SELECT stabr
FROM pls_fy2014_pupld14a
GROUP BY stabr
ORDER BY stabr;
-- Returns 56 unique state/territory codes


-- ----------------------------------------------------------------
-- Listing 8-8: GROUP BY on multiple columns (city + state)
-- ----------------------------------------------------------------

SELECT city, stabr
FROM pls_fy2014_pupld14a
GROUP BY city, stabr
ORDER BY city, stabr;


-- ----------------------------------------------------------------
-- Listing 8-9: GROUP BY with count() -- agency count per state
-- ----------------------------------------------------------------

SELECT stabr, count(*)
FROM pls_fy2014_pupld14a
GROUP BY stabr
ORDER BY count(*) DESC;


-- ----------------------------------------------------------------
-- Listing 8-10: GROUP BY with count() on two columns
-- (state + address-change status code)
-- ----------------------------------------------------------------

SELECT stabr, stataddr, count(*)
FROM pls_fy2014_pupld14a
GROUP BY stabr, stataddr
ORDER BY stabr ASC, count(*) DESC;


-- ----------------------------------------------------------------
-- Listing 8-11: sum() -- total library visits per year
-- (filter out negative placeholder values)
-- ----------------------------------------------------------------

SELECT sum(visits) AS visits_2014
FROM pls_fy2014_pupld14a
WHERE visits >= 0;
-- Expected: 1425930900

SELECT sum(visits) AS visits_2009
FROM pls_fy2009_pupld09a
WHERE visits >= 0;
-- Expected: 1591799201


-- ----------------------------------------------------------------
-- Listing 8-12: sum() on JOINED tables
-- (only agencies present in BOTH years)
-- ----------------------------------------------------------------

SELECT sum(pls14.visits) AS visits_2014,
       sum(pls09.visits) AS visits_2009
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.visits >= 0 AND pls09.visits >= 0;
-- Expected: 1417299241 | 1585455205


-- ----------------------------------------------------------------
-- Listing 8-13: GROUP BY with percent change in visits by state
-- ----------------------------------------------------------------

SELECT pls14.stabr,
       sum(pls14.visits) AS visits_2014,
       sum(pls09.visits) AS visits_2009,
       round(
           (CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits))
           / sum(pls09.visits) * 100, 2
       ) AS pct_change
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.visits >= 0 AND pls09.visits >= 0
GROUP BY pls14.stabr
ORDER BY pct_change DESC;


-- ----------------------------------------------------------------
-- Listing 8-14: HAVING -- filter aggregate results
-- (only states with more than 50 million visits in 2014)
-- ----------------------------------------------------------------

SELECT pls14.stabr,
       sum(pls14.visits) AS visits_2014,
       sum(pls09.visits) AS visits_2009,
       round(
           (CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits))
           / sum(pls09.visits) * 100, 2
       ) AS pct_change
FROM pls_fy2014_pupld14a pls14 JOIN pls_fy2009_pupld09a pls09
ON pls14.fscskey = pls09.fscskey
WHERE pls14.visits >= 0 AND pls09.visits >= 0
GROUP BY pls14.stabr
HAVING sum(pls14.visits) > 50000000
ORDER BY pct_change DESC;