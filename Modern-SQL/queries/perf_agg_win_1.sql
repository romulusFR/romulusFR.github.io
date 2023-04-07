---------------------
-- Q V1
---------------------
-- EXPLAIN ANALYZE
WITH q AS (
    SELECT
        depname,
        avg(salary) AS moy
    FROM
        emp
    GROUP BY
        depname
)
    SELECT
        emp.*,
        (salary - moy) AS delta
    FROM
        emp
        JOIN q USING (depname)
    ORDER BY
        depname;

