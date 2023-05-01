
-- préparation : requête de base sans récursion

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

SELECT
    h.parent AS depname,
    sum(nb) AS nb
FROM dep_hierarchy AS h JOIN emp_nb ON emp_nb.depname = h.depname
GROUP BY h.parent
ORDER BY h.parent;