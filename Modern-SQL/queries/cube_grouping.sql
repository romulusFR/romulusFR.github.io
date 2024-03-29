-- avec CUBE on a toutes sommes marginales
-- EXPLAIN ANALYZE
SELECT
    sensorid AS sensorid,
    date_trunc('day', time_stamp)::date AS grp,
    count(value) AS nb
FROM sensor
GROUP BY CUBE(sensorid, grp)
ORDER BY sensorid NULLS FIRST, grp NULLS FIRST;
