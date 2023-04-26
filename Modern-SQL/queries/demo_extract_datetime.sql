DROP TABLE IF EXISTS demo;
-- option TEMPORARY pour une relation éphémère.
CREATE TEMPORARY TABLE demo(
  id int,
  name text,
  timestamp timestamp WITH time zone DEFAULT CURRENT_TIMESTAMP(0) -- /!\ toujours une time zone
);

INSERT INTO demo VALUES
  (0, 'tyty', DEFAULT),
  (1, 'toto', '2023-04-25'),
  (2, 'titi', '2023-04-25T16:03'),
  (3, 'tutu', '2023-04-25T16:03:45'),
  (4, 'tata', '2023-04-25T16:03:45.123'),
  (5, 'tata', '2023-04-25T16:03:45.123456'),
  (6, 'tete', '2023-04-25T16:03:45.123456+11');

-- extension PostgreSQL, raccourci pour
-- SELECT * FROM demo
TABLE demo;

