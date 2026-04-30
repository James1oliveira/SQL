-- ================================================================
-- CHAPTER 7: Table Design That Works for You
-- TRY IT YOURSELF - EXERCISES
-- ================================================================

-- Given these starting tables:
--
-- CREATE TABLE albums (
--     album_id bigserial,
--     album_catalog_code varchar(100),
--     album_title text,
--     album_artist text,
--     album_release_date date,
--     album_genre varchar(40),
--     album_description text
-- );
--
-- CREATE TABLE songs (
--     song_id bigserial,
--     song_title text,
--     song_artist text,
--     album_id bigint
-- );


-- ----------------------------------------------------------------
-- Exercise 1:
-- Modify both CREATE TABLE statements to add primary keys,
-- a foreign key, and additional constraints.
-- ----------------------------------------------------------------

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
-- Reasoning:
-- - album_id is a surrogate primary key (auto-increments).
-- - album_catalog_code is UNIQUE because each album has one code.
-- - title and artist are NOT NULL because an album must have both.

-- CREATE TABLE songs (
--     song_id bigserial,
--     song_title text NOT NULL,
--     song_artist text NOT NULL,
--     album_id bigint REFERENCES albums (album_id) ON DELETE CASCADE,
--     CONSTRAINT song_id_key PRIMARY KEY (song_id)
-- );
-- Reasoning:
-- - song_id is the primary key.
-- - album_id is a foreign key linking to albums.
-- - ON DELETE CASCADE removes songs if the album is deleted.
-- - song_title and song_artist are NOT NULL.


-- ----------------------------------------------------------------
-- Exercise 2:
-- Could album_catalog_code serve as a natural key?
-- ----------------------------------------------------------------

-- Yes — IF we can confirm:
--   1. Every album has a catalog code (no NULLs).
--   2. Each catalog code is unique across all albums.
--   3. The code never changes once assigned.
-- If all three are true, it can replace album_id as the primary key.
-- In practice, labels and distributors sometimes reuse or change codes,
-- so a surrogate key (album_id) is safer.


-- ----------------------------------------------------------------
-- Exercise 3:
-- Which columns are good candidates for indexes?
-- ----------------------------------------------------------------

-- Good index candidates:
-- albums: album_title (searched by title), album_artist (searched by artist)
-- songs: song_title (searched by title), album_id (used in joins)
--
-- CREATE INDEX album_title_idx ON albums (album_title);
-- CREATE INDEX album_artist_idx ON albums (album_artist);
-- CREATE INDEX song_title_idx ON songs (song_title);
-- CREATE INDEX songs_album_id_idx ON songs (album_id);
--
-- Indexes speed up queries on columns used in WHERE and JOIN clauses.
-- The primary keys already have indexes automatically.
