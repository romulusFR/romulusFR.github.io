-- chaque capteur / chaque heure
-- EXPLAIN
SELECT sensorid AS sensorid, date_trunc('hour', time_stamp) AS hour, count(value) AS nb
FROM sensor
GROUP BY sensorid, hour

UNION

-- tous les capteurs / chaque heure
SELECT NULL, date_trunc('hour', time_stamp) AS hour, count(value)
FROM sensor
GROUP BY hour

UNION

-- chaque capteur / tous les temps
SELECT sensorid AS sensorid, NULL AS hour, count(value)
FROM sensor
GROUP BY sensorid

UNION

-- tous les capteurs / tous les temps
SELECT NULL AS sensorid, NULL AS hour, count(value) AS nb
FROM sensor
ORDER BY sensorid NULLS FIRST, hour NULLS FIRST;