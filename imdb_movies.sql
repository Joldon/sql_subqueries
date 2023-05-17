USE imdb_ijs;



/* How many actors are there in the actors table?
How many directors are there in the directors table?
How many movies are there in the movies table?
*/

 SELECT COUNT(first_name)
 FROM actors; -- 817718
 
 select count(id)
 from directors; -- 86880
 
 select count(id)
 from movies; -- 388269
 
 /* From what year are the oldest and the newest movies? What are the names of those movies?
What movies have the highest and the lowest ranks?
What is the most common movie title?
*/
select * from movies;
select min(year), max(year) -- 1888, 2008
from movies;

select name, year
from movies
where year IN (1888, 2008);
-- Harry Potter and the Half-Blood Prince 2008,  
-- Roundhay Garden Scene 1888
-- Traffic Crossing Leeds Bridge 1888

/* 
Hulyas solution
SELECT `year` FROM movies
ORDER BY `year` DESC;

SELECT `year`, `name` FROM movies
WHERE `year`='2008' OR `year`='1888';
*/

select MIN(`rank`), MAX(`rank`)
from movies
where `rank` IS NOT NULL; -- 1, 9.9

SELECT name, COUNT(*) as count
FROM movies
GROUP BY name
ORDER BY count DESC; -- Eurovision Song Contest, The
-- Limit 1 if you want to see exactly that item


-- UNDERSTANDING THE DATABASE
-- Are there movies with multiple directors?
SELECT m.name AS movie_name, COUNT(DISTINCT d.id) AS director_count
FROM movies AS m
INNER JOIN movies_directors AS md ON m.id = md.movie_id
INNER JOIN directors AS d ON md.director_id = d.id
GROUP BY m.name
HAVING director_count > 1;

-- What is the movie with the most directors? Why do you think it has so many?
-- this one aggregates all directors by the movies with the same name but produced in different years
-- basically thsi sums up directors from different movies but have the same name
SELECT m.name AS movie_name, COUNT(DISTINCT d.id) AS director_count
FROM movies AS m
INNER JOIN movies_directors AS md ON m.id = md.movie_id
INNER JOIN directors AS d ON md.director_id = d.id
GROUP BY m.name
ORDER BY director_count DESC;

-- this code separates movies with the same name but with different years treating them as separate entities
-- but there are the same number of directors
SELECT m.name AS movie_name, m.year, COUNT(DISTINCT d.id) AS director_count
FROM movies AS m
INNER JOIN movies_directors AS md ON m.id = md.movie_id
INNER JOIN directors AS d ON md.director_id = d.id
GROUP BY m.name, m.year
HAVING director_count > 1
ORDER BY COUNT(DISTINCT d.id) DESC;

-- this code sorts the list by number of directors but there is another error because teh least number of directors is 9
-- which is not realistic. Check what causes this bug
SELECT m.name AS movie_name, m.year, COUNT(DISTINCT d.id) AS director_count
FROM movies AS m
INNER JOIN movies_directors AS md ON m.id = md.movie_id
INNER JOIN directors AS d ON md.director_id = d.id
GROUP BY m.name, m.year
HAVING director_count > 1
ORDER BY director_count DESC;



-- shows number of actors count per movie
SELECT m.name AS movie_name, COUNT(DISTINCT a.id) AS actor_count
FROM movies AS m
JOIN roles AS r ON m.id = r.movie_id
JOIN actors AS a ON r.actor_id = a.id
GROUP BY m.id;

-- On average, how many actors are listed by movie?
SELECT AVG(actor_count) AS average_actors_per_movie
FROM (
  SELECT m.id AS movie_id, COUNT(DISTINCT a.id) AS actor_count
  FROM movies AS m
  JOIN roles AS r ON m.id = r.movie_id
  JOIN actors AS a ON r.actor_id = a.id
  GROUP BY m.id
) AS actor_counts; -- 11.4287


-- Are there movies with more than one “genre”?

