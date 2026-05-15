-- ================================================================
-- CHAPTER 9: Inspecting and Modifying Data
-- MAIN CODE
-- ================================================================
-- NOTE: Download from https://www.nostarch.com/practicalSQL/
--   MPI_Directory_by_Establishment_Name.csv
--   state_regions.csv
-- Both go in: C:\SQL\


-- ================================================================
-- LISTING 9-1: Create and import the meat/poultry/egg inspection table
-- ================================================================

CREATE TABLE meat_poultry_egg_inspect (
    est_number varchar(50) CONSTRAINT est_number_key PRIMARY KEY,
    company varchar(100),
    street varchar(100),
    city varchar(30),
    st varchar(2),
    zip varchar(5),
    phone varchar(14),
    grant_date date,
    activities text,
    dbas text
);

COPY meat_poultry_egg_inspect
FROM 'C:\SQL\MPI_Directory_by_Establishment_Name.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

CREATE INDEX company_idx ON meat_poultry_egg_inspect (company);

-- Verify row count (should be 6,287):
SELECT count(*) FROM meat_poultry_egg_inspect;


-- ================================================================
-- LISTING 9-2: Find companies listed at the same address more than once
-- ================================================================

SELECT company,
       street,
       city,
       st,
       count(*) AS address_count
FROM meat_poultry_egg_inspect
GROUP BY company, street, city, st
HAVING count(*) > 1
ORDER BY company, street, city, st;


-- ================================================================
-- LISTING 9-3: Count establishments per state (finds NULL state rows)
-- ================================================================

SELECT st,
       count(*) AS st_count
FROM meat_poultry_egg_inspect
GROUP BY st
ORDER BY st;


-- ================================================================
-- LISTING 9-4: Find rows missing a state code using IS NULL
-- ================================================================

SELECT est_number,
       company,
       city,
       st,
       zip
FROM meat_poultry_egg_inspect
WHERE st IS NULL;


-- ================================================================
-- LISTING 9-5: Find inconsistent company name spellings
-- ================================================================

SELECT company,
       count(*) AS company_count
FROM meat_poultry_egg_inspect
GROUP BY company
ORDER BY company ASC;


-- ================================================================
-- LISTING 9-6: Check zip code length to find truncated zip codes
-- ================================================================

SELECT length(zip),
       count(*) AS length_count
FROM meat_poultry_egg_inspect
GROUP BY length(zip)
ORDER BY length(zip) ASC;


-- ================================================================
-- LISTING 9-7: Find which states have short zip codes
-- ================================================================

SELECT st,
       count(*) AS st_count
FROM meat_poultry_egg_inspect
WHERE length(zip) < 5
GROUP BY st
ORDER BY st ASC;


-- ================================================================
-- LISTING 9-8: Back up the table before making changes
-- ================================================================

CREATE TABLE meat_poultry_egg_inspect_backup AS
SELECT * FROM meat_poultry_egg_inspect;

-- Verify both tables have same row count:
SELECT
    (SELECT count(*) FROM meat_poultry_egg_inspect) AS original,
    (SELECT count(*) FROM meat_poultry_egg_inspect_backup) AS backup;


-- ================================================================
-- LISTING 9-9: Add a backup copy of the st column inside the table
-- ================================================================

ALTER TABLE meat_poultry_egg_inspect ADD COLUMN st_copy varchar(2);
UPDATE meat_poultry_egg_inspect
SET st_copy = st;


-- ================================================================
-- LISTING 9-10: Verify the st and st_copy columns match
-- ================================================================

SELECT st,
       st_copy
FROM meat_poultry_egg_inspect
ORDER BY st;


-- ================================================================
-- LISTING 9-11: Fill in missing state codes for 3 rows
-- ================================================================

UPDATE meat_poultry_egg_inspect
SET st = 'MN'
WHERE est_number = 'V18677A';

UPDATE meat_poultry_egg_inspect
SET st = 'AL'
WHERE est_number = 'M45319+P45319';

UPDATE meat_poultry_egg_inspect
SET st = 'WI'
WHERE est_number = 'M263A+P263A+V263A';


-- ================================================================
-- LISTING 9-12: Restore original st values from backup if needed
-- ================================================================

-- Option 1: Restore from the backup column inside the table:
UPDATE meat_poultry_egg_inspect
SET st = st_copy;

-- Option 2: Restore from the full backup table:
UPDATE meat_poultry_egg_inspect original
SET st = backup.st
FROM meat_poultry_egg_inspect_backup backup
WHERE original.est_number = backup.est_number;


