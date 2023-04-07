-- pour la reproductibilité
SELECT setseed(0);

-- base sensor -------
----------------------
DROP TABLE IF EXISTS sensor;
CREATE TABLE sensor(
    sensorid INT NOT NULL,
    time_stamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    value DECIMAL NOT NULL
);


-- un relevé chaque seconde environ avec un bruit linéaire de +/- 100ms
-- correction bug ROUND ne rend pas equiprobable, mais FLOOR ok
INSERT INTO sensor (
    SELECT  FLOOR(random()*10),
            CURRENT_TIMESTAMP +  i * INTERVAL  '1 second' + random()/10 * INTERVAL '1 second',
            MOD(i, 60)
    FROM generate_series(1, 100000) AS g(i)
);

-- base RH -------
------------------

DROP TABLE IF EXISTS dep CASCADE;
CREATE TABLE dep(
    depname TEXT PRIMARY KEY,
    parent TEXT NULL REFERENCES dep(depname)
);


DROP TABLE IF EXISTS emp;
CREATE TABLE emp(
    depname TEXT NOT NULL REFERENCES dep(depname),
    empno BIGINT PRIMARY KEY,
    salary INT NOT NULL
);


INSERT INTO dep VALUES
    ('direction', NULL),
    ('production', 'direction'),
    ('personnel', 'direction'),
    ('sales', 'direction'),
    ('develop', 'production'),
    ('maintenance', 'production'),
    ('team 1', 'develop'),
    ('team 2', 'develop');


INSERT INTO emp(depname, empno, salary) VALUES
    ('develop'   , 11, 5200),
    ('develop'   ,  7, 4200),
    ('develop'   ,  9, 4500),
    ('develop'   ,  8, 6000),
    ('develop'   , 10, 5200),
    ('personnel' ,  5, 3500),
    ('personnel' ,  2, 3900),
    ('sales'     ,  3, 4800),
    ('sales'     ,  1, 5000),
    ('sales'     ,  4, 4800),
    ('sales'     ,  12, 4200);