-- this probably selects correctly but displays only id and name columns
SELECT m.id, m.name, COUNT(mg.genre)
FROM movies AS m
JOIN movies_genres AS mg ON m.id = mg.movie_id
GROUP BY m.id, m.name
HAVING COUNT(DISTINCT mg.genre) > 1
ORDER BY COUNT(mg.genre) DESC;

-- this uses GROUP_CONCAT and outputs also genres per movie 
SELECT m.id, m.name, mg.genre
FROM movies AS m
JOIN (
    SELECT movie_id, GROUP_CONCAT(genre SEPARATOR ', ') AS genre
    FROM (
        SELECT DISTINCT movie_id, genre
        FROM movies_genres
    ) AS mg
    GROUP BY movie_id
    HAVING COUNT(*) > 1
) AS mg
ON m.id = mg.movie_id;
/*
The below query joins the movies table with the movies_genres table twice, using different aliases (mg1 and mg2). 
The first join matches the movies with their genres, and the second join matches the movies with other genres 
that are different from the first one. The query then selects only 
the distinct combinations of id, name, and the two genres. 
This will give us all movies that have at least two different genres.
*/
SELECT DISTINCT m.id, m.name, mg1.genre, mg2.genre
FROM movies AS m
JOIN movies_genres AS mg1 ON m.id = mg1.movie_id
JOIN movies_genres AS mg2 ON mg1.movie_id = mg2.movie_id AND mg1.genre <> mg2.genre;

/*
Looking for specific movies
*/

-- Can you find the movie called “Pulp Fiction” 
SELECT name
FROM movies
WHERE name='Pulp Fiction';

-- Who directed it?
SELECT m.name, d.first_name, d.last_name
FROM directors AS d
JOIN movies_directors as md
ON d.id=md.director_id
JOIN movies as m
ON md.movie_id=m.id
WHERE m.name = 'Pulp Fiction';

select * from movies_directors;

-- Which actors where casted on it?

SELECT a.first_name, a.last_name
FROM actors as a
RIGHT JOIN roles as r
ON a.id = r.actor_id
JOIN movies as m
ON m.id=r.movie_id
WHERE m.name = 'Pulp Fiction';

-- Can you find the movie called “La Dolce Vita”?

-- this query to find movie 'La Dolce Vita', with normal query does not find it
SELECT name
FROM movies
WHERE name='La Dolce Vita';
SELECT name
FROM movies
WHERE LOWER(name) LIKE '%dolce%';

-- and then next step is:
SELECT name
FROM movies
WHERE name = 'Dolce vita, La';

-- Who directed it?
SELECT d.first_name, d.last_name
FROM directors as d
RIGHT JOIN movies_directors as md
ON d.id = md.director_id
LEFT JOIN movies as m
ON md.movie_id = m.id
WHERE m.name = 'Dolce vita, La';

-- Which actors where casted on it?
SELECT a.first_name, a.last_name, r.actor_id
FROM actors as a
LEFT JOIN roles as r
ON a.id = r.actor_id
RIGHT JOIN movies as m
ON m.id = r.movie_id
where m.name = 'Dolce vita, La';


/* When was the movie “Titanic” by James Cameron released?
Hint: there are many movies named “Titanic”. We want the one directed by James Cameron.
Hint 2: the name “James Cameron” is stored with a weird character on it.*/

SELECT year, m.name
FROM movies as m
JOIN movies_directors as md
ON m.id = md.movie_id
JOIN directors as d
ON md.director_id = d.id
WHERE m.name = 'Titanic' AND (LOWER(d.first_name)LIKE '%James%' AND LOWER(d.last_name) LIKE '%Cameron%')
;

-- Actors and directors

-- Who is the actor that acted more times as “Himself”?
SELECT COUNT(a.id), a.first_name, a.last_name
FROM actors AS a
JOIN roles as r
	ON r.actor_id = a.id
-- WHERE r.role = LOWER('Himself') this one loses some values that appear together with himself
WHERE r.role LIKE '%Himself%'
GROUP BY a.id
ORDER BY COUNT(a.id) DESC
LIMIT 5;


