
-- ============================================================
-- 1. SCHEMA CREATION  (drop in dependency order first)
-- ============================================================

-- Drop tables in reverse dependency order to avoid FK conflicts.
-- CASCADE ensures any dependent constraints are also removed.
DROP TABLE IF EXISTS Employees      CASCADE;
DROP TABLE IF EXISTS Overtime_Hours CASCADE;
DROP TABLE IF EXISTS Salaries       CASCADE;
DROP TABLE IF EXISTS Roles          CASCADE;
DROP TABLE IF EXISTS Department     CASCADE;


-- ─── Department ──────────────────────────────────────────────
-- Stores the company's departments and their physical locations.
-- Referenced by Employees via depart_id (FK).
CREATE TABLE Department (
    depart_id   SERIAL       PRIMARY KEY,           -- Auto-incrementing surrogate key
    depart_name VARCHAR(100) NOT NULL,               -- e.g. 'Engineering', 'Finance'
    depart_city VARCHAR(100) NOT NULL                -- Office city for this department
);

-- ─── Roles ───────────────────────────────────────────────────
-- Lookup table of all job titles available in the company.
-- Kept separate to avoid duplication and allow central updates.
CREATE TABLE Roles (
    role_id SERIAL       PRIMARY KEY,               -- Auto-incrementing surrogate key
    role    VARCHAR(100) NOT NULL                    -- e.g. 'Software Engineer', 'HR Manager'
);

-- ─── Salaries ────────────────────────────────────────────────
-- Stores annual salary bands. Decoupled from Employees so that
-- multiple employees can share the same salary tier.
CREATE TABLE Salaries (
    salary_id SERIAL         PRIMARY KEY,           -- Auto-incrementing surrogate key
    salary_pa NUMERIC(12, 2) NOT NULL               -- Annual salary; 12 digits, 2 decimal places
                             CHECK (salary_pa >= 0) -- Salary must be non-negative
);

-- ─── Overtime_Hours ──────────────────────────────────────────
-- Tracks overtime hour records. Normalised into its own table
-- to allow reuse and independent management.
CREATE TABLE Overtime_Hours (
    overtime_id    SERIAL  PRIMARY KEY,             -- Auto-incrementing surrogate key
    overtime_hours NUMERIC(6, 2) NOT NULL           -- Hours worked overtime; up to 9999.99
                   CHECK (overtime_hours >= 0)      -- Cannot record negative overtime
);

-- ─── Employees ───────────────────────────────────────────────
-- Central fact table linking all lookup/reference tables.
-- Each employee belongs to one department, holds one role,
-- is assigned one salary band, and has one overtime record.
CREATE TABLE Employees (
    emp_id      SERIAL       PRIMARY KEY,           -- Auto-incrementing surrogate key
    first_name  VARCHAR(100) NOT NULL,              -- Employee's given name
    surname     VARCHAR(100) NOT NULL,              -- Employee's family name
    gender      VARCHAR(20)  NOT NULL,              -- e.g. 'Male', 'Female', 'Non-binary'
    address     VARCHAR(255),                       -- Residential address (optional)
    email       VARCHAR(255) UNIQUE NOT NULL,       -- Work email; must be unique across all employees

    -- Foreign key columns — link to their respective lookup tables
    depart_id   INT NOT NULL,                       -- Which department this employee belongs to
    role_id     INT NOT NULL,                       -- The employee's job role
    salary_id   INT NOT NULL,                       -- The employee's salary band
    overtime_id INT NOT NULL,                       -- The employee's overtime record

    -- ── Foreign Key Constraints ───────────────────────────────
    -- Prevent orphaned references: every FK value must exist
    -- in its parent table, and parent rows cannot be deleted
    -- while child rows still reference them.

    CONSTRAINT fk_department
        FOREIGN KEY (depart_id)   REFERENCES Department(depart_id),

    CONSTRAINT fk_role
        FOREIGN KEY (role_id)     REFERENCES Roles(role_id),

    CONSTRAINT fk_salary
        FOREIGN KEY (salary_id)   REFERENCES Salaries(salary_id),

    CONSTRAINT fk_overtime
        FOREIGN KEY (overtime_id) REFERENCES Overtime_Hours(overtime_id)
);


-- ============================================================
-- 2. SEED DATA
-- ============================================================

-- ─── Department ──────────────────────────────────────────────
-- Five South African city offices, one per major department.
INSERT INTO Department (depart_name, depart_city) VALUES
    ('Engineering',       'Cape Town'),
    ('Human Resources',   'Johannesburg'),
    ('Finance',           'Durban'),
    ('Marketing',         'Pretoria'),
    ('Operations',        'Port Elizabeth');

