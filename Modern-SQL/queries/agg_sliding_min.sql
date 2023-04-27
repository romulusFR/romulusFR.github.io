-- donner, sans différencier les capteurs, la moyenne glissante de la valeur sur 1 minute

WITH q AS(
    SELECT
        time_stamp,
        time_stamp - (INTERVAL '1 MINUTE') AS previous_min,
        time_stamp - (first_value(time_stamp) OVER (ORDER BY time_stamp ASC)) AS delta_time,
        value,
        rank() over w AS rank,
        count(*) OVER w AS sliding_size,
        round(avg(value) OVER w, 2) AS sliding_avg
    FROM sensor
    WINDOW w AS (ORDER BY time_stamp ASC RANGE BETWEEN (INTERVAL '1 MINUTE') PRECEDING AND CURRENT ROW)
    ORDER BY time_stamp
)
SELECT avg(sliding_avg)
FROM q
WHERE rank > 60;