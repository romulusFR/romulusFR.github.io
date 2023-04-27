-- donner toutes les informations de chaque employé ainsi que
-- la différence entre son salaire et le salaire moyen de son équipe
-- version WINDOWS

-- EXPLAIN ANALYZE
SELECT
    emp.*,
    round(salary - avg(salary) OVER w) AS delta
FROM emp
WINDOW w AS (PARTITION BY depname)
ORDER BY depname, empno;