-- ─── Roles ───────────────────────────────────────────────────
-- Seven distinct job titles covering all seeded employees.
INSERT INTO Roles (role) VALUES
    ('Software Engineer'),
    ('HR Manager'),
    ('Financial Analyst'),
    ('Marketing Specialist'),
    ('Operations Coordinator'),
    ('Senior Developer'),
    ('Payroll Officer');

-- ─── Salaries ────────────────────────────────────────────────
-- Seven salary bands in ZAR (South African Rand), per annum.
-- Ranges from R270,000 (junior) to R510,000 (senior).
INSERT INTO Salaries (salary_pa) VALUES
    (420000.00),    -- salary_id = 1
    (380000.00),    -- salary_id = 2
    (310000.00),    -- salary_id = 3
    (270000.00),    -- salary_id = 4
    (510000.00),    -- salary_id = 5
    (295000.00),    -- salary_id = 6
    (460000.00);    -- salary_id = 7

-- ─── Overtime_Hours ──────────────────────────────────────────
-- Seven overtime records. A value of 0.00 means no overtime
-- was worked during the recorded period.
INSERT INTO Overtime_Hours (overtime_hours) VALUES
    (12.50),    -- overtime_id = 1
    (0.00),     -- overtime_id = 2  (no overtime)
    (34.75),    -- overtime_id = 3  (highest overtime)
    (8.00),     -- overtime_id = 4
    (22.00),    -- overtime_id = 5
    (5.50),     -- overtime_id = 6
    (18.25);    -- overtime_id = 7

-- ─── Employees ───────────────────────────────────────────────
-- Ten employees distributed across all five departments.
-- FK IDs map to the SERIAL values assigned above (1-based).
INSERT INTO Employees
    (first_name, surname, gender, address, email,
     depart_id, role_id, salary_id, overtime_id)
VALUES
    -- HR, Cape Town
    ('Amahle',  'Dlamini',   'Female', '12 Berea Rd, Durban',          'amahle.dlamini@company.co.za',   2, 2, 2, 2),
    -- Engineering, Cape Town
    ('Sipho',   'Nkosi',     'Male',   '5 Long St, Cape Town',         'sipho.nkosi@company.co.za',      1, 1, 1, 3),
    -- Finance, Durban
    ('Thandi',  'Mokoena',   'Female', '88 Jan Smuts Ave, Joburg',     'thandi.mokoena@company.co.za',   3, 3, 3, 1),
    -- Marketing, Pretoria
    ('Ethan',   'van Wyk',   'Male',   '22 Church St, Pretoria',       'ethan.vanwyk@company.co.za',     4, 4, 4, 4),
    -- Operations, Port Elizabeth
    ('Lerato',  'Sithole',   'Female', '7 Settlers Way, Port Eliz',    'lerato.sithole@company.co.za',   5, 5, 6, 5),
    -- Engineering, Cape Town (Senior Developer)
    ('Rowan',   'Petersen',  'Male',   '3 Kloof St, Cape Town',        'rowan.petersen@company.co.za',   1, 6, 7, 6),
    -- HR, Johannesburg (Payroll Officer)
    ('Naledi',  'Khumalo',   'Female', '45 Noord St, Johannesburg',    'naledi.khumalo@company.co.za',   2, 7, 3, 7),
    -- Finance, Durban (second Financial Analyst)
    ('James',   'Fourie',    'Male',   '101 Marine Dr, Durban',        'james.fourie@company.co.za',     3, 3, 5, 2),
    -- Marketing, Pretoria (second Marketing Specialist)
    ('Zanele',  'Mahlangu',  'Female', '18 Voortrekker Rd, Pretoria',  'zanele.mahlangu@company.co.za',  4, 4, 4, 3),
    -- Engineering, Cape Town (second Software Engineer)
    ('Caden',   'Abrahams',  'Male',   '9 Adderley St, Cape Town',     'caden.abrahams@company.co.za',   1, 1, 1, 1);


-- ============================================================
-- 3. VERIFY DATA
-- ============================================================

-- Quick sanity check: confirms expected row counts after seeding.
-- Expected: Department=5, Roles=7, Salaries=7, Overtime_Hours=7, Employees=10
SELECT 'Department'     AS tbl, COUNT(*) AS rows FROM Department
UNION ALL
SELECT 'Roles',          COUNT(*) FROM Roles
UNION ALL
SELECT 'Salaries',       COUNT(*) FROM Salaries
UNION ALL
SELECT 'Overtime_Hours', COUNT(*) FROM Overtime_Hours
UNION ALL
SELECT 'Employees',      COUNT(*) FROM Employees;


-- ============================================================
-- 4. DEMONSTRATE FK CONSTRAINTS WORKING
-- ============================================================
-- Each block attempts an operation that violates a FK constraint.
-- The exception handler catches the error and raises a NOTICE,
-- proving the constraint is active without aborting the script.

