WITH q AS (
    SELECT sensor.*,
        time_stamp - (lag(time_stamp) OVER w) AS delta
    FROM sensor
    WINDOW w AS (PARTITION BY sensorid ORDER BY time_stamp ASC)
    ORDER BY sensorid, time_stamp
)
SELECT avg(delta)
FROM q
GROUP BY sensorid;