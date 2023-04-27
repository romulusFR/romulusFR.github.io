-- base sensor -------

-- pour la reproductibilité
SELECT setseed(0);

-- clean
DROP TABLE IF EXISTS sensor;

-- schema
CREATE TABLE sensor(
    sensorid int NOT NULL,
    time_stamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    value DECIMAL NOT NULL
);


-- dataset
-- un relevé chaque seconde environ avec un bruit linéaire de +/- 100ms
-- value est sur Z/nZ 
-- BUG : round() ne rend pas equiprobable les sensors (à cause de 0 et 10), mais floor est ok
INSERT INTO sensor (
    SELECT  floor(random()*10),
            CURRENT_TIMESTAMP +  i * INTERVAL  '1 second' + random()/10 * INTERVAL '1 second',
            mod(i, 60)
    FROM generate_series(0, 100000) AS g(i)
);


VACUUM ANALYZE sensor;
