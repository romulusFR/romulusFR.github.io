-- variante avec GROUPING SETS ou le power set est explicité
-- EXPLAIN ANALYZE
SELECT
    sensorid AS sensorid,
    date_trunc('day', time_stamp)::date AS grp,
    count(value) AS nb
FROM sensor
GROUP BY GROUPING SETS (
    ( ),
    (sensorid),
    (grp),
    (sensorid, grp)
)
ORDER BY sensorid NULLS FIRST, grp NULLS FIRST;
