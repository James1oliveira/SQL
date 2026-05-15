

-- ============================================================
-- DROP TABLES (clean slate, order matters due to FK constraints)
-- ============================================================
DROP TABLE IF EXISTS contact_interest CASCADE;
DROP TABLE IF EXISTS contact_seeking  CASCADE;
DROP TABLE IF EXISTS my_contacts      CASCADE;
DROP TABLE IF EXISTS interests        CASCADE;
DROP TABLE IF EXISTS seeking          CASCADE;
DROP TABLE IF EXISTS profession       CASCADE;
DROP TABLE IF EXISTS zip_code         CASCADE;
DROP TABLE IF EXISTS status           CASCADE;


-- ============================================================
-- LOOKUP / REFERENCE TABLES
-- ============================================================

-- 1. profession  (UNIQUE constraint on the profession name)
CREATE TABLE profession (
    prof_id    SERIAL PRIMARY KEY,
    profession VARCHAR(100) NOT NULL UNIQUE   -- Requirement 1: UNIQUE constraint
);

-- 2. zip_code  (natural key, CHECK constraint limits code to 4 digits, province instead of state)
-- Requirement 2: natural key (zip_code is the PK, not a surrogate)
-- Requirement 3: province column instead of state
-- Requirement 4: all 9 SA provinces, 2 cities each
CREATE TABLE zip_code (
    zip_code CHAR(4)     NOT NULL
        CHECK (zip_code ~ '^\d{4}$'),         -- Requirement 2: exactly 4 digits
    city     VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL,
    PRIMARY KEY (zip_code)                    -- natural key
);

-- 3. status
CREATE TABLE status (
    status_id SERIAL PRIMARY KEY,
    status    VARCHAR(50) NOT NULL
);

-- 4. interests
CREATE TABLE interests (
    interest_id SERIAL PRIMARY KEY,
    interest    VARCHAR(100) NOT NULL
);

-- 5. seeking
CREATE TABLE seeking (
    seeking_id SERIAL PRIMARY KEY,
    seeking    VARCHAR(100) NOT NULL
);


-- ============================================================
-- MAIN TABLE
-- ============================================================
CREATE TABLE my_contacts (
    contact_id SERIAL PRIMARY KEY,
    last_name  VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    phone      VARCHAR(20),
    email      VARCHAR(150),
    gender     CHAR(1) CHECK (gender IN ('M','F','O')),
    birthday   DATE,
    prof_id    INT  REFERENCES profession(prof_id),
    zip_code   CHAR(4) REFERENCES zip_code(zip_code),
    status_id  INT  REFERENCES status(status_id)
);


-- ============================================================
-- JUNCTION / JOINING TABLES  (many-to-many)
-- ============================================================

-- contact_interest  (composite PK)
CREATE TABLE contact_interest (
    contact_id  INT NOT NULL REFERENCES my_contacts(contact_id),
    interest_id INT NOT NULL REFERENCES interests(interest_id),
    PRIMARY KEY (contact_id, interest_id)
);

-- contact_seeking  (composite PK)
CREATE TABLE contact_seeking (
    contact_id INT NOT NULL REFERENCES my_contacts(contact_id),
    seeking_id INT NOT NULL REFERENCES seeking(seeking_id),
    PRIMARY KEY (contact_id, seeking_id)
);


-- ============================================================
-- SEED DATA
-- ============================================================

-- ---- profession ----
INSERT INTO profession (profession) VALUES
    ('Software Engineer'),
    ('Data Analyst'),
    ('Nurse'),
    ('Teacher'),
    ('Accountant'),
    ('Lawyer'),
    ('Graphic Designer'),
    ('Entrepreneur'),
    ('Doctor'),
    ('Marketing Manager'),
    ('Civil Engineer'),
    ('Chef'),
    ('Journalist'),
    ('Pharmacist'),
    ('HR Specialist'),
    ('Financial Advisor'),
    ('Architect');


