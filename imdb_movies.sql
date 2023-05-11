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

Are there movies with multiple directors?
What is the movie with the most directors? Why do you think it has so many?
On average, how many actors are listed by movie?
Are there movies with more than one “genre”?
*/

select * from movies_directors;
select * from directors;
select * from movies;
select * from directors_genres;
SELECT 











 
