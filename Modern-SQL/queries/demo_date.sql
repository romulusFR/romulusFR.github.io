-- SET lc_time TO 'en_GB.utf8';

SELECT
  EXTRACT(CENTURY FROM timestamp) AS century,
  EXTRACT(DOY FROM timestamp) AS doy, -- day of the year
  EXTRACT(DOW FROM timestamp) AS dow, -- day of the week
  EXTRACT(WEEK FROM timestamp) AS week,
  EXTRACT(MINUTE FROM timestamp) AS minute,
  to_char(timestamp, 'TMDay DD TMMonth YYYY à HH:MM')
FROM
  demo;


SELECT
    timestamp - (INTERVAL '1 day') AS day_before,
    timestamp,
    timestamp + (INTERVAL '1 week') AS week_after
FROM
    demo;

-- nombre d'heures entre le 25 avril et maintenant
SELECT CAST(EXTRACT(epoch FROM now() - '2023-04-25')/3600 AS int) AS hours;