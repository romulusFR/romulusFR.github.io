-- variation de valeur entre un relevé et celui qui le précède immédiatement
-- avec la window function lag()


-- EXPLAIN
SELECT
    sensor.*,
    row_number() OVER win AS rank,
    value - lag(value) OVER win AS delta
FROM sensor
WINDOW win AS (ORDER BY time_stamp ASC)
ORDER BY time_stamp;

