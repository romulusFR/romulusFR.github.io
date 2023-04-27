-- génère aléatoirement des employés **et** des départements pour la base RH
-- les départements ne 
\set dep_size 1000
\set emp_size 100000

SELECT setseed(0);

TRUNCATE dep CASCADE;

INSERT INTO dep (
    SELECT
        'dep' || i::text
    FROM
        generate_series(0, :dep_size - 1) AS g(i)
);

INSERT INTO emp (
    SELECT
        'dep' || (floor(:dep_size * random())) AS depname,
        i,
        (6000 * random())::int
    FROM
        generate_series(1, :emp_size) AS g(i));

-- important pour l'optimiseur de requêtes
VACUUM ANALYZE dep, emp;

SELECT count(*) FROM dep;
SELECT count(*) FROM emp;