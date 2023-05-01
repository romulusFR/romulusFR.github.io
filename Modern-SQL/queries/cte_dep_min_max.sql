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
