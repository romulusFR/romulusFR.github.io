-- ? Requête : _donner le rang de chaque employé (les ex-aequos ne créant pas de trous) par ordre de salaire décroissant au sein de son équipe avec l'écart à la moyenne entre son salaire et celle de son équipe_

SELECT  emp.*,
        dense_rank() OVER (PARTITION BY depname ORDER BY salary DESC) AS rank,
        salary - avg(salary) OVER (PARTITION BY depname) AS delta
FROM emp
ORDER BY depname, rank, empno;

-- ? Requête : _donner, sans différencier les capteurs, la somme cumulée de la valeur_.

SELECT time_stamp,
       value,
       sum(value) OVER (ORDER BY time_stamp ASC RANGE UNBOUNDED PRECEDING) AS cum_sum
FROM sensor
ORDER BY time_stamp;

-- ? Requête : _donner, sans différencier les capteurs, la moyenne glissante de la valeur sur 1 minute_

SELECT
    time_stamp,
    time_stamp - (interval '1 MINUTE'),
    value,
    count(*) OVER w,
    round(avg(value) OVER w, 2) AS moy
FROM
    sensor
WINDOW w AS (ORDER BY time_stamp ASC RANGE BETWEEN '1 MINUTE' PRECEDING AND CURRENT ROW)
ORDER BY
    time_stamp;




-- ? Les opérateurs de regroupement `GROUPING SETS`
-- ? la version simplifiée avec le CUBE

SELECT sensorid AS sensorid, date_trunc('minute', time_stamp)::time AS time_stamp, count(value) AS nb
FROM sensor
GROUP BY CUBE(sensorid, date_trunc('minute', time_stamp))
ORDER BY sensorid NULLS FIRST, time_stamp NULLS FIRST;


-- ? équivalent du cross join avec lag
-- ? faire la même chose avec `lag` et comparer les plans d'exécution


SELECT sensor.*,
       row_number() OVER win AS rank,
       value - lag(value) OVER win AS delta
FROM sensor
WINDOW win AS (ORDER BY time_stamp ASC)
ORDER BY time_stamp;

--  WindowAgg  (cost=66.83..89.33 rows=1000 width=56)
--    ->  Sort  (cost=66.83..69.33 rows=1000 width=16)
--          Sort Key: time_stamp
--          ->  Seq Scan on sensor  (cost=0.00..17.00 rows=1000 width=16)

--- ? CTE ET WITH

WITH RECURSIVE dep_hierarchy(depname, parent, depth) AS (
    SELECT depname, parent, 1
    FROM dep
    WHERE parent IS NOT NULL
  UNION
    SELECT dep.depname, dep_hierarchy.parent, dep_hierarchy.depth + 1
    FROM dep JOIN dep_hierarchy ON dep.parent = dep_hierarchy.depname
)
SELECT * FROM dep_hierarchy
ORDER BY depname, parent;

--Requête : _donner pour chaque service, le nombre total d'employé qui en dépendent en comptant les sous-service transitifs_.

-- préparation

WITH emp_nb AS (
    SELECT dep.depname, count(empno) AS nb
    FROM dep LEFT JOIN emp ON dep.depname = emp.depname
    GROUP BY dep.depname
    ORDER BY dep.depname
)
SELECT * FROM emp_nb;

--final

WITH RECURSIVE dep_hierarchy(depname, parent, depth) AS (
    SELECT DISTINCT depname, depname, 0
    FROM dep
   UNION
    SELECT depname, parent, 1
    FROM dep
    WHERE parent IS NOT NULL
  UNION
    SELECT dep.depname, dep_hierarchy.parent, dep_hierarchy.depth + 1
    FROM dep JOIN dep_hierarchy ON dep.parent = dep_hierarchy.depname
),

emp_nb AS (
    SELECT dep.depname, count(empno) AS nb
    FROM dep LEFT JOIN emp ON dep.depname = emp.depname
    GROUP BY dep.depname
    ORDER BY dep.depname
)

SELECT h.parent as depname, sum(nb)
FROM dep_hierarchy AS h JOIN emp_nb  ON emp_nb.depname = h.depname
GROUP BY h.parent
ORDER BY h.parent;


-- Requête : _donner pour chaque service, le salaire min et le salaire max de tous les subordonnés_.


WITH RECURSIVE dep_hierarchy(depname, parent) AS (
    SELECT DISTINCT depname, depname
    FROM dep
   UNION
    SELECT DISTINCT parent, parent
    FROM dep
   UNION
    SELECT depname, parent
    FROM dep
    WHERE parent IS NOT NULL
  UNION
    SELECT dep.depname, dep_hierarchy.parent
    FROM dep JOIN dep_hierarchy ON dep.parent = dep_hierarchy.depname
)
SELECT h.parent, min(emp.salary), max(emp.salary)
FROM dep_hierarchy AS h JOIN emp ON h.depname = emp.depname
GROUP BY h.parent
ORDER BY parent;


