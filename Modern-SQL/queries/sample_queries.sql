---------------------
-- Q3
---------------------

SELECT
    emp.*,
    first_value(salary) OVER w,
    last_value(salary) OVER w
FROM emp
WINDOW w AS (PARTITION BY depname ORDER BY salary DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
ORDER BY
    depname;

---------------------
-- Q4
---------------------

--
-- le nombre de relevés et la moyenne glissante sur la dernière minute
SELECT
    time_stamp,
    time_stamp - (interval '1 MINUTE'),
    value,
    count(*) OVER w,
    round(avg(value) OVER w, 2) AS moy
FROM
    sensor
WINDOW w AS (ORDER BY time_stamp ASC RANGE BETWEEN '1 MINUTE' PRECEDING AND CURRENT ROW)
ORDER BY
    time_stamp;

