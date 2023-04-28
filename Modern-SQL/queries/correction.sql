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




---------------------
-- Q3
---------------------

SELECT
    emp.*,
    first_value(salary) OVER w,
    last_value(salary) OVER w
FROM emp
WINDOW w AS (PARTITION BY depname ORDER BY salary DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
ORDER BY
    depname;

---------------------
-- Q4
---------------------

--
-- le nombre de relevés et la moyenne glissante sur la dernière minute
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