-- What is the most common name for actors? 
SELECT COUNT(first_name), first_name
FROM actors
GROUP BY first_name
ORDER BY COUNT(first_name) DESC
;

SELECT COUNT(last_name), last_name
FROM actors
GROUP BY last_name
ORDER BY COUNT(last_name) DESC
;

WITH concat_names as (SELECT 
    concat(first_name,' ',last_name) fullname
FROM
	actors)
SELECT fullname, COUNT(fullname)
FROM concat_names
GROUP BY 1
ORDER BY 2 DESC;

-- And for directors?
SELECT COUNT(first_name), first_name
FROM directors
GROUP BY 2
ORDER BY 1 DESC
LIMIT 10
;

SELECT COUNT(last_name), last_name
FROM directors
GROUP BY 2
ORDER BY 1 DESC
LIMIT 10;

-- concat and with
WITH concat_names AS (SELECT 
	concat(first_name, ' ', last_name) AS fullname
FROM directors)
SELECT COUNT(fullname), fullname
FROM concat_names
GROUP BY 2
ORDER BY 1 DESC
;

-- Analysing genders


-- How many actors are male and how many are female?
SELECT COUNT(id), gender
FROM actors
GROUP BY gender
; -- M 513306, F = 304412

-- What percentage of actors are female, and what percentage are male?
SELECT 
(SELECT COUNT(id)
FROM actors
WHERE gender LIKE '%f%')
/
(SELECT COUNT(id)
FROM actors)
; -- 0.3723 37% females

-- Movies across time

-- How many of the movies were released after the year 2000?
SELECT *
FROM movies
WHERE year >= 2001;


-- How many of the movies where released between the years 1990 and 2000?
SELECT name, year
FROM movies
WHERE year BETWEEN 1990 AND 2000
;
-- Which are the 3 years with the most movies? How many movies were produced on those years?
SELECT COUNT(year), year
FROM movies
GROUP BY year
ORDER BY COUNT(year) DESC
LIMIT 3
;

-- with window function and WITH
WITH cte AS (SELECT
	RANK() OVER (ORDER BY COUNT(id) DESC) ranking,
    year,
    count(id) total
FROM movies
GROUP BY year
ORDER BY 1)
SELECT ranking, year, total
FROM cte
WHERE ranking <= 3;

-- What are the top 5 movie genres?
SELECT COUNT(genre), genre
FROM movies_genres
GROUP BY genre
ORDER BY COUNT(genre) DESC
LIMIT 5
;

-- with window function and WITH
WITH cte AS (SELECT
	RANK() OVER (ORDER BY COUNT(movie_id) DESC) ranking,
    genre,
    COUNT(movie_id) total
FROM movies_genres
GROUP BY genre
ORDER BY 1)
SELECT ranking, genre, total
FROM cte
WHERE ranking <= 5;


-- What are the top 5 movie genres before 1920?
SELECT COUNT(genre), genre
FROM movies_genres
WHERE year <= 1920
GROUP BY genre
ORDER BY COUNT(genre) DESC
;


WITH century_movies AS (
SELECT COUNT(genre), genre
FROM movies_genres
GROUP BY genre
ORDER BY COUNT(genre) DESC
LIMIT 5)
SELECT genre
FROM century_movies
;
-- WITH old_movies AS (
-- SELECT movies
-- WHERE year <= 1920)
-- SELECT COUNT(genre), genre
-- FROM movies_genres
-- WHERE genre IN (old_movies)
-- ;

-- working solution
SELECT COUNT(mg.genre) AS genre_count, mg.genre
FROM movies_genres AS mg
WHERE mg.movie_id IN (
    SELECT id
    FROM movies
    WHERE year <= 1920
)
GROUP BY mg.genre
ORDER BY genre_count DESC
LIMIT 5;



-- with window function and WITH
WITH cte AS (SELECT
	RANK() OVER (ORDER BY COUNT(movie_id) DESC) ranking,
    genre,
    COUNT(movie_id) total
FROM movies_genres
WHERE movie_id IN (SELECT id FROM movies WHERE year < 1920)
GROUP BY genre
ORDER BY 1)
SELECT ranking, genre, total
FROM cte
WHERE ranking <= 5;

