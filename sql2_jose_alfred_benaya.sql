-- No. 3
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR NOT NULL,
    last_name VARCHAR DEFAULT NULL,
    email VARCHAR UNIQUE NOT NULL,
    age INT DEFAULT 18,
    gender VARCHAR CHECK (gender IN ('male', 'female')),
    date_of_birth DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- No. 4
CREATE OR REPLACE FUNCTION count_movies_by_genre(genre_title VARCHAR)
RETURNS INTEGER AS $$
DECLARE
    movie_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO movie_count
    FROM movie
    JOIN movie_genres ON movie.mov_id = movie_genres.mov_id
    JOIN genres ON movie_genres.gen_id = genres.gen_id
    WHERE genres.gen_title = genre_title;

    RETURN movie_count;
END;
$$ LANGUAGE plpgsql;

-- No. 5
SELECT
    DISTINCT mov_title movie,
    genres.gen_title genre
FROM
    movie
JOIN
    movie_genres ON movie.mov_id = movie_genres.mov_id
JOIN
    genres ON movie_genres.gen_id = genres.gen_id
WHERE
    movie.mov_id IN (SELECT mov_id FROM rating WHERE rev_stars > 8.0);

-- No. 6
-- Cek sebelum Index
SET enable_seqscan = off;
EXPLAIN ANALYZE
SELECT nama, desa
FROM ninja
WHERE email = 'naruto@mail.com';

-- Buat Index
CREATE INDEX idx_email ON ninja(email);

-- Cek setelah Index
EXPLAIN ANALYZE
SELECT nama, desa
FROM ninja
WHERE email = 'naruto@mail.com';


-- No. 7
WITH ranked_movies AS (
    SELECT
        mov_title,
        gen_title,
        rev_stars,
        RANK() OVER (PARTITION BY genres.gen_id ORDER BY rev_stars DESC) AS rating_rank
    FROM
        movie
    JOIN
        movie_genres ON movie.mov_id = movie_genres.mov_id
    JOIN
        genres ON movie_genres.gen_id = genres.gen_id
    JOIN
        rating ON movie.mov_id = rating.mov_id
)
SELECT
    mov_title,
    gen_title,
    rev_stars
FROM
    ranked_movies
WHERE
    rating_rank = 1
ORDER BY rev_stars DESC;