-- ── 4a. FK violation on depart_id (dept 99 does not exist) ───
-- Attempt to insert an employee referencing a department (99)
-- that does not exist. Should be blocked by fk_department.
-- Expected: NOTICE — FK DEMO 1 PASSED
DO $$
BEGIN
    BEGIN
        INSERT INTO Employees
            (first_name, surname, gender, email,
             depart_id, role_id, salary_id, overtime_id)
        VALUES ('Ghost', 'User', 'Male', 'ghost@test.com',
                99, 1, 1, 1);   -- depart_id 99 does NOT exist
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'FK DEMO 1 PASSED: Cannot insert employee with non-existent depart_id=99 → %', SQLERRM;
    END;
END $$;

-- ── 4b. FK violation on role_id (role 50 does not exist) ─────
-- Attempt to insert an employee with a role (50) that does not
-- exist. Should be blocked by fk_role.
-- Expected: NOTICE — FK DEMO 2 PASSED
DO $$
BEGIN
    BEGIN
        INSERT INTO Employees
            (first_name, surname, gender, email,
             depart_id, role_id, salary_id, overtime_id)
        VALUES ('Ghost', 'User', 'Male', 'ghost2@test.com',
                1, 50, 1, 1);   -- role_id 50 does NOT exist
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'FK DEMO 2 PASSED: Cannot insert employee with non-existent role_id=50 → %', SQLERRM;
    END;
END $$;

-- ── 4c. Cannot DELETE a Department that has employees ─────────
-- Attempt to delete the Engineering department (depart_id=1),
-- which is still referenced by multiple employees.
-- Should be blocked by fk_department on the Employees table.
-- Expected: NOTICE — FK DEMO 3 PASSED
DO $$
BEGIN
    BEGIN
        DELETE FROM Department WHERE depart_id = 1;  -- Engineering has employees
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'FK DEMO 3 PASSED: Cannot delete Department that has linked employees → %', SQLERRM;
    END;
END $$;


-- ============================================================
-- 5. MAIN REPORT QUERY
--    LEFT JOIN — Department name, Job title, Salary, Overtime
-- ============================================================
-- Returns a full employee report by joining all lookup tables.
-- LEFT JOIN is used so that any employee with a missing FK
-- reference still appears in results (with NULLs) rather than
-- being silently excluded — useful for data-quality audits.
-- Results are sorted alphabetically by department, then surname.

SELECT
    d.depart_name                              AS "Department",
    r.role                                     AS "Job Title",
    TO_CHAR(s.salary_pa, 'FM R999,999,990.00') AS "Annual Salary",  -- Formatted as ZAR currency
    o.overtime_hours                           AS "Overtime Hours",
    e.first_name || ' ' || e.surname           AS "Employee"         -- Full name concatenation
FROM  Employees       e
LEFT JOIN Department     d ON e.depart_id   = d.depart_id
LEFT JOIN Roles          r ON e.role_id     = r.role_id
LEFT JOIN Salaries       s ON e.salary_id   = s.salary_id
LEFT JOIN Overtime_Hours o ON e.overtime_id = o.overtime_id
ORDER BY d.depart_name, e.surname;


-- ============================================================
-- 6. ADDITIONAL USEFUL QUERIES
-- ============================================================

-- ── Average salary per department ────────────────────────────
-- Aggregates salary data per department using INNER JOINs
-- (only employees with valid dept/salary references are counted).
-- Sorted highest-to-lowest to surface top-paying departments.
SELECT
    d.depart_name,
    ROUND(AVG(s.salary_pa), 2) AS avg_salary   -- Rounded to cents
FROM  Employees e
JOIN  Department d ON e.depart_id = d.depart_id
JOIN  Salaries   s ON e.salary_id = s.salary_id
GROUP BY d.depart_name
ORDER BY avg_salary DESC;

-- ── Employees with overtime > 10 hours ───────────────────────
-- Identifies employees who have worked significant overtime.
-- Useful for HR reporting, fatigue monitoring, or payroll.
-- Threshold: > 10 hours. Sorted highest overtime first.
SELECT
    e.first_name || ' ' || e.surname AS employee,   -- Full name
    d.depart_name,
    r.role,
    o.overtime_hours
FROM  Employees       e
JOIN  Department     d ON e.depart_id   = d.depart_id
JOIN  Roles          r ON e.role_id     = r.role_id
JOIN  Overtime_Hours o ON e.overtime_id = o.overtime_id
WHERE o.overtime_hours > 10                          -- Filter: only meaningful overtime
ORDER BY o.overtime_hours DESC;                      -- Highest offenders first