-- What is the evolution of the top movie genres across all the decades of the 20th century?
with genre_count_per_decade as (
select rank() over (partition by decade order by movies_per_genre desc) ranking, genre, decade
from (SELECT 
    genre,
    FLOOR(m.year / 10) * 10 AS decade,
    COUNT(genre) AS movies_per_genre
FROM
    movies_genres mg
        JOIN
    movies m ON m.id = mg.movie_id
GROUP BY decade , genre) as a
)
select genre, decade
FROM genre_count_per_decade
WHERE ranking = 1;



-- preliminary step
with temp_actors as (
    select 
        *,
        concat(first_name, ' ', last_name) as full_name
    from actors
    order by full_name
    limit 2000
    ),
temp_movies as (
    select 
        *,
        floor(year / 10) * 10 as decade
    from movies
    limit 2000
    ),
decade_count as (
    select tm.decade, ta.full_name, count(ta.full_name) as full_name_count
    from temp_actors ta
    join roles r
        on ta.id = r.actor_id
    join temp_movies tm
        on r.movie_id = tm.id
    where tm.`year` between 1900 and 2000
    group by tm.decade, ta.full_name
)

select decade, max(full_name_count)
from decade_count
group by decade;



-- Joan's solution
with temp_actors as (
    select 
        *,
        concat(first_name, ' ', last_name) as full_name
    from actors
    order by full_name
    -- limit 2000
    ),
temp_movies as (
    select 
        *,
        floor(year / 10) * 10 as decade
    from movies
    -- limit 2000
    ),
decade_count as (
    select tm.decade, ta.full_name, count(ta.full_name) as full_name_count
    from temp_actors ta
    join roles r
        on ta.id = r.actor_id
    join temp_movies tm
        on r.movie_id = tm.id
    where tm.`year` between 1900 and 2000
    group by tm.decade, ta.full_name
),
ranked_actors as (
    select 
        decade, full_name, full_name_count,
        row_number() over (partition by decade order by full_name_count desc) as rn
    from decade_count
)

select * 
from ranked_actors
where rn = 1
order by decade;


select * from directors;
select * from movies;
select * from directors_genres;
select * from actors;
select * from movies_genres;
select * from roles;


-- Get the most common actor name for each decade in the XX century.

WITH temp_actors AS ( -- the below query is probably not correct
    SELECT *,
        CONCAT(first_name, ' ', last_name) AS full_name
    FROM actors
    ORDER BY full_name
    LIMIT 2000    
),
temp_movies AS (
    SELECT *,
        FLOOR(year / 10) * 10 AS decade
    FROM movies
    LIMIT 2000
),
decade_count AS (
    SELECT
        tm.decade,
        ta.full_name,
        COUNT(*) AS full_name_count
    FROM temp_movies tm
    JOIN roles r ON tm.id = r.movie_id
    JOIN temp_actors ta ON r.actor_id = ta.id
    WHERE tm.year BETWEEN 1900 AND 1999
    GROUP BY tm.decade, ta.full_name
),
ranked_actors AS (
    SELECT
        decade,
        full_name,
        full_name_count,
        ROW_NUMBER() OVER (PARTITION BY decade ORDER BY full_name_count DESC) AS rn
    FROM decade_count
)
SELECT
    decade,
    full_name,
    full_name_count
FROM ranked_actors
WHERE rn = 1
ORDER BY decade;

-- the below is from official solution
with cte as (
SELECT RANK() OVER (PARTITION BY DECADE ORDER BY TOTALS DESC) AS ranking, 
	fname, 
	totals, 
	decade
from (SELECT a.first_name as fname, 
	COUNT(a.first_name) as totals, 
	FLOOR(m.year / 10) * 10 as decade
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
GROUP BY decade, fname) sub)
SELECT decade, 
	fname, 
	totals
FROM cte
WHERE ranking = 1
-- AND decade >= 1900
-- AND decade < 1900
ORDER BY decade;




