-- ================================================================
-- CHAPTER 7: Table Design That Works for You
-- MAIN CODE
-- File paths set to: C:\Users\33980\OneDrive\Desktop\code college\SQL\Classwork\chapter7\
-- CSV files location: C:\Users\33980\OneDrive\Desktop\code college\SQL\Classwork\chapter7\csv\
-- ================================================================


-- ----------------------------------------------------------------
-- Natural Key — Single Column Primary Key
-- ----------------------------------------------------------------

-- CREATE TABLE natural_key_example (
--     license_id varchar(10) CONSTRAINT license_key PRIMARY KEY,
--     first_name varchar(50),
--     last_name varchar(50)
-- );

-- Drop and recreate using table constraint syntax:
-- DROP TABLE natural_key_example;

-- CREATE TABLE natural_key_example (
--     license_id varchar(10),
--     first_name varchar(50),
--     last_name varchar(50),
--     CONSTRAINT license_key PRIMARY KEY (license_id)
-- );

-- Test primary key violation (second INSERT will fail):
-- INSERT INTO natural_key_example (license_id, first_name, last_name)
-- VALUES ('T229901', 'Lynn', 'Malero');

-- INSERT INTO natural_key_example (license_id, first_name, last_name)
-- VALUES ('T229901', 'Sam', 'Tracy');
-- ^ ERROR: duplicate key value violates unique constraint "license_key"


-- ----------------------------------------------------------------
-- Composite Primary Key (two columns together = unique)
-- ----------------------------------------------------------------

-- CREATE TABLE natural_key_composite_example (
--     student_id varchar(10),
--     school_day date,
--     present boolean,
--     CONSTRAINT student_key PRIMARY KEY (student_id, school_day)
-- );

-- Test composite key violation:
-- INSERT INTO natural_key_composite_example (student_id, school_day, present)
-- VALUES(775, '1/22/2017', 'Y');

-- INSERT INTO natural_key_composite_example (student_id, school_day, present)
-- VALUES(775, '1/23/2017', 'Y');

-- INSERT INTO natural_key_composite_example (student_id, school_day, present)
-- VALUES(775, '1/23/2017', 'N');
-- ^ ERROR: duplicate key value — same student on same day already exists


-- ----------------------------------------------------------------
-- Surrogate Key — Auto-Incrementing bigserial
-- ----------------------------------------------------------------

-- CREATE TABLE surrogate_key_example (
--     order_number bigserial,
--     product_name varchar(50),
--     order_date date,
--     CONSTRAINT order_key PRIMARY KEY (order_number)
-- );

-- INSERT INTO surrogate_key_example (product_name, order_date)
-- VALUES ('Beachball Polish', '2015-03-17'),
--        ('Wrinkle De-Atomizer', '2017-05-22'),
--        ('Flux Capacitor', '1985-10-26');

-- SELECT * FROM surrogate_key_example;


-- ----------------------------------------------------------------
-- Foreign Key
-- ----------------------------------------------------------------

-- CREATE TABLE licenses (
--     license_id varchar(10),
--     first_name varchar(50),
--     last_name varchar(50),
--     CONSTRAINT licenses_key PRIMARY KEY (license_id)
-- );

-- CREATE TABLE registrations (
--     registration_id varchar(10),
--     registration_date date,
--     license_id varchar(10) REFERENCES licenses (license_id),
--     CONSTRAINT registration_key PRIMARY KEY (registration_id, license_id)
-- );

-- INSERT INTO licenses (license_id, first_name, last_name)
-- VALUES ('T229901', 'Lynn', 'Malero');

-- This succeeds (license_id T229901 exists in licenses):
-- INSERT INTO registrations (registration_id, registration_date, license_id)
-- VALUES ('A203391', '3/17/2017', 'T229901');

-- This fails (license_id T000001 does not exist in licenses):
-- INSERT INTO registrations (registration_id, registration_date, license_id)
-- VALUES ('A75772', '3/17/2017', 'T000001');
-- ^ ERROR: foreign key constraint violation


-- ----------------------------------------------------------------
-- CASCADE Delete (auto-delete related rows)
-- ----------------------------------------------------------------