-- ---- zip_code (Requirement 4: all 9 provinces, 2 cities each) ----
INSERT INTO zip_code (zip_code, city, province) VALUES
    -- Gauteng
    ('2000', 'Johannesburg',  'Gauteng'),
    ('0001', 'Pretoria',      'Gauteng'),
    -- Western Cape
    ('8000', 'Cape Town',     'Western Cape'),
    ('7530', 'Stellenbosch',  'Western Cape'),
    -- KwaZulu-Natal
    ('4001', 'Durban',        'KwaZulu-Natal'),
    ('3200', 'Pietermaritzburg', 'KwaZulu-Natal'),
    -- Eastern Cape
    ('6001', 'Port Elizabeth', 'Eastern Cape'),
    ('5200', 'East London',   'Eastern Cape'),
    -- Limpopo
    ('0699', 'Polokwane',     'Limpopo'),
    ('0810', 'Tzaneen',       'Limpopo'),
    -- Mpumalanga
    ('1200', 'Nelspruit',     'Mpumalanga'),
    ('1050', 'Witbank',       'Mpumalanga'),
    -- North West
    ('2520', 'Rustenburg',    'North West'),
    ('2745', 'Mahikeng',      'North West'),
    -- Free State
    ('9300', 'Bloemfontein',  'Free State'),
    ('9870', 'Welkom',        'Free State'),
    -- Northern Cape
    ('8300', 'Kimberley',     'Northern Cape'),
    ('8800', 'Upington',      'Northern Cape');


-- ---- status ----
INSERT INTO status (status) VALUES
    ('Single'),
    ('Divorced'),
    ('Widowed'),
    ('Separated'),
    ('Never married');


-- ---- interests ----
INSERT INTO interests (interest) VALUES
    ('Hiking'),
    ('Reading'),
    ('Cooking'),
    ('Gaming'),
    ('Travel'),
    ('Music'),
    ('Photography'),
    ('Fitness'),
    ('Dancing'),
    ('Art'),
    ('Football'),
    ('Cycling'),
    ('Movies'),
    ('Yoga'),
    ('Volunteering');


-- ---- seeking ----
INSERT INTO seeking (seeking) VALUES
    ('Long-term relationship'),
    ('Friendship'),
    ('Casual dating'),
    ('Marriage'),
    ('Networking'),
    ('Adventure partner');


-- ---- my_contacts (Requirement 6: more than 15 contacts) ----
INSERT INTO my_contacts
    (last_name, first_name, phone, email, gender, birthday, prof_id, zip_code, status_id)
VALUES
    ('Dlamini',    'Sipho',     '0821234567', 'sipho@email.com',     'M', '1990-03-15', 1,  '2000', 1),
    ('Nkosi',      'Thandi',    '0837654321', 'thandi@email.com',    'F', '1992-07-22', 3,  '4001', 1),
    ('Van der Berg','Pieter',   '0840001111', 'pieter@email.com',    'M', '1985-11-01', 5,  '8000', 2),
    ('Botha',      'Anri',      '0812223333', 'anri@email.com',      'F', '1994-05-30', 4,  '7530', 1),
    ('Mokoena',    'Lerato',    '0834445555', 'lerato@email.com',    'F', '1988-09-10', 2,  '0001', 3),
    ('Sithole',    'Bongani',   '0856667777', 'bongani@email.com',   'M', '1991-12-25', 6,  '3200', 1),
    ('Pretorius',  'Liesl',     '0828889999', 'liesl@email.com',     'F', '1995-02-14', 7,  '2000', 1),
    ('Zulu',       'Musa',      '0810002222', 'musa@email.com',      'M', '1987-06-06', 8,  '6001', 5),
    ('Adams',      'Fatima',    '0843334444', 'fatima@email.com',    'F', '1993-01-19', 9,  '8000', 1),
    ('Naidoo',     'Ravi',      '0865556666', 'ravi@email.com',      'M', '1989-08-08', 10, '4001', 2),
    ('Maluleke',   'Grace',     '0877778888', 'grace@email.com',     'F', '1996-04-27', 11, '0699', 1),
    ('Coetzee',    'Riaan',     '0829990000', 'riaan@email.com',     'M', '1984-10-31', 12, '9300', 4),
    ('Khumalo',    'Nokwanda',  '0831112222', 'nokwanda@email.com',  'F', '1990-07-17', 13, '1200', 1),
    ('Jacobs',     'Cornelia',  '0843333333', 'cornelia@email.com',  'F', '1997-03-03', 14, '8300', 1),
    ('Shabalala',  'Themba',    '0855554444', 'themba@email.com',    'M', '1986-12-12', 15, '2520', 3),
    ('Meyer',      'Hendrik',   '0867775555', 'hendrik@email.com',   'M', '1992-09-09', 16, '9870', 2),
    ('Ntuli',      'Zanele',    '0819996666', 'zanele@email.com',    'F', '1994-11-22', 17, '8800', 1),
    ('Ferreira',   'Carina',    '0832227777', 'carina@email.com',    'F', '1991-06-15', 1,  '1050', 1),
    ('Masondo',    'Kabelo',    '0844448888', 'kabelo@email.com',    'M', '1988-02-28', 3,  '2745', 5),
    ('Williams',   'Naomi',     '0856669999', 'naomi@email.com',     'F', '1995-08-18', 5,  '5200', 1);


