--SQL project Spotify
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

SELECT* FROM SPOTIFY;

--EDA

SELECT COUNT(*) FROM SPOTIFY;
--NUMBER OF DISTINCT ALBUMS
SELECT COUNT(DISTINCT ALBUM) FROM SPOTIFY;
--NUMBER OF ARTISTS
SELECT COUNT(DISTINCT ARTIST) FROM SPOTIFY;
--NUMBER OF TYPES OF ALBUMS
SELECT DISTINCT ALBUM_TYPE FROM SPOTIFY;

--AVERAGE DANCEABILITY
SELECT AVG(danceability) FROM SPOTIFY;

--MAX DURATION
SELECT MAX(duration_min) FROM SPOTIFY;

--MINIMUMU DURATION
SELECT MIN(duration_min) FROM SPOTIFY;

--DURATION CAN'T BE 0 THEREFORE WE HAVE TO DEAL WITH THAT

SELECT* FROM SPOTIFY
WHERE duration_min=0;

DELETE FROM SPOTIFY
WHERE duration_min=0;

--DISTINCT CHANELS
SELECT COUNT(DISTINCT channel) FROM SPOTIFY;

SELECT DISTINCT(most_played_on) from spotify;

SELECT MAX(LOUDNESS) FROM SPOTIFY;

--DELETING ROWS WHERE LOUDNESS IS MORE THAT 0
SELECT ARTIST FROM SPOTIFY
WHERE LOUDNESS>=0;

DELETE FROM SPOTIFY
WHERE LOUDNESS>=0;
-- FINDING UNUSUSAL ENTRIES
SELECT* FROM SPOTIFY
WHERE LIKES>VIEWS;



--Q1. Retrieve the names of all tracks that have more than 1 billion streams.
SELECT TITLE  FROM SPOTIFY
WHERE STREAM>1000000000;

--Q2. List all albums along with their respective artists.
SELECT DISTINCT ALBUM, ARTIST FROM SPOTIFY; 

--Q3. Get the total number of comments for tracks where licensed = TRUE.

SELECT SUM(COMMENTS) FROM SPOTIFY
WHERE LICENSED='TRUE';

--Q4.Find all tracks that belong to the album type single.
SELECT* FROM SPOTIFY
WHERE ALBUM_TYPE='single';

--Q5. Count the total number of tracks by each artist.
SELECT 
ARTIST, 
COUNT(*) AS NUMBER_OF_TRACKS
FROM SPOTIFY
GROUP BY ARTIST
ORDER BY 2 DESC;

SELECT 
ARTIST, 
COUNT(*) AS NUMBER_OF_TRACKS
FROM SPOTIFY
GROUP BY ARTIST
ORDER BY 2;
--MAX NUM OF SONGS BY AN ARTIST ARE 10 AND MIN IS 1.
---------------------------------------------------------------------------------------------


--Q6. Calculate the average danceability of tracks in each album.
SELECT ALBUM, DANCEABILITY FROM SPOTIFY;

SELECT ALBUM,
AVG(DANCEABILITY) AS AVGERAGE_DANCEABILITY
FROM SPOTIFY
GROUP BY ALBUM
ORDER BY 2 DESC;

--Q7. Find the top 5 tracks with the highest energy values.
SELECT DISTINCT TRACK, ENERGY
FROM SPOTIFY
ORDER BY ENERGY DESC LIMIT 5;

SELECT 
TRACK,
AVG(ENERGY) AS AVG_ENGERGY
FROM SPOTIFY
GROUP BY TRACK
ORDER BY 2 DESC LIMIT 5;

--Q8. List all tracks along with their views and likes where official_video = TRUE.
SELECT TRACK,
SUM(VIEWS) AS TOTAL_VIEWS,
SUM(LIKES) AS TOTAL_LIKES
FROM SPOTIFY
WHERE OFFICIAL_VIDEO='TRUE'
GROUP BY TRACK
ORDER BY 3 DESC
;

--Q9. For each album, calculate the total views of all associated tracks.
SELECT* FROM SPOTIFY;

SELECT 
ALBUM,
TRACK,
SUM(VIEWS) AS TOTAL_VEIWS
FROM SPOTIFY
GROUP BY 1,2
ORDER BY 3 DESC;

--Q10. Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT TRACK, STREAM, MOST_PLAYED_ON FROM SPOTIFY;

SELECT* FROM
(SELECT 
TRACK,
COALESCE(SUM(CASE WHEN MOST_PLAYED_ON='Spotify' THEN STREAM END),0) AS TOTAL_STREAM_ON_SPOTIFY,
COALESCE(SUM(CASE WHEN MOST_PLAYED_ON='Youtube' THEN STREAM END),0) AS TOTAL_STREAMS_ON_YOUTUBE
FROM SPOTIFY
GROUP BY TRACK) AS CONDITIONS 
WHERE 
TOTAL_STREAM_ON_SPOTIFY>TOTAL_STREAMS_ON_YOUTUBE
AND TOTAL_STREAMS_ON_YOUTUBE>0;
------------------------------------------------------------------------------------------------------------
--Q11. Find the top 3 most-viewed tracks for each artist using window functions.
WITH RANK_OF_ARTIST
AS
(SELECT 
ARTIST,
TRACK, 
SUM(VIEWS), 
DENSE_RANK() OVER (PARTITION BY ARTIST ORDER BY SUM(VIEWS)DESC) AS RANK 
FROM SPOTIFY
GROUP BY ARTIST, TRACK
ORDER BY 1,3 DESC
)
SELECT* FROM RANK_OF_ARTIST
WHERE RANK<4;

--Q12. Write a query to find tracks where the liveness score is above the average.
SELECT TRACK, LIVENESS
FROM SPOTIFY;
EXPLAIN ANALYZE 
SELECT*
FROM SPOTIFY
WHERE LIVENESS>0.1936647867482756 ;

SELECT AVG(LIVENESS) FROM SPOTIFY;----0.1936647867482756


--Q13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
SELECT ALBUM, TRACK, ENERGY FROM SPOTIFY;

WITH CTE
AS
(SELECT
ALBUM,
MAX(ENERGY) AS HIGHEST_ENERGY,
MIN(ENERGY) AS lOWEST_ENERGY
FROM SPOTIFY
GROUP BY ALBUM)
SELECT ALBUM,
HIGHEST_ENERGY-lOWEST_ENERGY AS ENERGY_DIFF
FROM CTE 
ORDER BY 2 DESC;
-------------------------------------------------------------------------------------
--QUESRY OPTIMIZATION

EXPLAIN ANALYSE
SELECT
ALBUM, TRACK
FROM SPOTIFY 
WHERE ARTIST='50 Cent';----Execution Time: 4.921 ms

CREATE INDEX ARTIST_INDEX ON SPOTIFY(ARTIST);

EXPLAIN ANALYSE
SELECT
ALBUM, TRACK
FROM SPOTIFY 
WHERE ARTIST='50 Cent'-----Execution Time: 1.495 ms