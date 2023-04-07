\set dep_size 1000
\set emp_size 100000
SELECT
    setseed(0);

TRUNCATE emp;

TRUNCATE dep CASCADE;

INSERT INTO dep (
    SELECT
        'dep' || i::text
    FROM
        generate_series(0, :dep_size) AS g (i));

INSERT INTO emp (
    SELECT
        'dep' || ((:dep_size * random())::int),
        i,
        (6000 * random())::int
    FROM
        generate_series(1, :emp_size) AS g (i));

-- important pour l'optimiseur de requêtes
VACUUM ANALYZE;

