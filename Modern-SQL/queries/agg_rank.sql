-- donner le rang de chaque employé (les ex-aequos ne créant pas de trous)
-- par ordre de salaire décroissant au sein de son équipe avec l'écart
-- à la moyenne entre son salaire et celle de son équipe.

SELECT  emp.*,
        dense_rank() OVER (PARTITION BY depname ORDER BY salary DESC) AS rank,
        round(salary - avg(salary) OVER (PARTITION BY depname)) AS delta
FROM emp
ORDER BY depname, rank, empno;
