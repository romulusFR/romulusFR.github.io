-- EXPLAIN
SELECT
    sensorid AS sensorid,
    date_trunc('hour', time_stamp) AS hour,
    count(value) AS nb
FROM sensor
GROUP BY CUBE(sensorid, hour)
ORDER BY sensorid NULLS FIRST, hour NULLS FIRST;