WITH ordered_sensor AS(
  SELECT
    sensor.*,
    dense_rank() OVER (ORDER BY time_stamp ASC) AS rank
  FROM sensor
  ORDER BY time_stamp ASC
)

SELECT
  s1.*,
  s1.value - s2.value as delta
FROM ordered_sensor AS s1 JOIN ordered_sensor AS s2 ON s1.rank = s2.rank + 1
;