WITH vals(id, name, timestamp) AS(
    VALUES
    (42, 'tyty', CURRENT_TIMESTAMP),
    (43, 'tyty', CURRENT_TIMESTAMP)
    
    -- (42, 'tyty', CURRENT_TIMESTAMP)
    -- ERROR:  21000: MERGE command cannot affect row a second time
)


MERGE INTO demo USING vals ON demo.id = vals.id
    WHEN MATCHED THEN UPDATE SET
        timestamp = vals.timestamp,
        name = vals.name
    WHEN NOT MATCHED THEN
        INSERT VALUES (vals.*)
        -- ou explicitement
        -- INSERT (id, name, timestamp) VALUES (vals.id, vals.name, vals.timestamp)
;

-- <https://www.postgresql.org/docs/current/sql-merge.html#id-1.9.3.156.8>
-- There is no RETURNING clause with MERGE. Actions of INSERT, UPDATE and DELETE cannot contain RETURNING or WITH clauses.

TABLE demo;