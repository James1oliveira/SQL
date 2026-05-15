-- Chapter 9 explains how to inspect, clean, and modify data in SQL. 
-- It covers finding missing or incorrect values, updating tables and columns, 
-- fixing inconsistent data, and deleting unnecessary information.
-- The chapter also teaches how to safely make changes using backup tables 
-- and transaction blocks to avoid losing data.
 
 
 -- ================================================================
-- CHAPTER 9: Inspecting and Modifying Data
-- TRY IT YOURSELF - EXERCISES
-- ================================================================
-- Requires: meat_poultry_egg_inspect table from Chapter 9 main code


-- ----------------------------------------------------------------
-- Exercise 1:
-- Add two new boolean columns to the meat_poultry_egg_inspect table:
--   meat_processing     = TRUE if the plant processes meat
--   poultry_processing  = TRUE if the plant processes poultry
-- ----------------------------------------------------------------

ALTER TABLE meat_poultry_egg_inspect ADD COLUMN meat_processing boolean;
ALTER TABLE meat_poultry_egg_inspect ADD COLUMN poultry_processing boolean;


-- ----------------------------------------------------------------
-- Exercise 2:
-- Set meat_processing = TRUE for any row where the activities column
-- contains the text 'Meat Processing'.
-- Set poultry_processing = TRUE for any row where activities contains
-- 'Poultry Processing'.
-- Use ILIKE so the search is case-insensitive.
-- ----------------------------------------------------------------

UPDATE meat_poultry_egg_inspect
SET meat_processing = TRUE
WHERE activities ILIKE '%Meat Processing%';

UPDATE meat_poultry_egg_inspect
SET poultry_processing = TRUE
WHERE activities ILIKE '%Poultry Processing%';

-- Verify the updates:
SELECT company, activities, meat_processing, poultry_processing
FROM meat_poultry_egg_inspect
WHERE meat_processing = TRUE OR poultry_processing = TRUE
ORDER BY company
LIMIT 10;


-- ----------------------------------------------------------------
-- Exercise 3:
-- Count how many plants fall into each category.
-- BONUS: Count plants that do BOTH types of processing.
-- ----------------------------------------------------------------

-- Count meat processing plants:
SELECT count(*) AS meat_plants
FROM meat_poultry_egg_inspect
WHERE meat_processing = TRUE;

-- Count poultry processing plants:
SELECT count(*) AS poultry_plants
FROM meat_poultry_egg_inspect
WHERE poultry_processing = TRUE;

-- Count plants that process BOTH meat AND poultry:
SELECT count(*) AS both_processing
FROM meat_poultry_egg_inspect
WHERE meat_processing = TRUE
  AND poultry_processing = TRUE;

-- Summary in one query:
SELECT
    count(*) FILTER (WHERE meat_processing = TRUE)     AS meat_plants,
    count(*) FILTER (WHERE poultry_processing = TRUE)  AS poultry_plants,
    count(*) FILTER (WHERE meat_processing = TRUE
                       AND poultry_processing = TRUE)  AS both_plants
FROM meat_poultry_egg_inspect;