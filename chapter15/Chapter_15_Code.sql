-- ================================================================
-- CHAPTER 15: Saving Time with Views, Functions, and Triggers
-- MAIN CODE [CORRECTED]
-- Data directory: C:\SQL\
-- ================================================================
-- Requires tables from earlier chapters:
--   us_counties_2010, us_counties_2000 (Chapters 4–5)
--   meat_poultry_egg_inspect          (Chapter 9)
--   teachers, employees, departments  (Chapters 1–2)


-- ================================================================
-- VIEWS
-- ================================================================

-- Listing 15-1: Create a simple view for Nevada counties
CREATE OR REPLACE VIEW nevada_counties_pop_2010 AS
    SELECT geo_name,
           state_fips,
           county_fips,
           p0010001 AS pop_2010
    FROM us_counties_2010
    WHERE state_us_abbreviation = 'NV'
    ORDER BY county_fips;

-- Query the view:
SELECT * FROM nevada_counties_pop_2010 LIMIT 5;


-- Listing 15-2: Create a view joining 2010 and 2000 census tables
CREATE OR REPLACE VIEW county_pop_change_2010_2000 AS
    SELECT c2010.geo_name,
           c2010.state_us_abbreviation AS st,
           c2010.state_fips,
           c2010.county_fips,
           c2010.p0010001 AS pop_2010,
           c2000.p0010001 AS pop_2000,
           round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
                  / c2000.p0010001 * 100, 1 ) AS pct_change_2010_2000
    FROM us_counties_2010 c2010
         INNER JOIN us_counties_2000 c2000
             ON c2010.state_fips  = c2000.state_fips
            AND c2010.county_fips = c2000.county_fips
    ORDER BY c2010.state_fips, c2010.county_fips;

-- Query Nevada rows from the view:
SELECT geo_name, st, pop_2010, pct_change_2010_2000
FROM county_pop_change_2010_2000
WHERE st = 'NV'
LIMIT 5;


-- Listing 15-3: View with WITH LOCAL CHECK OPTION
-- (only allows INSERT/UPDATE where depart_id = 1)
CREATE OR REPLACE VIEW employees_tax_dept AS
    SELECT emp_id, first_name, last_name, dept_id
    FROM employees
    WHERE dept_id = 1
    ORDER BY emp_id
    WITH LOCAL CHECK OPTION;

SELECT * FROM employees_tax_dept;

-- Insert via the underlying table (view only exposes 4 of 9 columns;
-- all NOT NULL columns must be supplied directly on the base table):
INSERT INTO employees (first_name, last_name, salary, dept_id)
VALUES ('Suzanne', 'Legere', 50000, 1);
-- Confirm she appears in the view:
SELECT * FROM employees_tax_dept;

-- Drop a view:
-- DROP VIEW nevada_counties_pop_2010;


-- ================================================================
-- FUNCTIONS
-- ================================================================

-- Listing 15-4: percent_change() — plain SQL function
CREATE OR REPLACE FUNCTION percent_change(
    new_value      numeric,
    old_value      numeric,
    decimal_places integer DEFAULT 1
)
RETURNS numeric AS
$$
    SELECT CASE
               WHEN old_value = 0 THEN NULL
               ELSE round(((new_value - old_value) / old_value) * 100,
                          decimal_places)
           END;
$$
LANGUAGE SQL IMMUTABLE RETURNS NULL ON NULL INPUT;

-- Quick test:
SELECT percent_change(110, 108, 2);

-- Listing 15-5: Use percent_change() in a census query
SELECT c2010.geo_name,
       c2010.state_us_abbreviation AS st,
       c2010.p0010001 AS pop_2010,
       percent_change(c2010.p0010001, c2000.p0010001) AS pct_chg_func,
       round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
              / c2000.p0010001 * 100, 1 ) AS pct_chg_formula
FROM us_counties_2010 c2010
     INNER JOIN us_counties_2000 c2000
         ON c2010.state_fips  = c2000.state_fips
        AND c2010.county_fips = c2000.county_fips
ORDER BY pct_chg_func DESC
LIMIT 5;


-- Listing 15-6: update_personal_days() — PL/pgSQL function
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS personal_days integer;

SELECT first_name, last_name, hire_date, personal_days FROM teachers;

CREATE OR REPLACE FUNCTION update_personal_days()
RETURNS void AS $$
BEGIN
    UPDATE teachers
    SET personal_days =
        CASE
            WHEN (now() - hire_date) BETWEEN '5 years'::interval
                                         AND '10 years'::interval THEN 4
            WHEN (now() - hire_date) > '10 years'::interval         THEN 5
            ELSE 3
        END;
    RAISE NOTICE 'personal_days updated!';
