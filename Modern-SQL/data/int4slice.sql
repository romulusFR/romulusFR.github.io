DROP FUNCTION IF EXISTS int4slice;

-- version textuelle
-- CREATE FUNCTION mk_slice(value integer, width integer default 1000) RETURNS text AS $$
--     SELECT '[' || (width * (value / width))::text || ',' || (width * (value / width) + width) || ')'::text 
-- $$
-- LANGUAGE SQL
-- IMMUTABLE
-- ;


-- version range
-- https://www.postgresql.org/docs/current/rangetypes.html
CREATE FUNCTION int4slice(value integer, width integer default 1000) RETURNS int4range AS $$
    SELECT int4range(
        width * (value / width),
        width * (value / width) + width,
        '[)'
    )
$$
LANGUAGE SQL
IMMUTABLE
;

