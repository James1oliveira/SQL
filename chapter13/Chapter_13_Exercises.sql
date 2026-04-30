-- ================================================================
-- CHAPTER 13: Mining Text to Find Meaningful Data
-- TRY IT YOURSELF - EXERCISES
-- ================================================================
-- Requires: crime_reports and president_speeches tables from Chapter 13


-- ----------------------------------------------------------------
-- Exercise 1:
-- Re-run the speeches ranking query but use ts_rank_cd() instead
-- of ts_rank() to search for the word 'economy'.
-- Compare the scores — ts_rank_cd() weights terms that appear
-- close together more heavily (cover density ranking).
-- ----------------------------------------------------------------

-- Using ts_rank():
-- SELECT president,
--        speech_date,
--        ts_rank(search_speech_text,
--                to_tsquery('economy')) AS rank_score
-- FROM president_speeches
-- WHERE search_speech_text @@ to_tsquery('economy')
-- ORDER BY rank_score DESC
-- LIMIT 5;

-- Using ts_rank_cd() (cover density — considers proximity):
-- SELECT president,
--        speech_date,
--        ts_rank_cd(search_speech_text,
--                   to_tsquery('economy')) AS rank_cd_score
-- FROM president_speeches
-- WHERE search_speech_text @@ to_tsquery('economy')
-- ORDER BY rank_cd_score DESC
-- LIMIT 5;

-- Compare both side by side:
-- SELECT president,
--        speech_date,
--        ts_rank(search_speech_text, to_tsquery('economy'))    AS ts_rank,
--        ts_rank_cd(search_speech_text, to_tsquery('economy')) AS ts_rank_cd
-- FROM president_speeches
-- WHERE search_speech_text @@ to_tsquery('economy')
-- ORDER BY ts_rank DESC
-- LIMIT 10;


-- ----------------------------------------------------------------
-- Exercise 2:
-- Find speeches that mention 'snow' or 'winter'.
-- Use ts_headline() to display the surrounding context.
-- Show: president, speech date, and the highlighted excerpt.
-- ----------------------------------------------------------------

-- SELECT president,
--        speech_date,
--        ts_headline(speech_text,
--                    to_tsquery('snow | winter'),
--                    'StartSel = <,
--                     StopSel = >,
--                     MinWords=5,
--                     MaxWords=10,
--                     MaxFragments=1')
--            AS highlighted_excerpt
-- FROM president_speeches
-- WHERE search_speech_text @@ to_tsquery('snow | winter')
-- ORDER BY speech_date;


-- ----------------------------------------------------------------
-- Exercise 3:
-- Add a second_date column to the crime_reports table.
-- Populate it with the SECOND date found in original_text
-- (if a second date exists — some reports span two dates).
-- Use regexp_matches() with the 'g' flag, then skip the first
-- result using a subquery approach.
-- ----------------------------------------------------------------

-- Step 1: Add the column.
-- ALTER TABLE crime_reports ADD COLUMN second_date timestamp with time zone;

-- Step 2: Use a lateral subquery to get the second match.
-- UPDATE crime_reports cr
-- SET second_date = (
--     SELECT matches[1]::timestamptz
--     FROM regexp_matches(cr.original_text, '\d{1,2}\/\d{1,2}\/\d{2}', 'g')
--         AS t(matches)
--     OFFSET 1
--     LIMIT 1
-- );

-- Step 3: Verify the results.
-- SELECT crime_id, date_1, second_date
-- FROM crime_reports
-- ORDER BY crime_id;

-- Note: Rows with only one date in the text will have NULL in second_date.
-- That is expected and correct behavior.
