INSERT INTO demo VALUES (0, 'collision', DEFAULT);

INSERT INTO demo VALUES (0, 'collision', DEFAULT)
ON CONFLICT (id) DO NOTHING;

INSERT INTO demo VALUES (0, 'collision', DEFAULT)
ON CONFLICT ON CONSTRAINT demo_pkey DO NOTHING;

INSERT INTO demo VALUES (0, 'collision', DEFAULT)
ON CONFLICT ON CONSTRAINT demo_pkey DO UPDATE SET name=demo.name, timestamp=EXCLUDED.timestamp;
