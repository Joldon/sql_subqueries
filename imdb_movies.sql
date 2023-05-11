USE imdb_ijs;

select * from actors;




select * from movies_genres;
select * from roles;

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

/* Understanding the database




Are there movies with more than one “genre”?
*/



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

select * from movies_directors;
select * from directors;
select * from movies;
select * from directors_genres;
-- On average, how many actors are listed by movie?







 
