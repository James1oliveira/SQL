-- ================================================================
-- CHAPTER 2: Beginning Data Exploration with SELECT
-- MAIN CODE
-- ================================================================


-- ----------------------------------------------------------------
-- Select All Columns and Rows
-- ----------------------------------------------------------------

-- SELECT * FROM teachers;


-- ----------------------------------------------------------------
-- Select Specific Columns
-- ----------------------------------------------------------------

-- SELECT last_name, first_name, salary FROM teachers;


-- ----------------------------------------------------------------
-- Find Unique Values with DISTINCT
-- ----------------------------------------------------------------

-- SELECT DISTINCT school
-- FROM teachers;

-- SELECT DISTINCT school, salary
-- FROM teachers;


-- ----------------------------------------------------------------
-- Sort Results with ORDER BY
-- ----------------------------------------------------------------

-- Sort salary highest to lowest:
-- SELECT first_name, last_name, salary
-- FROM teachers
-- ORDER BY salary DESC;

-- Sort by multiple columns (school A-Z, hire_date newest first):
-- SELECT last_name, school, hire_date
-- FROM teachers
-- ORDER BY school ASC, hire_date DESC;


-- ----------------------------------------------------------------
-- Filter Rows with WHERE
-- ----------------------------------------------------------------

-- Exact match:
-- SELECT last_name, school, hire_date
-- FROM teachers
-- WHERE school = 'Myers Middle School';

-- Not equal:
-- SELECT school
-- FROM teachers
-- WHERE school != 'F.D. Roosevelt HS';

-- Less than (date):
-- SELECT first_name, last_name, hire_date
-- FROM teachers
-- WHERE hire_date < '2000-01-01';

-- Greater than or equal to:
-- SELECT first_name, last_name, salary
-- FROM teachers
-- WHERE salary >= 43500;

-- Between (inclusive of both ends):
-- SELECT first_name, last_name, school, salary
-- FROM teachers
-- WHERE salary BETWEEN 40000 AND 65000;


-- ----------------------------------------------------------------
-- Pattern Matching with LIKE and ILIKE
-- ----------------------------------------------------------------

-- LIKE is case-sensitive (returns no results here):
-- SELECT first_name
-- FROM teachers
-- WHERE first_name LIKE 'sam%';

-- ILIKE is case-insensitive (returns Samuel and Samantha):
-- SELECT first_name
-- FROM teachers
-- WHERE first_name ILIKE 'sam%';


-- ----------------------------------------------------------------
-- Combining Conditions with AND / OR
-- ----------------------------------------------------------------

-- Both conditions must be true (AND):
-- SELECT *
-- FROM teachers
-- WHERE school = 'Myers Middle School'
-- AND salary < 40000;

-- Either condition can be true (OR):
-- SELECT *
-- FROM teachers
-- WHERE last_name = 'Cole'
-- OR last_name = 'Bush';

-- Grouped conditions with parentheses:
-- SELECT *
-- FROM teachers
-- WHERE school = 'F.D. Roosevelt HS'
-- AND (salary < 38000 OR salary > 40000);


-- ----------------------------------------------------------------
-- Full Query: WHERE and ORDER BY Combined
-- ----------------------------------------------------------------

-- SELECT first_name, last_name, school, hire_date, salary
-- FROM teachers
-- WHERE school LIKE '%Roos%'
-- ORDER BY hire_date DESC;
