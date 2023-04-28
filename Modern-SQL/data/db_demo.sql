DROP TABLE IF EXISTS demo;

-- option TEMPORARY pour une relation éphémère.
CREATE TEMPORARY TABLE demo(
  id int PRIMARY KEY,
  name text,
   -- /!\ il est conseillé de toujours spécifier une time zone
  timestamp timestamp with time zone DEFAULT CURRENT_TIMESTAMP(0),
  -- /!\ (EXTRACT (epoch FROM timestamp)) sans timezone n'est 
  -- PAS immutable (et donc refusée) car l'évaluation dépend de la locale
  epoch_utc bigint GENERATED ALWAYS AS (EXTRACT (epoch FROM timestamp at time zone 'UTC')) STORED
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

