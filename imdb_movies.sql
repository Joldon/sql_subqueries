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

select MIN(`rank`), MAX(`rank`)
from movies
where `rank` IS NOT NULL; -- 1, 9.9

SELECT name, COUNT(*) as count
FROM movies
GROUP BY name
ORDER BY count DESC; -- Eurovision Song Contest, The



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
-- but does sort them by number of directors
SELECT m.name AS movie_name, m.year, COUNT(DISTINCT d.id) AS director_count
FROM movies AS m
INNER JOIN movies_directors AS md ON m.id = md.movie_id
INNER JOIN directors AS d ON md.director_id = d.id
GROUP BY m.name, m.year
HAVING director_count > 1;

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
SELECT m.id, m.name
FROM movies AS m
JOIN movies_genres AS mg ON m.id = mg.movie_id
GROUP BY m.id, m.name
HAVING COUNT(DISTINCT mg.genre) > 1;

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
SELECT d.first_name, d.last_name
FROM directors AS d
JOIN movies_directors as md
ON d.id=md.director_id
JOIN movies as m
ON md.movie_id=m.id
WHERE m.name = 'Pulp Fiction';

select * from movies_directors;
select * from directors;
select * from movies;
select * from directors_genres;
select * from actors;
select * from movies_genres;
select * from roles;
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

SELECT *
FROM movies as m
JOIN movies_directors as md
ON m.id = md.movie_id
JOIN directors as d
ON md.director_id = d.id
WHERE m.name = 'Titanic' AND (LOWER(d.first_name)LIKE '%James%' AND LOWER(d.last_name) LIKE '%Cameron%')
;


