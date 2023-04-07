---------------------
-- Q V2
---------------------
-- EXPLAIN ANALYZE
SELECT
    emp.*,
    salary - avg(salary) OVER (PARTITION BY depname) AS delta
FROM
    emp
ORDER BY
    depname;

