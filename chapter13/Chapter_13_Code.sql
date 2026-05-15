-- ================================================================
-- CHAPTER 13: Mining Text to Find Meaningful Data
-- MAIN CODE + EXERCISES
-- Data files: C:\SQL\
-- ================================================================
-- REQUIRED FILE (download from nostarch.com):
--   crime_reports.csv


-- ================================================================
-- String Functions
-- ================================================================

-- Case formatting:
SELECT upper('hello');              -- HELLO
SELECT lower('HELLO');              -- hello
SELECT initcap('once upon a time'); -- Once Upon A Time

-- Character info:
SELECT char_length('hello');   -- 5
SELECT length('hello');        -- 5 (PostgreSQL-specific)
SELECT position(',' IN 'Tan, Bella');  -- 4

-- Extract and replace:
SELECT left('703-555-1212', 3);          -- 703
SELECT right('703-555-1212', 8);         -- 555-1212
SELECT trim('   hello   ');              -- hello
SELECT trim(leading ' ' FROM '   hello');
SELECT trim(trailing ' ' FROM 'hello   ');
SELECT replace('hello world', 'world', 'there');

-- Concatenation:
SELECT 'Hello' || ' ' || 'World';


-- ================================================================
-- Parsing Crime Reports with Regular Expressions
-- ================================================================

-- Create and load crime reports table:
CREATE TABLE crime_reports (
    crime_id bigserial PRIMARY KEY,
    date_1 timestamp with time zone,
    date_2 timestamp with time zone,
    street varchar(250),
    city varchar(100),
    crime_type varchar(100),
    description text,
    case_number varchar(50),
    original_text text NOT NULL
);

COPY crime_reports (original_text)
FROM 'C:\SQL\crime_reports.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT original_text FROM crime_reports;

-- Match the first date from original_text:
SELECT crime_id,
       regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}') AS date_1
FROM crime_reports;

-- Find all dates in text:
SELECT crime_id,
       regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}', 'g') AS dates
FROM crime_reports;

-- Extract multiple fields at once using one regex with capture groups:
SELECT
    regexp_match(original_text,
        '(?:C0|SO)[0-9]+') AS case_number,
    regexp_match(original_text,
        '\d{1,2}\/\d{1,2}\/\d{2}') AS date_1,
    regexp_match(original_text,
        '\n(?:\d{4}|) (\w+ \w+|\w+)(:|)') AS street,
    regexp_match(original_text,
        '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n') AS city
FROM crime_reports;

-- Extract from array result with index [1]:
SELECT
    (regexp_match(original_text, '(?:C0|SO)[0-9]+'))[1] AS case_number,
    (regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1] AS date_1,
    (regexp_match(original_text, '\n(?:\d{4}|) (\w+ \w+|\w+)(:|)'))[1] AS street
FROM crime_reports;

-- Update the structured columns from original_text:
UPDATE crime_reports
SET date_1 = (regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1]::timestamptz,
    case_number = (regexp_match(original_text, '(?:C0|SO)[0-9]+'))[1],
    street = (regexp_match(original_text, '\n(?:\d{4}|) (\w+ \w+|\w+)(:|)'))[1],
    city = (regexp_match(original_text, '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n'))[1],
    crime_type = (regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.*):'))[1],
    description = (regexp_match(original_text, ':\s(.+)(?:\n|$)'))[1];


-- ================================================================
-- Full Text Search
-- ================================================================

-- Convert text to tsvector:
SELECT to_tsvector('I am walking across the sitting room to sit with you.');

-- Convert query to tsquery:
SELECT to_tsquery('walking & sitting');

-- Match check:
SELECT to_tsvector('I am walking') @@ to_tsquery('walking');  -- true
SELECT to_tsvector('I am walking') @@ to_tsquery('running');  -- false

-- Create a speeches table for full text search:
CREATE TABLE president_speeches (
    sotu_id serial PRIMARY KEY,
    president varchar(100) NOT NULL,
    title varchar(250) NOT NULL,
    speech_date date NOT NULL,
    speech_text text NOT NULL,
    search_speech_text tsvector
);

-- NOTE: The .txt file splits speeches across multiple lines and cannot be loaded
-- directly with FORMAT TEXT. Use the .csv file with QUOTE '@' instead.
-- The '@' character marks the start of each speech_text field in the file.
COPY president_speeches (president, title, speech_date, speech_text)
FROM 'C:\SQL\sotu-1946-1977.csv'
WITH (FORMAT CSV, DELIMITER '|', QUOTE '@', ENCODING 'WIN1252');

-- Update to populate the tsvector search column:
UPDATE president_speeches
SET search_speech_text = to_tsvector('english', speech_text);

-- Create GIN index for full text search:
CREATE INDEX search_idx ON president_speeches USING gin(search_speech_text);

-- Query the tsvector column:
SELECT president, speech_date
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('vietnam')
ORDER BY speech_date;

-- Multiple terms (AND):
SELECT president, speech_date
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & (peace | economy)')
ORDER BY speech_date;

-- Highlight matching terms:
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('tranquility'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('tranquility');

-- Rank results:
SELECT president,
       speech_date,
       ts_rank(search_speech_text, to_tsquery('war & security')) AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security')
ORDER BY score DESC
LIMIT 5;


-- ================================================================
-- CHAPTER 13: Try It Yourself Exercises
-- ================================================================

-- Exercise 1: Use ts_rank_cd() (cover density) to rank speeches by
-- the term 'economy' and compare results with ts_rank().
SELECT president, speech_date,
       ts_rank_cd(search_speech_text, to_tsquery('economy')) AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('economy')
ORDER BY score DESC
LIMIT 5;


-- Exercise 2: Find speeches mentioning 'snow' or 'winter' using ts_headline()
-- to display the surrounding context.
SELECT president,
       speech_date,
       ts_headline(speech_text,
                   to_tsquery('snow | winter'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=10,
                    MaxFragments=1')
           AS highlighted_excerpt
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('snow | winter')
ORDER BY speech_date;


-- Exercise 3: Add a second_date column to crime_reports and populate
-- it with the second date found in original_text (if any).

-- Step 1: Add the column.
ALTER TABLE crime_reports ADD COLUMN second_date timestamp with time zone;

-- Step 2: Use a lateral subquery to get the second match.
UPDATE crime_reports cr
SET second_date = (
    SELECT matches[1]::timestamptz
    FROM regexp_matches(cr.original_text, '\d{1,2}\/\d{1,2}\/\d{2}', 'g')
        AS t(matches)
    OFFSET 1
    LIMIT 1
);

-- Step 3: Verify the results.
-- Note: Rows with only one date in the text will have NULL in second_date.
-- That is expected and correct behavior.
SELECT crime_id, date_1, second_date
FROM crime_reports
ORDER BY crime_id;