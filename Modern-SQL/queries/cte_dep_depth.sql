WITH RECURSIVE dep_hierarchy(depname, parent, depth) AS (
    SELECT depname, parent, 1
    FROM dep
    WHERE parent IS NOT NULL
  UNION
    SELECT dep.depname, dep_hierarchy.parent, dep_hierarchy.depth + 1
    FROM dep JOIN dep_hierarchy ON dep.parent = dep_hierarchy.depname
)
SELECT *
FROM dep_hierarchy
ORDER BY depname, parent;