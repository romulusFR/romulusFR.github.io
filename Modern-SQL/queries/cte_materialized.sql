WITH small_dep AS MATERIALIZED (
  SELECT depname
  FROM dep LEFT OUTER JOIN emp USING (depname)
  GROUP BY depname
  HAVING count(empno) BETWEEN 1 AND 2
  ORDER BY depname
)

SELECT emp.*
FROM emp JOIN small_dep USING (depname);