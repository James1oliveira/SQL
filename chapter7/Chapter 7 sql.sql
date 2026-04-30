-- CREATE TABLE natural_key_example (
--     license_id varchar(10) CONSTRAINT license_key PRIMARY KEY,
--     first_name varchar(50),
--     last_name varchar(50)
-- );

-- CREATE TABLE natural_key_example (
--     license_id varchar(10),
--     first_name varchar(50),
--     last_name varchar(50),
--     CONSTRAINT license_key PRIMARY KEY (license_id)
-- );

-- CREATE TABLE natural_key_composite_example (
--     student_id varchar(10),
--     school_day date,
--     present boolean,
--     CONSTRAINT student_key PRIMARY KEY (student_id, school_day)
-- );


-- CREATE TABLE surrogate_key_example (
--     order_number bigserial,
--     product_name varchar(50),
--     order_date date,
--     CONSTRAINT order_key PRIMARY KEY (order_number)
-- );

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


-- CREATE TABLE check_constraint_example (
--     user_id bigserial,
--     user_role varchar(50),
--     salary integer,
--     CONSTRAINT user_id_key PRIMARY KEY (user_id),
--     CONSTRAINT check_role_in_list CHECK (user_role IN('Admin', 'Staff')),
--     CONSTRAINT check_salary_not_zero CHECK (salary > 0)
-- );

-- CREATE TABLE unique_constraint_example (
--     contact_id bigserial CONSTRAINT contact_id_key PRIMARY KEY,
--     first_name varchar(50),
--     last_name varchar(50),
--     email varchar(200),
--     CONSTRAINT email_unique UNIQUE (email)
-- );

-- CREATE TABLE albums (
--     album_id bigserial,
--     album_catalog_code varchar(100),
--     album_title text,
--     album_artist text,
--     album_release_date date,
--     album_genre varchar(40),
--     album_description text
-- );

-- CREATE TABLE songs (
--     song_id bigserial,
--     song_title text,
--     song_artist text,
--     album_id bigint
-- );


-- CREATE TABLE albums (
--     album_id bigserial,
--     album_catalog_code varchar(100) NOT NULL,
--     album_title text NOT NULL,
--     album_artist text NOT NULL,
--     album_release_date date,
--     album_genre varchar(40),
--     album_description text,
--     CONSTRAINT album_id_key PRIMARY KEY (album_id),
--     CONSTRAINT album_catalog_unique UNIQUE (album_catalog_code)
-- );

-- CREATE TABLE songs (
--     song_id bigserial,
--     song_title text NOT NULL,
--     song_artist text NOT NULL,
--     album_id bigint REFERENCES albums (album_id) ON DELETE CASCADE,
--     CONSTRAINT song_id_key PRIMARY KEY (song_id)
-- );


-- CREATE INDEX album_title_idx ON albums (album_title);
-- CREATE INDEX album_artist_idx ON albums (album_artist);
-- CREATE INDEX song_title_idx ON songs (song_title);
-- CREATE INDEX songs_album_id_idx ON songs (album_id);