-- ============================================================
-- contact_interest  (Requirement 5: each contact gets 3+ interests)
-- ============================================================
INSERT INTO contact_interest (contact_id, interest_id) VALUES
    -- Sipho: Hiking, Football, Travel
    (1, 1),(1, 11),(1, 5),
    -- Thandi: Reading, Cooking, Music
    (2, 2),(2, 3),(2, 6),
    -- Pieter: Gaming, Cycling, Movies
    (3, 4),(3, 12),(3, 13),
    -- Anri: Yoga, Art, Photography
    (4, 14),(4, 10),(4, 7),
    -- Lerato: Travel, Fitness, Dancing
    (5, 5),(5, 8),(5, 9),
    -- Bongani: Football, Gaming, Hiking
    (6, 11),(6, 4),(6, 1),
    -- Liesl: Photography, Art, Cooking
    (7, 7),(7, 10),(7, 3),
    -- Musa: Music, Dancing, Travel
    (8, 6),(8, 9),(8, 5),
    -- Fatima: Volunteering, Reading, Yoga
    (9, 15),(9, 2),(9, 14),
    -- Ravi: Cycling, Fitness, Movies
    (10, 12),(10, 8),(10, 13),
    -- Grace: Cooking, Music, Art
    (11, 3),(11, 6),(11, 10),
    -- Riaan: Hiking, Football, Cycling
    (12, 1),(12, 11),(12, 12),
    -- Nokwanda: Reading, Photography, Volunteering
    (13, 2),(13, 7),(13, 15),
    -- Cornelia: Dancing, Yoga, Fitness
    (14, 9),(14, 14),(14, 8),
    -- Themba: Travel, Gaming, Movies
    (15, 5),(15, 4),(15, 13),
    -- Hendrik: Music, Football, Cooking
    (16, 6),(16, 11),(16, 3),
    -- Zanele: Art, Dancing, Reading
    (17, 10),(17, 9),(17, 2),
    -- Carina: Yoga, Cycling, Photography
    (18, 14),(18, 12),(18, 7),
    -- Kabelo: Hiking, Fitness, Gaming
    (19, 1),(19, 8),(19, 4),
    -- Naomi: Volunteering, Travel, Music
    (20, 15),(20, 5),(20, 6);


-- ============================================================
-- contact_seeking
-- ============================================================
INSERT INTO contact_seeking (contact_id, seeking_id) VALUES
    (1, 1),(1, 2),
    (2, 1),(2, 4),
    (3, 3),(3, 2),
    (4, 1),(4, 6),
    (5, 2),(5, 5),
    (6, 1),(6, 2),
    (7, 4),(7, 1),
    (8, 3),(8, 6),
    (9, 1),(9, 2),
    (10, 5),(10, 1),
    (11, 1),(11, 4),
    (12, 2),(12, 6),
    (13, 1),(13, 3),
    (14, 4),(14, 1),
    (15, 3),(15, 5),
    (16, 1),(16, 2),
    (17, 1),(17, 6),
    (18, 2),(18, 5),
    (19, 1),(19, 4),
    (20, 3),(20, 2);


-- ============================================================
-- LEFT JOIN QUERY
-- Displays: profession, zip_code, city, province, status,
--           interests (aggregated), seeking (aggregated)
-- ============================================================
SELECT
    c.contact_id,
    c.first_name,
    c.last_name,
    p.profession,
    z.zip_code,
    z.city,
    z.province,
    s.status,
    STRING_AGG(DISTINCT i.interest,  ', ' ORDER BY i.interest)  AS interests,
    STRING_AGG(DISTINCT sk.seeking,  ', ' ORDER BY sk.seeking)  AS seeking
FROM my_contacts c
    LEFT JOIN profession      p   ON c.prof_id    = p.prof_id
    LEFT JOIN zip_code        z   ON c.zip_code   = z.zip_code
    LEFT JOIN status          s   ON c.status_id  = s.status_id
    LEFT JOIN contact_interest ci ON c.contact_id = ci.contact_id
    LEFT JOIN interests        i  ON ci.interest_id = i.interest_id
    LEFT JOIN contact_seeking  cs ON c.contact_id = cs.contact_id
    LEFT JOIN seeking          sk ON cs.seeking_id  = sk.seeking_id
GROUP BY
    c.contact_id,
    c.first_name,
    c.last_name,
    p.profession,
    z.zip_code,
    z.city,
    z.province,
    s.status
ORDER BY
    c.contact_id;