END;
$$ LANGUAGE plpgsql;

-- Run the function:
SELECT update_personal_days();
SELECT first_name, last_name, hire_date, personal_days FROM teachers;


-- Listing 15-7: trim_county() — plpython3u not available on this machine.
-- Pure SQL equivalent using replace():
SELECT geo_name,
       replace(geo_name, ' County', '') AS county_trimmed
FROM us_counties_2010
ORDER BY state_fips, county_fips
LIMIT 5;


-- ================================================================
-- TRIGGERS
-- ================================================================

-- ----------------------------------------------------------------
-- Part 1: Grade-change audit trigger
-- ----------------------------------------------------------------

-- Listing 15-8: Tables for grade tracking
CREATE TABLE IF NOT EXISTS grades (
    student_id bigint,
    course_id  bigint,
    course     varchar(30) NOT NULL,
    grade      varchar(5)  NOT NULL,
    PRIMARY KEY (student_id, course_id)
);

CREATE TABLE IF NOT EXISTS grades_history (
    student_id  bigint      NOT NULL,
    course_id   bigint      NOT NULL,
    change_time timestamp with time zone NOT NULL,
    course      varchar(30) NOT NULL,
    old_grade   varchar(5)  NOT NULL,
    new_grade   varchar(5)  NOT NULL,
    PRIMARY KEY (student_id, course_id, change_time)
);

-- Seed grades with test data:
INSERT INTO grades (student_id, course_id, course, grade)
VALUES
    (1, 1, 'Biology 2',         'F'),
    (1, 2, 'English 11B',       'D'),
    (1, 3, 'World History 11B', 'C'),
    (1, 4, 'Trig 2',            'B')
ON CONFLICT DO NOTHING;


-- Listing 15-9: Trigger function — log grade changes
CREATE OR REPLACE FUNCTION record_if_grade_changed()
RETURNS trigger AS $$
BEGIN
    IF NEW.grade <> OLD.grade THEN
        INSERT INTO grades_history (
            student_id, course_id, change_time,
            course, old_grade, new_grade
        )
        VALUES (
            OLD.student_id, OLD.course_id, now(),
            OLD.course,     OLD.grade,     NEW.grade
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Listing 15-10: Attach the trigger to the grades table
DROP TRIGGER IF EXISTS grades_update ON grades;

CREATE TRIGGER grades_update
    AFTER UPDATE ON grades
    FOR EACH ROW EXECUTE FUNCTION record_if_grade_changed();

-- Test: update a grade — should appear in grades_history
UPDATE grades SET grade = 'C' WHERE student_id = 1 AND course_id = 1;
SELECT student_id, change_time, course, old_grade, new_grade
FROM grades_history;


-- ----------------------------------------------------------------
-- Part 2: Temperature classification trigger
-- ----------------------------------------------------------------

-- Listing 15-11: temperature_test table
CREATE TABLE IF NOT EXISTS temperature_test (
    station_name     varchar(50),
    observation_date date,
    max_temp         integer,
    min_temp         integer,
    max_temp_group   varchar(40),
    PRIMARY KEY (station_name, observation_date)
);

-- Listing 15-12: Trigger function — classify max temperature
CREATE OR REPLACE FUNCTION classify_max_temp()
RETURNS trigger AS $$
BEGIN
    CASE
        WHEN NEW.max_temp >= 90             THEN NEW.max_temp_group := 'Hot';
        WHEN NEW.max_temp BETWEEN 70 AND 89 THEN NEW.max_temp_group := 'Warm';
        WHEN NEW.max_temp BETWEEN 50 AND 69 THEN NEW.max_temp_group := 'Pleasant';
        WHEN NEW.max_temp BETWEEN 33 AND 49 THEN NEW.max_temp_group := 'Cold';
        WHEN NEW.max_temp BETWEEN 20 AND 32 THEN NEW.max_temp_group := 'Freezing';
        ELSE                                     NEW.max_temp_group := 'Inhumane';
    END CASE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Listing 15-13: Attach the trigger
DROP TRIGGER IF EXISTS temperature_insert ON temperature_test;

CREATE TRIGGER temperature_insert
    BEFORE INSERT ON temperature_test
    FOR EACH ROW EXECUTE FUNCTION classify_max_temp();

-- Test inserts — max_temp_group should be filled automatically:
INSERT INTO temperature_test (station_name, observation_date, max_temp, min_temp)
VALUES
    ('North Station', '2019-01-19',  10, -3),
    ('North Station', '2019-03-20',  28, 19),
    ('North Station', '2019-05-02',  65, 42),
    ('North Station', '2019-08-09',  93, 74);

SELECT * FROM temperature_test;