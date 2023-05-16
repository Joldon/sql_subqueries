--  Joan's solution model representation
WITH tt1 AS (
    SELECT *, concat(v1, '', v2) AS alias1 -- selects variables and stores them in an alias (as value)
    FROM t1
),
tt2 AS (
    SELECT *, floor(v3/10) * 10 AS alias2 -- selects variables and stores them in an alias (as value)
    FROM t2
),
-- stores a query result in a temporary table combining variables and aliases from the first two temporary tables
tt3 AS (
    SELECT tt2.alias2, tt1.alias1, COUNT(tt1.alias1) AS alias3
    FROM tt2
    JOIN tt3 ON tt1.id = t3.actor_id
    JOIN tt2 ON t3.movie_id = tt2.id
    GROUP BY tt2.alias2, tt1.alias1 
), 
-- stores a query result in a temporary table selecting aliases from the previous temporary tables
-- and adding a row number to each row and then storing it in another alias (as value)
tt4 AS (
    SELECT alias2, alias1, alias3, ROW_NUMBER() OVER (PARTITION BY alias2 ORDER BY alias3 DESC) AS alias4
    FROM tt3
)
-- selects all variables from the last temporary table 
SELECT *
FROM tt4
WHERE alias4 = 1 -- and filters the result by a value stored in the last alias
ORDER BY alias2;


-- SUBQUERIES
SELECT v1, v2
FROM t1
WHERE v3 IN (
    SELECT v3
    FROM t2
    WHERE v4 = 'value'
);

-- comparison operators in subqueries
SELECT v1, v2, v3
FROM t1
WHERE v3 > (
    SELECT MAX(v3)
    FROM t1
);

-- subqueries in FROM clause
SELECT MAX(alias1), MIN(alias1), FLOOR(AVG(alias1))
FROM (
    SELECT v1, COUNT(v1) AS alias1
    FROM t1
    GROUP BY v1 AS alias2
);

-- subqueries in NOT IN
SELECT v1
FROM t1
WHERE v2 NOT IN (
    SELECT DISTINCT v2
    FROM t2
    WHERE v2 = 'value'
);

-- correlated subqueries
SELECT v1, v2
FROM t1 AS t1_outer
WHERE v3 > (
    SELECT MAX(v3)
    FROM t1 AS t1_inner
    WHERE t1_inner.v1 = t1_outer.v1
);