-- ================================================================
-- LISTING 9-13: Add a company_standard column for standardized names
-- ================================================================

ALTER TABLE meat_poultry_egg_inspect ADD COLUMN company_standard varchar(100);
UPDATE meat_poultry_egg_inspect
SET company_standard = company;


-- ================================================================
-- LISTING 9-14: Standardize all Armour-Eckrich name variations
-- ================================================================

UPDATE meat_poultry_egg_inspect
SET company_standard = 'Armour-Eckrich Meats'
WHERE company LIKE 'Armour%';

SELECT company, company_standard
FROM meat_poultry_egg_inspect
WHERE company LIKE 'Armour%';


-- ================================================================
-- LISTING 9-15: Back up the zip column before fixing it
-- ================================================================

ALTER TABLE meat_poultry_egg_inspect ADD COLUMN zip_copy varchar(5);
UPDATE meat_poultry_egg_inspect
SET zip_copy = zip;


-- ================================================================
-- LISTING 9-16: Fix zip codes missing 2 leading zeros (PR and VI)
-- ================================================================

UPDATE meat_poultry_egg_inspect
SET zip = '00' || zip
WHERE st IN('PR','VI') AND length(zip) = 3;


-- ================================================================
-- LISTING 9-17: Fix zip codes missing 1 leading zero (Northeast states)
-- ================================================================

UPDATE meat_poultry_egg_inspect
SET zip = '0' || zip
WHERE st IN('CT','MA','ME','NH','NJ','RI','VT') AND length(zip) = 4;

-- Verify all zips are now 5 characters:
SELECT length(zip), count(*) AS length_count
FROM meat_poultry_egg_inspect
GROUP BY length(zip)
ORDER BY length(zip) ASC;


-- ================================================================
-- LISTING 9-18: Create and fill the state_regions lookup table
-- ================================================================

CREATE TABLE state_regions (
    st varchar(2) CONSTRAINT st_key PRIMARY KEY,
    region varchar(20) NOT NULL
);

COPY state_regions
FROM 'C:\SQL\state_regions.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');


-- ================================================================
-- LISTING 9-19: Add inspection_date column and fill for New England
-- ================================================================

ALTER TABLE meat_poultry_egg_inspect ADD COLUMN inspection_date date;

UPDATE meat_poultry_egg_inspect inspect
SET inspection_date = '2019-12-01'
WHERE EXISTS (SELECT state_regions.region
              FROM state_regions
              WHERE inspect.st = state_regions.st
              AND state_regions.region = 'New England');


-- ================================================================
-- LISTING 9-20: View the updated inspection dates grouped by state
-- ================================================================

SELECT st, inspection_date
FROM meat_poultry_egg_inspect
GROUP BY st, inspection_date
ORDER BY st;


-- ================================================================
-- LISTING 9-21: Delete rows for Puerto Rico and Virgin Islands
-- ================================================================

DELETE FROM meat_poultry_egg_inspect
WHERE st IN('PR','VI');


-- ================================================================
-- LISTING 9-22: Remove the zip_copy backup column
-- ================================================================

ALTER TABLE meat_poultry_egg_inspect DROP COLUMN zip_copy;


-- ================================================================
-- LISTING 9-23: Drop the full backup table when no longer needed
-- ================================================================

DROP TABLE meat_poultry_egg_inspect_backup;


-- ================================================================
-- LISTING 9-24: Transaction block -- test and revert a change safely
-- ================================================================

START TRANSACTION;

UPDATE meat_poultry_egg_inspect
SET company = 'AGRO Merchantss Oakland LLC'   -- intentional typo!
WHERE company = 'AGRO Merchants Oakland, LLC';

SELECT company
FROM meat_poultry_egg_inspect
WHERE company LIKE 'AGRO%'
ORDER BY company;

ROLLBACK;   -- discards the change
-- Use COMMIT; instead to save the change permanently


-- ================================================================
-- LISTING 9-25: Copy the table and add a new column in one step
-- ================================================================

CREATE TABLE meat_poultry_egg_inspect_backup AS
SELECT *,
       '2018-02-07'::date AS reviewed_date
FROM meat_poultry_egg_inspect;


-- ================================================================
-- LISTING 9-26: Swap table names to make the copy the active table
-- ================================================================

ALTER TABLE meat_poultry_egg_inspect RENAME TO meat_poultry_egg_inspect_temp;
ALTER TABLE meat_poultry_egg_inspect_backup RENAME TO meat_poultry_egg_inspect;
ALTER TABLE meat_poultry_egg_inspect_temp RENAME TO meat_poultry_egg_inspect_backup;