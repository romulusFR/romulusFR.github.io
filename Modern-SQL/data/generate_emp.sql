-- génère aléatoirement des employés pour la base RH
-- utilise la hiérarchie **des départements existants**

\set emp_size 100000

SELECT setseed(0);
TRUNCATE emp;

-- 
WITH dataset AS (
    SELECT
        one_dep.depname AS depname,
        -- g.i AS empno,
        round(random() * 2000 + 3000) AS salary
    FROM generate_series(1, :emp_size) AS g(i)
        -- ici un JOIN LATERAL
        CROSS JOIN LATERAL (
            SELECT depname
            FROM dep
            WHERE i = i
            ORDER BY random()
            FETCH FIRST 1 ROW ONLY
        ) AS one_dep
)

-- on utilise l'auto increment
INSERT INTO emp(depname, salary) (
    SELECT depname, salary
    FROM dataset
);

-- important pour l'optimiseur de requêtes
VACUUM ANALYZE emp;

SELECT count(*) FROM emp;

-- remarque
-- la variante ci-dessous est KO car le SELECT exécuté **une seule fois**
-- et tous les employés sont dans le même département
-- 
-- INSERT INTO emp(depname, salary)
-- SELECT 
--     (SELECT depname FROM dep ORDER BY random() FETCH FIRST 1 ROW ONLY) AS depname,
--     round(random() * 2000 + 3000) AS salary
-- FROM generate_series(1, 100) AS g(i);

