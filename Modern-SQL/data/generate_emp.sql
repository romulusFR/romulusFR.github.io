DELETE FROM emp;

-- INSERT INTO emp(depname, empno, salary) VALUES
-- KO car select exécuté une seule fois
-- SELECT (SELECT depname FROM dep ORDER BY random() FETCH FIRST 1 ROW ONLY), round(random() * 1000 + 1000)
-- FROM generate_series(1, 100) AS g(i);
--
-- OK
WITH dataset AS (
    SELECT
        depname,
        i AS empno,
        round(random() * 2000 + 3000) AS salary
    FROM
        generate_series(1, 100000) AS g (i)
        CROSS JOIN LATERAL (
            SELECT
                depname
            FROM
                dep
            WHERE
                i = i
            ORDER BY
                random()
                FETCH FIRST 1 ROW ONLY) AS t)
    INSERT INTO emp
    SELECT
        *
    FROM
        dataset;

