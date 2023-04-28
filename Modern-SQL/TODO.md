# TODO

## Ajout contenus

- clause `RETURNING`
- clause `ON CONFLICT`
- clause `MERGE`
- clause `EXTRACT`
- clause `GENERATED AS IDENTIY` <https://www.postgresql.org/docs/current/sql-createtable.html>
- clause `FETCH { FIRST | NEXT } [ count ] { ROW | ROWS } { ONLY | WITH TIES }` <https://www.postgresql.org/docs/current/sql-select.html#SQL-LIMIT>
- clauses `LIKE, SIMILAR TO, LIKE_REGEX` et al. <https://www.postgresql.org/docs/current/functions-matching.html>

## Recherche dans les chaînes de caractères

Les alternatives au classique `LIKE` permettent d'utiliser des expressions régulières dans une syntaxe du standard SQL avec `SIMILAR TO` ou dans la syntaxe POSIX avec `LIKE_REGEX` non supportée (mais fonction OK).
