-- donner toutes les informations de chaque employé ainsi que
-- la différence entre son salaire et le salaire moyen de son équipe
-- version GROUP BY + JOIN

-- l'aggrégat sur emp
-- EXPLAIN
WITH sal AS MATERIALIZED (
    SELECT depname, AVG(salary) as avg
    FROM emp GROUP BY depname
)

-- la jointure entre emp et l'agrégat
SELECT emp.*, round(salary - sal.avg) AS delta
FROM emp JOIN sal
    ON emp.depname = sal.depname
ORDER BY depname, empno;
