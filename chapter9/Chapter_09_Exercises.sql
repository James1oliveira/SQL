-- ================================================================
-- CHAPTER 9: Inspecting and Modifying Data
-- TRY IT YOURSELF - EXERCISES
-- ================================================================
-- Uses the meat_poultry_egg_inspect table from Chapter 9 main code.


-- ================================================================
-- Exercise 1:
-- Create two boolean columns: meat_processing and poultry_processing.
-- ================================================================

-- ALTER TABLE meat_poultry_egg_inspect ADD COLUMN meat_processing boolean;
-- ALTER TABLE meat_poultry_egg_inspect ADD COLUMN poultry_processing boolean;


-- ================================================================
-- Exercise 2:
-- Set meat_processing = TRUE for rows where activities contains
-- the text 'Meat Processing'.
-- Set poultry_processing = TRUE for rows where activities contains
-- the text 'Poultry Processing'.
-- ================================================================

-- UPDATE meat_poultry_egg_inspect
-- SET meat_processing = TRUE
-- WHERE activities ILIKE '%Meat Processing%';

-- UPDATE meat_poultry_egg_inspect
-- SET poultry_processing = TRUE
-- WHERE activities ILIKE '%Poultry Processing%';


-- ================================================================
-- Exercise 3:
-- Count how many plants perform each type of activity.
-- Bonus: Count plants that perform BOTH activities.
-- ================================================================

-- Count meat processing plants:
-- SELECT count(*) AS meat_plants
-- FROM meat_poultry_egg_inspect
-- WHERE meat_processing = TRUE;

-- Count poultry processing plants:
-- SELECT count(*) AS poultry_plants
-- FROM meat_poultry_egg_inspect
-- WHERE poultry_processing = TRUE;

-- BONUS: Count plants that do BOTH:
-- SELECT count(*) AS both_processing
-- FROM meat_poultry_egg_inspect
-- WHERE meat_processing = TRUE
-- AND poultry_processing = TRUE;
