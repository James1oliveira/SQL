-- ================================================================
-- CHAPTER 15: Saving Time with Views, Functions, and Triggers
-- MAIN CODE + EXERCISES
-- ================================================================
-- Uses tables from earlier chapters: us_counties_2010, us_counties_2000,
-- employees, departments, teachers, meat_poultry_egg_inspect


-- ================================================================
-- VIEWS
-- ================================================================

-- Create a simple view (Nevada counties):
-- CREATE OR REPLACE VIEW nevada_counties_pop_2010 AS
-- SELECT geo_name, state_fips, county_fips, p0010001 AS pop_2010
-- FROM us_counties_2010
-- WHERE state_us_abbreviation = 'NV'
-- ORDER BY county_fips;

-- Query the view:
-- SELECT * FROM nevada_counties_pop_2010 LIMIT 5;

-- Create a view with a join and calculation:
-- CREATE OR REPLACE VIEW county_pop_change_2010_2000 AS
-- SELECT c2010.geo_name,
--        c2010.state_us_abbreviation AS st,
--        c2010.state_fips, c2010.county_fips,
--        c2010.p0010001 AS pop_2010,
--        c2000.p0010001 AS pop_2000,
--        round((CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
--              / c2000.p0010001 * 100, 1) AS pct_change_2010_2000
-- FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
-- ON c2010.state_fips = c2000.state_fips
-- AND c2010.county_fips = c2000.county_fips
-- ORDER BY c2010.state_fips, c2010.county_fips;

-- Query specific columns from the view for Nevada:
-- SELECT geo_name, st, pop_2010, pct_change_2010_2000
-- FROM county_pop_change_2010_2000
-- WHERE st = 'NV' LIMIT 5;

-- View for controlled INSERT/UPDATE access (Tax dept only):
-- CREATE OR REPLACE VIEW employees_tax_dept AS
-- SELECT emp_id, first_name, last_name, dept_id
-- FROM employees
-- WHERE dept_id = 1
-- ORDER BY emp_id
-- WITH LOCAL CHECK OPTION;

-- SELECT * FROM employees_tax_dept;

-- Insert via view (succeeds — dept_id 1):
-- INSERT INTO employees_tax_dept (first_name, last_name, dept_id)
-- VALUES ('Suzanne', 'Legere', 1);

-- Insert via view (FAILS — dept_id 2 violates check option):
-- INSERT INTO employees_tax_dept (first_name, last_name, dept_id)
-- VALUES ('Jamil', 'White', 2);

-- Update via view:
-- UPDATE employees_tax_dept SET last_name = 'Le Gere' WHERE emp_id = 5;
-- SELECT * FROM employees_tax_dept;

-- Delete via view:
-- DELETE FROM employees_tax_dept WHERE emp_id = 5;

-- Drop a view:
-- DROP VIEW nevada_counties_pop_2010;


-- ================================================================
-- FUNCTIONS
-- ================================================================

-- percent_change() function using plain SQL:
-- CREATE OR REPLACE FUNCTION
-- percent_change(new_value numeric, old_value numeric, decimal_places integer DEFAULT 1)
-- RETURNS numeric AS
-- 'SELECT round(((new_value - old_value) / old_value) * 100, decimal_places);'
-- LANGUAGE SQL IMMUTABLE RETURNS NULL ON NULL INPUT;

-- Test the function:
-- SELECT percent_change(110, 108, 2);

-- Use in census query:
-- SELECT c2010.geo_name, c2010.state_us_abbreviation AS st,
--        c2010.p0010001 AS pop_2010,
--        percent_change(c2010.p0010001, c2000.p0010001) AS pct_chg_func,
--        round((CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
--              / c2000.p0010001 * 100, 1) AS pct_chg_formula
-- FROM us_counties_2010 c2010 INNER JOIN us_counties_2000 c2000
-- ON c2010.state_fips = c2000.state_fips AND c2010.county_fips = c2000.county_fips
-- ORDER BY pct_chg_func DESC LIMIT 5;

-- Add personal_days column to teachers:
-- ALTER TABLE teachers ADD COLUMN personal_days integer;
-- SELECT first_name, last_name, hire_date, personal_days FROM teachers;

-- update_personal_days() function using PL/pgSQL:
-- CREATE OR REPLACE FUNCTION update_personal_days()
-- RETURNS void AS $$
-- BEGIN
--     UPDATE teachers
--     SET personal_days =
--         CASE WHEN (now() - hire_date) BETWEEN '5 years'::interval
--                   AND '10 years'::interval THEN 4
--              WHEN (now() - hire_date) > '10 years'::interval THEN 5
--              ELSE 3 END;
--     RAISE NOTICE 'personal_days updated!';
-- END;
-- $$ LANGUAGE plpgsql;

-- Run the function:
-- SELECT update_personal_days();
-- SELECT first_name, last_name, hire_date, personal_days FROM teachers;

-- Python function (requires plpythonu extension):
-- CREATE EXTENSION plpythonu;
-- CREATE OR REPLACE FUNCTION trim_county(input_string text)
-- RETURNS text AS $$
--     import re
--     cleaned = re.sub(r' County', '', input_string)
--     return cleaned
-- $$ LANGUAGE plpythonu;

-- Test trim_county():
-- SELECT geo_name, trim_county(geo_name) FROM us_counties_2010
-- ORDER BY state_fips, county_fips LIMIT 5;


-- ================================================================
-- TRIGGERS
-- ================================================================

-- Tables for grade change logging:
-- CREATE TABLE grades (
--     student_id bigint, course_id bigint, course varchar(30) NOT NULL,
--     grade varchar(5) NOT NULL, PRIMARY KEY (student_id, course_id)
-- );
-- INSERT INTO grades VALUES
--     (1, 1, 'Biology 2', 'F'),(1, 2, 'English 11B', 'D'),
--     (1, 3, 'World History 11B', 'C'),(1, 4, 'Trig 2', 'B');
-- CREATE TABLE grades_history (
--     student_id bigint NOT NULL, course_id bigint NOT NULL,
--     change_time timestamp with time zone NOT NULL,
--     course varchar(30) NOT NULL, old_grade varchar(5) NOT NULL,
--     new_grade varchar(5) NOT NULL,
--     PRIMARY KEY (student_id, course_id, change_time)
-- );

-- Function for the trigger:
-- CREATE OR REPLACE FUNCTION record_if_grade_changed()
-- RETURNS trigger AS $$
-- BEGIN
--     IF NEW.grade <> OLD.grade THEN
--         INSERT INTO grades_history (student_id, course_id, change_time,
--                                     course, old_grade, new_grade)
--         VALUES (OLD.student_id, OLD.course_id, now(),
--                 OLD.course, OLD.grade, NEW.grade);
--     END IF;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- Create the trigger:
-- CREATE TRIGGER grades_update
-- AFTER UPDATE ON grades
-- FOR EACH ROW EXECUTE PROCEDURE record_if_grade_changed();

-- Test the trigger:
-- UPDATE grades SET grade = 'C' WHERE student_id = 1 AND course_id = 1;
-- SELECT student_id, change_time, course, old_grade, new_grade FROM grades_history;

-- Temperature classification trigger:
-- CREATE TABLE temperature_test (
--     station_name varchar(50), observation_date date,
--     max_temp integer, min_temp integer, max_temp_group varchar(40),
--     PRIMARY KEY (station_name, observation_date)
-- );
-- CREATE OR REPLACE FUNCTION classify_max_temp()
-- RETURNS trigger AS $$
-- BEGIN
--     CASE
--         WHEN NEW.max_temp >= 90 THEN NEW.max_temp_group := 'Hot';
--         WHEN NEW.max_temp BETWEEN 70 AND 89 THEN NEW.max_temp_group := 'Warm';
--         WHEN NEW.max_temp BETWEEN 50 AND 69 THEN NEW.max_temp_group := 'Pleasant';
--         WHEN NEW.max_temp BETWEEN 33 AND 49 THEN NEW.max_temp_group := 'Cold';
--         WHEN NEW.max_temp BETWEEN 20 AND 32 THEN NEW.max_temp_group := 'Freezing';
--         ELSE NEW.max_temp_group := 'Inhumane';
--     END CASE;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;
-- CREATE TRIGGER temperature_insert
-- BEFORE INSERT ON temperature_test
-- FOR EACH ROW EXECUTE PROCEDURE classify_max_temp();
-- INSERT INTO temperature_test (station_name, observation_date, max_temp, min_temp)
-- VALUES ('North Station','1/19/2019',10,-3),('North Station','3/20/2019',28,19),
--        ('North Station','5/2/2019',65,42),('North Station','8/9/2019',93,74);
-- SELECT * FROM temperature_test;


-- ================================================================
-- CHAPTER 15: Try It Yourself Exercises
-- ================================================================

-- Exercise 1: View of NYC taxi trips per hour (uses Chapter 11 data).
-- CREATE OR REPLACE VIEW nyc_taxi_trips_per_hour AS
-- SELECT date_part('hour', tpep_pickup_datetime) AS trip_hour, count(*)
-- FROM nyc_yellow_taxi_trips_2016_06_01
-- GROUP BY trip_hour ORDER BY trip_hour;
-- SELECT * FROM nyc_taxi_trips_per_hour;


-- Exercise 2: rates_per_thousand() function.
-- CREATE OR REPLACE FUNCTION
-- rates_per_thousand(observed_number numeric, base_number numeric,
--                    decimal_places integer DEFAULT 1)
-- RETURNS numeric AS
-- 'SELECT round((observed_number / base_number) * 1000, decimal_places);'
-- LANGUAGE SQL IMMUTABLE RETURNS NULL ON NULL INPUT;

-- Test:
-- SELECT rates_per_thousand(50, 11000, 2);


-- Exercise 3: Trigger that sets inspection_date 6 months from now on INSERT.
-- CREATE OR REPLACE FUNCTION set_inspection_date()
-- RETURNS trigger AS $$
-- BEGIN
--     NEW.inspection_date = now() + '6 months'::interval;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;
-- CREATE TRIGGER inspection_date_insert
-- BEFORE INSERT ON meat_poultry_egg_inspect
-- FOR EACH ROW EXECUTE PROCEDURE set_inspection_date();
-- Steps: 1) Create the function that sets inspection_date = now() + 6 months.
--        2) Create a BEFORE INSERT trigger on meat_poultry_egg_inspect that calls it.
--        3) Insert a test row and verify inspection_date is populated automatically.