-- CREATE TABLE registrations (
--     registration_id varchar(10),
--     registration_date date,
--     license_id varchar(10) REFERENCES licenses (license_id) ON DELETE CASCADE,
--     CONSTRAINT registration_key PRIMARY KEY (registration_id, license_id)
-- );


-- ----------------------------------------------------------------
-- CHECK Constraint
-- ----------------------------------------------------------------

-- CREATE TABLE check_constraint_example (
--     user_id bigserial,
--     user_role varchar(50),
--     salary integer,
--     CONSTRAINT user_id_key PRIMARY KEY (user_id),
--     CONSTRAINT check_role_in_list CHECK (user_role IN('Admin', 'Staff')),
--     CONSTRAINT check_salary_not_zero CHECK (salary > 0)
-- );


-- ----------------------------------------------------------------
-- UNIQUE Constraint
-- ----------------------------------------------------------------

-- CREATE TABLE unique_constraint_example (
--     contact_id bigserial CONSTRAINT contact_id_key PRIMARY KEY,
--     first_name varchar(50),
--     last_name varchar(50),
--     email varchar(200),
--     CONSTRAINT email_unique UNIQUE (email)
-- );

-- INSERT INTO unique_constraint_example (first_name, last_name, email)
-- VALUES ('Samantha', 'Lee', 'slee@example.org');

-- INSERT INTO unique_constraint_example (first_name, last_name, email)
-- VALUES ('Betty', 'Diaz', 'bdiaz@example.org');

-- This fails (email already exists):
-- INSERT INTO unique_constraint_example (first_name, last_name, email)
-- VALUES ('Sasha', 'Lee', 'slee@example.org');
-- ^ ERROR: duplicate key value violates unique constraint "email_unique"


-- ----------------------------------------------------------------
-- NOT NULL Constraint
-- ----------------------------------------------------------------

-- CREATE TABLE not_null_example (
--     student_id bigserial,
--     first_name varchar(50) NOT NULL,
--     last_name varchar(50) NOT NULL,
--     CONSTRAINT student_id_key PRIMARY KEY (student_id)
-- );


-- ----------------------------------------------------------------
-- Adding and Removing Constraints with ALTER TABLE
-- ----------------------------------------------------------------

-- Remove primary key:
-- ALTER TABLE not_null_example DROP CONSTRAINT student_id_key;

-- Add primary key back:
-- ALTER TABLE not_null_example ADD CONSTRAINT student_id_key PRIMARY KEY (student_id);

-- Remove NOT NULL:
-- ALTER TABLE not_null_example ALTER COLUMN first_name DROP NOT NULL;

-- Add NOT NULL back:
-- ALTER TABLE not_null_example ALTER COLUMN first_name SET NOT NULL;


-- ----------------------------------------------------------------
-- Indexes — Speed Up Queries
-- ----------------------------------------------------------------

-- CREATE TABLE new_york_addresses (
--     longitude numeric(9,6),
--     latitude numeric(9,6),
--     street_number varchar(10),
--     street varchar(32),
--     unit varchar(7),
--     postcode varchar(5),
--     id integer CONSTRAINT new_york_key PRIMARY KEY
-- );

-- COPY new_york_addresses
-- FROM 'C:\Users\33980\OneDrive\Desktop\code college\SQL\Classwork\chapter7\csv\city_of_new_york.csv'
-- WITH (FORMAT CSV, HEADER);

-- Benchmark queries BEFORE adding index:
-- EXPLAIN ANALYZE SELECT * FROM new_york_addresses WHERE street = 'BROADWAY';
-- EXPLAIN ANALYZE SELECT * FROM new_york_addresses WHERE street = '52 STREET';
-- EXPLAIN ANALYZE SELECT * FROM new_york_addresses WHERE street = 'ZWICKY AVENUE';

-- Add B-Tree index:
-- CREATE INDEX street_idx ON new_york_addresses (street);

-- Benchmark queries AFTER adding index (should be much faster):
-- EXPLAIN ANALYZE SELECT * FROM new_york_addresses WHERE street = 'BROADWAY';
-- EXPLAIN ANALYZE SELECT * FROM new_york_addresses WHERE street = '52 STREET';
-- EXPLAIN ANALYZE SELECT * FROM new_york_addresses WHERE street = 'ZWICKY AVENUE';
