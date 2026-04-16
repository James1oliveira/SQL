-- ================================================================
-- CHAPTER 2: Beginning Data Exploration with SELECT
-- TRY IT YOURSELF - EXERCISES
-- ================================================================


-- ----------------------------------------------------------------
-- Exercise 1:
-- List all teachers grouped by school.
-- Schools in alphabetical order (A-Z).
-- Teachers within each school ordered by last name (A-Z).
-- ----------------------------------------------------------------

-- SELECT school, last_name, first_name
-- FROM teachers
-- ORDER BY school ASC, last_name ASC;


-- ----------------------------------------------------------------
-- Exercise 2:
-- Find the one teacher whose first name starts with 'S'
-- AND who earns more than $40,000.
-- (Answer: Samuel Cole)
-- ----------------------------------------------------------------

-- SELECT first_name, last_name, salary
-- FROM teachers
-- WHERE first_name LIKE 'S%'
-- AND salary > 40000;


-- ----------------------------------------------------------------
-- Exercise 3:
-- Show teachers hired on or after January 1, 2010.
-- Ordered from highest salary to lowest.
-- ----------------------------------------------------------------

-- SELECT first_name, last_name, hire_date, salary
-- FROM teachers
-- WHERE hire_date >= '2010-01-01'
-- ORDER BY salary DESC;
