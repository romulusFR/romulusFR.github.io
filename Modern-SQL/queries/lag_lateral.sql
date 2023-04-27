-- variation de valeur entre un relevé et celui qui le précède immédiatement
-- avec LATERAL JOIN

-- EXPLAIN
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
FROM ordered_sensor AS s1 CROSS JOIN LATERAL (
  SELECT s2.*
  FROM ordered_sensor AS s2
  WHERE s1.rank = s2.rank + 1
  ) AS s2
;