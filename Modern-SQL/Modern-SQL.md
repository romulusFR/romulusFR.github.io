# Café développeur·se LIRIS : SQL moderne

Support de présentation pour le [café développeur·se LIRIS : SQL moderne](https://projet.liris.cnrs.fr/edp/cafes-developpeur-liris/2023-05-11-sql-moderne.html).

- [Café développeur·se LIRIS : SQL moderne](#café-développeurse-liris--sql-moderne)
  - [Introduction](#introduction)
    - [Jeux de données](#jeux-de-données)
    - [Références](#références)
  - [Dates, heures et intervalles](#dates-heures-et-intervalles)
  - [Gestion des modifications](#gestion-des-modifications)
    - [Auto-increment avec `AS IDENTITY`](#auto-increment-avec-as-identity)
    - [`RETURNING`](#returning)
    - [`UPDATE` or `INSERT`](#update-or-insert)
  - [Fonctions de fenêtrage (_windows function_)](#fonctions-de-fenêtrage-windows-function)
    - [Solution traditionnelle](#solution-traditionnelle)
    - [Solution _windows_](#solution-windows)
    - [Performance des fonctions de fenêtrage](#performance-des-fonctions-de-fenêtrage)
    - [Clauses `ORDER BY` et `RANGE/ROWS/GROUP` des fenêtres](#clauses-order-by-et-rangerowsgroup-des-fenêtres)
  - [Requêtes analytiques](#requêtes-analytiques)
    - [Clause `FILTER`](#clause-filter)
    - [Les opérateurs de regroupement `GROUPING SETS`](#les-opérateurs-de-regroupement-grouping-sets)
  - [Vues, vues récursives et vues matérialisées](#vues-vues-récursives-et-vues-matérialisées)
    - [Les _Common Table Expression_ (CTE)](#les-common-table-expression-cte)
    - [Exercices](#exercices)

## Introduction

_A lot has changed since SQL-92_ comme le dit Markus WINAND sur <https://modern-sql.com/> mais dans les formations universitaires comme dans la pratique, de nombreux utilisateurs connaissent mal les constructions introduites depuis 1992.

Le but de ce café est de montrer des opérateurs SQL des [standards contemporains](https://en.wikipedia.org/wiki/SQL#Standardization_history) (SQL:1999, SQL:2003, SQL:2011).
Que ce soit pour leur pouvoir d'expression, pour leur facilité d'utilisation ou pour leurs performance, ces opérateurs facilitent grandement certaines activités.
Seront notamment abordés :

- la extractions de dates avec `EXTRACT` et de chaînes,
- le contrôle des écritures `RETURNING`, `ON CONFLICT` et `MERGE`,
- les opérateurs pour les requêtes analytiques `WINDOWS`, `GROUPING` et `FILTER`,
- les `Common Table Expression` avec `WITH` (et `WITH RECURSIVE`).

On s'appuiera sur PostgreSQL version 15 pour les exemples.
On restera _au plus proche du standard SQL_, en remarquant tant que possible ce qui est spécifique à PostgreSQL.

### Jeux de données

Pour la mise en place, créer un utilisateur et une base `cafe` :

```bash
# impersoner le compte privilégié PostgreSQL
sudo -i -u postgres
# créer l'utilisateur
createuser --createdb --pwprompt cafe
# créer la base
createdb --owner cafe cafe
exit
# vérifier le login/password
psql -U cafe -h localhost -p 5433
```

Les fichiers suivants, à exécuter avec l'utilisateur `cafe` dans la base `cafe`, permettent de créer les relations suivantes :

- [db_demo.sql](data/db_demo.sql) : des relations temporaires d'exemple,
- [db_emp_dep.sql](data/db_emp_dep.sql) : un jeu d'essai _RH_ avec une table `emp` pour les employés et une table `dep` pour la hiérarchie des services.
  - [generate_emp.sql](data/generate_emp.sql) : génère un grand nombre d'employés mais ne génère pas de services
  - [generate_emp_dep.sql](data/generate_emp_dep.sql) : génère un grand nombre d'employés **et** de services
- [](data/db_sensor.sql) : une table `sensor` contenant des données générées aléatoirement,

### Références

Documentation officielle PostgreSQL

- `RETURNING`
  - <https://www.postgresql.org/docs/current/dml-returning.html>
  - <https://www.postgresql.org/docs/current/sql-insert.html>
- `ON CONFLICT` pour les _UPSERTS_
  - <https://www.postgresql.org/docs/current/sql-insert.html#SQL-ON-CONFLICT>
- `MERGE` pour les _UPSERTS_
  - <https://www.postgresql.org/docs/current/sql-merge.html>
- `timestamp`, `EXTRACT` et `to_char`
  - <https://www.postgresql.org/docs/current/datatype-datetime.html>
  - <https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-EXTRACT>
  - <https://www.postgresql.org/docs/current/functions-formatting.html>
- _windows function_
  - <https://www.postgresql.org/docs/current/tutorial-window.html>
  - <https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-WINDOW-FUNCTIONS>
  - <https://www.postgresql.org/docs/current/functions-window.html>
- `GENERATED [...] AS IDENTITY` à la place du type `serial` pour les auto-increments
  - <https://www.postgresql.org/docs/current/sql-createtable.html>
- `GROUPING SETS`, `CUBE`, et `ROLLUP` pour les opération _cube_
  - <https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-GROUPING-SETS>
- `FILTER` clause pour calculer des _pivots_
  - <https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-AGGREGATES>
- `LATERAL JOIN` _subqueries_
  - <https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-LATERAL>
- `[MATERIALIZED] VIEW`
  - <https://www.postgresql.org/docs/current/tutorial-views.html>
  - <https://www.postgresql.org/docs/current/sql-createview.html>
  - <https://www.postgresql.org/docs/current/sql-creatematerializedview.html>
- `WITH [RECURSIVE]` clause, _Common Table Expression_
  - <https://www.postgresql.org/docs/current/queries-with.html>
- `FETCH { FIRST | NEXT } [ count ] { ROW | ROWS } { ONLY | WITH TIES }` l'équivalent standard de `LIMIT`
  - <https://www.postgresql.org/docs/current/sql-select.html#SQL-LIMIT>
- `LIKE, SIMILAR TO, LIKE_REGEX` et autres pour la recherche de sous-chaînes
  - <https://www.postgresql.org/docs/current/functions-matching.html>

En complément :

- un exposé _Postgres Window Magic_ de Bruce MOMJIAN <https://momjian.us/main/presentations/sql.html> (vidéo et slides)
- <https://modern-sql.com/> _A lot has changed since SQL-92_ par Markus WINAND.

## Dates, heures et intervalles

Les dates disposent d'opérateurs SQL standardisés.
On construit l'exemple ci-dessous ([source](data/db_demo.sql)) avec au passage l'option `TEMPORARY` et les dates à différentes précisions au format [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601).

```sql
DROP TABLE IF EXISTS demo;
-- option TEMPORARY pour une relation éphémère.
CREATE TEMPORARY TABLE demo(
  id int PRIMARY KEY,
  name text,
  timestamp timestamp WITH time zone DEFAULT CURRENT_TIMESTAMP(0) -- /!\ toujours une time zone
);

INSERT INTO demo VALUES
  (1, 'toto', '2023-04-25'),
  (2, 'titi', '2023-04-25T16:03'),
  (3, 'tutu', '2023-04-25T16:03:45'),
  (4, 'tata', '2023-04-25T16:03:45.123'),
  (5, 'tata', '2023-04-25T16:03:45.123456'),
  (6, 'tete', '2023-04-25T16:03:45.123456+11');

-- extension PostgreSQL, raccourci pour
-- SELECT * FROM demo
TABLE demo;
```

L'opérateur [`EXTRACT(field FROM source)`](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-EXTRACT) permet d'extraire jour, jour de l'année, etc. des `timestamp` et des `interval`.

La fonction [`to_char`](https://www.postgresql.org/docs/current/functions-formatting.html) permet la conversion en chaînes de caractères.

```sql
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
```

## Gestion des modifications

### Auto-increment avec `AS IDENTITY`

La définition suivante de la table `emp` de la base d'exemple définit une clef primaire avec la contrainte `GENERATED BY DEFAULT AS IDENTITY` qui est standard et qui remplace désormais le type (non standard) `serial` de PostgreSQL.

```sql
CREATE TABLE emp(
    depname text NOT NULL REFERENCES dep(depname),
    empno int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    salary int NOT NULL
);
```

Il est aujourd'hui **recommandé** d'utiliser `AS IDENTITY` et non plus `serial` qui pose un problème de gestion des droits sur la séquence associée à la colonne auto-increment.

- <https://stackoverflow.com/questions/55300370/postgresql-serial-vs-identity>
- <https://www.2ndquadrant.com/en/blog/postgresql-10-identity-columns/>
- <https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_serial>

### `RETURNING`

Extrait de la [documentation](https://www.postgresql.org/docs/current/sql-insert.html) de la clause `INSERT`.

> The optional `RETURNING` clause causes `INSERT` to compute and return value(s) based on each row actually inserted (or updated, if an ON CONFLICT DO UPDATE clause was used). This is primarily useful for obtaining values that were supplied by defaults, such as a serial sequence number. However, any expression using the table's columns is allowed.

La clause `RETURNING` est notamment utilisée sur les `WITH` avec des modifications ou pour des colonnes de type _auto-increment_ précédentes.
La clause existe dans d'autres SGBD mais n'est pas complètement standard.

Le script suivant semblable à [generate_emp.sql](data/generate_emp.sql) génère des employés dans le département `sales` et retourne les identifiants `empno` créés.

```sql
-- attention au comportement si on mixe auto-increment et valeurs manuelles
TRUNCATE emp;

WITH insert_query AS(
    INSERT INTO emp(depname, salary) (
        SELECT
            'sales' as depname,
            round(random() * 2000 + 3000) AS salary
        FROM
            generate_series(1, 10) AS g(i)
    )
    RETURNING depname, empno, salary
)

SELECT *
FROM insert_query JOIN dep USING (depname)
;
```

### `UPDATE` or `INSERT`

L'_upsert_, appelé aussi _`UPDATE` or `INSERT`_ est une opération qui consiste à tenter d'insérer et de faire à défaut une mise-à-jour si le tuple existe déjà en **une seule** commande. Il y a deux façons de le faire en PostgreSQL.

#### Clause `ON CONFLICT`

<https://www.postgresql.org/docs/current/sql-insert.html#SQL-ON-CONFLICT>

C'est la solution traditionnelle avant la version 15, elle est presque standard. Elle permet de de spécifier le comportement en cas d'exception levée par un conflit de contrainte de clef primaire ou de contrainte d'unicité.

```sql
INSERT INTO demo VALUES (0, 'collision', DEFAULT);
-- ERROR:  23505: duplicate key value violates unique constraint "demo_pkey"

INSERT INTO demo VALUES (0, 'collision', DEFAULT)
ON CONFLICT (id) DO NOTHING;
-- INSERT 0 0

INSERT INTO demo VALUES (0, 'collision', DEFAULT)
ON CONFLICT ON CONSTRAINT demo_pkey DO NOTHING;
-- INSERT 0 0

INSERT INTO demo VALUES (0, 'collision', DEFAULT)
ON CONFLICT ON CONSTRAINT demo_pkey DO UPDATE SET
  name=demo.name,
  timestamp=EXCLUDED.timestamp;
-- INSERT 0 1
```

#### Commande `MERGE`

C'est la clause standard d'_upsert_ supportée depuis la version 15.
Elle permet des traitements impossible avec `ON CONFLICT` mais n'intègre pas de clause `RETURNING`.

```sql
WITH vals(id, name, timestamp) AS(
    VALUES
    (42, 'tyty', CURRENT_TIMESTAMP),
    (43, 'tyty', CURRENT_TIMESTAMP)
)

MERGE INTO demo USING vals ON demo.id = vals.id
    WHEN MATCHED THEN UPDATE SET
        timestamp = vals.timestamp,
        name = vals.name
    WHEN NOT MATCHED THEN
        INSERT VALUES (vals.*)
;
```

## Fonctions de fenêtrage (_windows function_)

_Une fonction de fenêtrage effectue un calcul sur un jeu d'enregistrements liés d'une certaine façon à l'enregistrement courant. On peut les rapprocher des calculs réalisables par une fonction d'agrégat. Cependant, **les fonctions de fenêtrage n'entraînent pas le regroupement des enregistrements traités en un seul**, [...]. À la place, chaque enregistrement garde son identité propre._ [Doc PostgreSQL (fr)](https://docs.postgresql.fr/current/tutorial-window.html)

On a souvent besoin de combiner le résultat d'un agrégat avec des données _de la même table_.
Comme on va le voir sur l'exemple suivant, on a une tension entre :

- le regroupement dont on a besoin pour le calcul
- le résultat final qu'on ne veut **pas** regroupés, où on veut toutes les lignes.

On va prendre comme exemple la requête _donner toutes les informations de chaque employé ainsi que la différence entre son salaire et le salaire moyen de son équipe_.

### Solution traditionnelle

Sans fenêtrage, on fait une sous-requête d'agrégation **et** une jointure sur la même table, avec une requête imbriquée `FROM` ou une CTE `WITH` :

```sql
SELECT emp.*, round(salary - sal.avg) AS delta
FROM emp JOIN (
    SELECT depname, AVG(salary) as avg
    FROM emp GROUP BY depname) AS sal
    ON emp.depname = sal.depname
ORDER BY depname, empno;
```

```raw
  depname  | empno | salary | delta
-----------+-------+--------+-------
 develop   |     7 |   4200 |  -820
 develop   |     8 |   6000 |   980
 develop   |     9 |   4500 |  -520
 develop   |    10 |   5200 |   180
 develop   |    11 |   5200 |   180
 personnel |     2 |   3900 |   200
 personnel |     5 |   3500 |  -200
 sales     |     1 |   5000 |   300
 sales     |     3 |   4800 |   100
 sales     |     4 |   4800 |   100
 sales     |    12 |   4200 |  -500
(11 rows)
```

La même version avec `WITH` (on viendra sur cet opérateur), préférée personnellement car le rend la sous-requête plus lisible mais qui a **exactement le même plan d'exécution** (et donc le même résultat), voir [perf_agg_group_by.sql](queries/agg_group_by.sql) :

```sql
WITH sal AS(
    SELECT depname, AVG(salary) as avg
    FROM emp GROUP BY depname
)

-- la jointure entre emp et l'agrégat
SELECT emp.*, round(salary - sal.avg) AS delta
FROM emp JOIN sal
    ON emp.depname = sal.depname
ORDER BY depname, empno;
```

### Solution _windows_

Avec fenêtrage, on précise _la fenêtre_ (ou _partition_, mais le terme est polysémique), c'est-à-dire _le groupement intermédiaire sur lequel faire le calcul_, ici de moyenne. _Notez les parenthèses un peu surprenantes de la fonction `round`_, voir [perf_agg_windows.sql](queries/agg_windows.sql)

```sql
SELECT  emp.*,
        round(salary - avg(salary) OVER (PARTITION BY depname)) AS delta
FROM emp
ORDER BY depname, empno;
```

On peut grâce aux _windows function_ faire des opérations **difficiles à exprimer** sur le `GROUP BY`, par exemple le calcul _du rang_ (dense ou pas) du salarié dans son équipe.

Par exemple la requête _donner le rang dense de chaque employé (les ex aequos ne créant pas de trous) par ordre de salaire décroissant au sein de son équipe avec l'écart à la moyenne entre son salaire et celle de son équipe_ s'exprime comme suit, voir [agg_rank.sql](queries/agg_rank.sql).

```sql
SELECT  emp.*,
        dense_rank() OVER (PARTITION BY depname ORDER BY salary DESC) AS rank,
        round(salary - avg(salary) OVER (PARTITION BY depname)) AS delta
FROM emp
ORDER BY depname, rank, empno;
```

On vérifie que le salaire moyen est de par exemple 5020 pour les développeurs et que le résultat est cohérent.

```raw
  depname  | empno | salary | rank | delta
-----------+-------+--------+------+-------
 develop   |     8 |   6000 |    1 |   980
 develop   |    10 |   5200 |    2 |   180
 develop   |    11 |   5200 |    2 |   180
 develop   |     9 |   4500 |    3 |  -520
 develop   |     7 |   4200 |    4 |  -820
 personnel |     2 |   3900 |    1 |   200
 personnel |     5 |   3500 |    2 |  -200
 sales     |     1 |   5000 |    1 |   300
 sales     |     3 |   4800 |    2 |   100
 sales     |     4 |   4800 |    2 |   100
 sales     |    12 |   4200 |    3 |  -500
(11 rows)
```

### Performance des fonctions de fenêtrage

En plus de l'expression concise (mais quelque fois assez absconse) et de l'expressivité augmentée par rapport aux agrégats usuels SQL:19992, les fonctions de fenêtrage sont **performantes**.
On reprend le jeu d'essai avec un peu plus de volume en générant 1 000 services et 100 000 employés, consulter et exécuter le fichier [generate_emp_dep.sql](data/generate_emp_dep.sql).

On va comparer la solution traditionnelle SQL:1992 avec celle avec le fenêtrage grâce à la commande `EXPLAIN ANALYZE`.
Pour la solution traditionnelle avec `GROUP BY` et `JOIN`, on obtient le plan suivant où la jointure est très efficace (un seul tuple par `depname` dans la sous-requête `q`)

```raw
                                                                   QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=14737.38..14987.38 rows=100000 width=46) (actual time=339.916..361.076 rows=100000 loops=1)
   Sort Key: emp.depname, emp.empno
   Sort Method: external merge  Disk: 3040kB
   ->  Hash Join  (cost=2076.00..4630.61 rows=100000 width=46) (actual time=46.923..113.996 rows=100000 loops=1)
         Hash Cond: (emp.depname = sal.depname)
         ->  Seq Scan on emp  (cost=0.00..1541.00 rows=100000 width=14) (actual time=0.010..8.001 rows=100000 loops=1)
         ->  Hash  (cost=2063.50..2063.50 rows=1000 width=38) (actual time=46.903..46.905 rows=1000 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 59kB
               ->  Subquery Scan on sal  (cost=2041.00..2063.50 rows=1000 width=38) (actual time=45.799..46.630 rows=1000 loops=1)
                     ->  HashAggregate  (cost=2041.00..2053.50 rows=1000 width=38) (actual time=45.798..46.481 rows=1000 loops=1)
                           Group Key: emp_1.depname
                           Batches: 1  Memory Usage: 321kB
                           ->  Seq Scan on emp emp_1  (cost=0.00..1541.00 rows=100000 width=10) (actual time=0.002..10.228 rows=100000 loops=1)
 Planning Time: 0.214 ms
 Execution Time: 364.585 ms
```

Avec la fonction de fenêtrage, le plan est débarrassé de la jointure, le plan est le suivant.

```raw
                                                      QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------
 Incremental Sort  (cost=10856.19..20164.88 rows=100000 width=46) (actual time=243.264..366.854 rows=100000 loops=1)
   Sort Key: depname, empno
   Presorted Key: depname
   Full-sort Groups: 1000  Sort Method: quicksort  Average Memory: 29kB  Peak Memory: 29kB
   Pre-sorted Groups: 1000  Sort Method: quicksort  Average Memory: 32kB  Peak Memory: 32kB
   ->  WindowAgg  (cost=10848.27..13348.27 rows=100000 width=46) (actual time=243.109..314.612 rows=100000 loops=1)
         ->  Sort  (cost=10848.27..11098.27 rows=100000 width=14) (actual time=243.046..257.467 rows=100000 loops=1)
               Sort Key: depname
               Sort Method: external merge  Disk: 2568kB
               ->  Seq Scan on emp  (cost=0.00..1541.00 rows=100000 width=14) (actual time=0.009..11.787 rows=100000 loops=1)
 Planning Time: 0.106 ms
 Execution Time: 369.971 ms
```

Un programme Python de comparaison de performance de requêtes [bench.py](bencher/bench.py) est fourni.
Sur 100 exécutions, on obtient les statistiques suivantes, légèrement en faveur des fonctions de fenêtrage sur ce cas.

```raw
python3 bench.py --repeat 100 --verbose ../queries/agg_windows.sql ../queries/agg_group_by.sql

INFO:PERF:Total running time 59.73 for 200 queries
../queries/agg_windows.sql  mean = 284.05 ms, stdev = 28.91 ms, median = 272.32 ms
../queries/agg_group_by.sql mean = 310.81 ms, stdev = 15.80 ms, median = 307.89 ms
```

### Clauses `ORDER BY` et `RANGE/ROWS/GROUP` des fenêtres

La syntaxe complète des `WINDOWS` est très riche. On peut définir la partition et l'ordre de tri au sein de la partition, ici [la syntaxe générale](https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-WINDOW-FUNCTIONS), l'ordre est nécessaire pour certaines fonctions comme `rank()` ou `dense_rank()`

```raw
[ existing_window_name ]
[ PARTITION BY expression [, ...] ]
[ ORDER BY expression [ ASC | DESC | USING operator ] [ NULLS { FIRST | LAST } ] [, ...] ]
[ frame_clause ]
```

Au sein de la fenêtre, c'est-à-dire le sous-ensemble des tuples de la partition pris en compte pour le calcul, on peut utiliser des fonctions qui permettent de référencer les tuples précédents comme `lag()`.
Un exemple typique est celui des requêtes où l'on calcule un sous-total courant ou delta avec la ligne précédente.

Par exemple, la requête sur la table `sensor` qui calcule _pour chaque capteur, le temps en seconde entre deux relevés consécutifs_ utilise la fonction `lag()` et soustraction de dates.
Quand la définition de la fenêtre est longue ou employée sur plusieurs attributs, on peut la définir avec la clause `WINDOWS` et la réemployer comme suit.

```sql
SELECT sensor.*,
       time_stamp - (lag(time_stamp) OVER w) AS delta
FROM sensor
WINDOW w AS (PARTITION BY sensorid ORDER BY time_stamp ASC)
ORDER BY sensorid, time_stamp;
```

Comme avec [db_sensor.sql](data/db_sensor.sql) on a généré 100 000 relevés espacés d'environ 1 seconde en tirant au hasard à chaque fois parmi 10 capteurs, on peut vérifier que l'écart moyen de deux relevés du même capteur est de 10 secondes. Voir le fichier [agg_delta_time.sql](queries/agg_delta_time.sql) qui reprend la requête précédente.

On peut aussi avoir besoin de définir la fenêtre elle-même pour typiquement fixer un intervalle sur lequel on souhaite regrouper.
La fenêtre est par défaut **tous tuples du groupe** défini par `PARTITION BY` s'il n'y a pas de `ORDER BY` et **tous les précédents** quand la fenêtre est ordonnée.

C'est assez complet et parfois subtil.
Ci-dessous [la syntaxe](https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-WINDOW-FUNCTIONS) des `frame_clause`, `frame_start` et `frame_end`

```raw
# The optional frame_clause can be one of

{ RANGE | ROWS | GROUPS } frame_start [ frame_exclusion ]
{ RANGE | ROWS | GROUPS } BETWEEN frame_start AND frame_end [ frame_exclusion ]

# where frame_start and frame_end can be one of

UNBOUNDED PRECEDING
offset PRECEDING
CURRENT ROW
offset FOLLOWING
UNBOUNDED FOLLOWING

# and frame_exclusion can be one of

EXCLUDE CURRENT ROW
EXCLUDE GROUP
EXCLUDE TIES
EXCLUDE NO OTHERS

The default framing option is RANGE UNBOUNDED PRECEDING, which is the same as RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW. With ORDER BY, this sets the frame to be all rows from the partition start up through the current row's last ORDER BY peer. Without ORDER BY, this means all rows of the partition are included in the window frame, since all rows become peers of the current row.
```

#### Exemples de contrôle des fenêtres

On souhaite calculer _sans différencier les capteurs, la somme cumulée de la valeur_. C'est typiquement l'exemple d'une colonne _sous-total courant_ dans un ticket de caisse, voir [agg_cumul_sum.sql](queries/agg_cumul_sum.sql).

```sql
SELECT time_stamp,
       value,
       sum(value) OVER (ORDER BY time_stamp ASC RANGE UNBOUNDED PRECEDING) AS cum_sum
FROM sensor
ORDER BY time_stamp;
```

Ensuite, on souhaite calculer _sans différencier les capteurs, la moyenne glissante de la valeur sur 1 minute_. On va utiliser pour cela une clause `RANGE BETWEEN '1 MINUTE' PRECEDING` dans la fenêtre.

```sql
SELECT
    time_stamp,
    time_stamp - (INTERVAL '1 MINUTE') AS previous_min,
    time_stamp - (first_value(time_stamp) OVER (ORDER BY time_stamp ASC)) AS delta_time,
    value,
    rank() over w AS rank,
    count(*) OVER w AS sliding_size,
    round(avg(value) OVER w, 2) AS sliding_avg
FROM sensor
WINDOW w AS (ORDER BY time_stamp ASC RANGE BETWEEN (INTERVAL '1 MINUTE') PRECEDING AND CURRENT ROW)
ORDER BY time_stamp;
```

Il y a un relevé par seconde environ et à chaque fois la valeur est `mod(i, 60)` donc une fois 60 relevés effectués, la fenêtre glissante va comporter environ 60 relevés comportant tous les nombres entre 0 et 59, la moyenne glissante doit donc être de 29.50 environ. On le vérifie avec [agg_sliding_min.sql](queries/agg_sliding_min.sql).

#### Comparaison au `JOIN LATERAL`

Par défaut, on ne peut pas faire de sous-requêtes corrélées dans le `FROM`, l'opérateur `JOIN LATERAL` lève cette restriction qui permet de faire des _sous-requêtes latérale_.
Le principe est, pour chaque tuple de la table de gauche, **calculer la requête qui produit la table de droite en utilisant les valeur du tuple de gauche**.

Par exemple, le calcul _de la variation de valeur entre un relevé et celui qui le précède immédiatement_ (peu importe le capteur concerné) peut se faire avec `CROSS JOIN LATERAL` après avoir donné un rang aux tuples. Par construction, la valeur de `delta` vaut 59 fois `1` et 1 fois `-59`.

```sql
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
```

On obtient le plan suivant :

```raw
                                         QUERY PLAN
--------------------------------------------------------------------------------------------
 Merge Join  (cost=36910.20..1037930.21 rows=50001000 width=84)
   Merge Cond: (s1.rank = ((s2.rank + 1)))
   CTE ordered_sensor
     ->  WindowAgg  (cost=10944.37..12694.39 rows=100001 width=24)
           ->  Sort  (cost=10944.37..11194.37 rows=100001 width=16)
                 Sort Key: sensor.time_stamp
                 ->  Seq Scan on sensor  (cost=0.00..1637.01 rows=100001 width=16)
   ->  Sort  (cost=12307.78..12557.78 rows=100001 width=52)
         Sort Key: s1.rank
         ->  CTE Scan on ordered_sensor s1  (cost=0.00..2000.02 rows=100001 width=52)
   ->  Materialize  (cost=11908.03..12408.04 rows=100001 width=40)
         ->  Sort  (cost=11908.03..12158.03 rows=100001 width=40)
               Sort Key: ((s2.rank + 1))
               ->  CTE Scan on ordered_sensor s2  (cost=0.00..2000.02 rows=100001 width=40)
```

On va faire la même chose avec la _window function_ `lag`, comparer les plans d'exécution et évaluer la performance empirique avec [bench.py](bencher/bench.py). Notons qu'on a pas tout à fait le même résultat de requête : le premier tuples est perdu avec la solution `JOIN LATERAL`. La requête est comme suit :

```sql
SELECT
    sensor.*,
    row_number() OVER win AS rank,
    value - lag(value) OVER win AS delta
FROM sensor
WINDOW win AS (ORDER BY time_stamp ASC)
ORDER BY time_stamp;
```

Son plan est particulièrement efficace : il suffit simplement de trier `sensor` puis de faire un parcours où on calcule lla position et une soustraction.

```raw
                                QUERY PLAN
---------------------------------------------------------------------------
 WindowAgg  (cost=10944.37..13194.39 rows=100001 width=56)
   ->  Sort  (cost=10944.37..11194.37 rows=100001 width=16)
         Sort Key: time_stamp
         ->  Seq Scan on sensor  (cost=0.00..1637.01 rows=100001 width=16)
```

La différence empirique de performance est sans surprise **substantielle**.

```raw
python3 bench.py --repeat 100 --verbose ../queries/lag_lateral.sql ../queries/lag_window.sql

INFO:PERF:Total running time 55.74 for 200 queries
../queries/lag_lateral.sql mean = 443.26 ms, stdev = 85.21 ms, median = 405.89 ms
../queries/lag_window.sql  mean = 111.53 ms, stdev = 17.48 ms, median = 104.29 ms
```

## Requêtes analytiques

On va maintenant prendre des exemples de requêtes statistiques utilisant typiquement une opération `PIVOT` qui n'existe **pas** en SQL. L'exemple employé est celui des [tableaux de contingences](https://en.wikipedia.org/wiki/Contingency_table) qui donne pour deux variables catégorielles les effectifs concernés.

### Clause `FILTER`

La clause `FILTER` permet de mettre une condition (dans le `SELECT`) sur les tuples considérés par un agrégat.
Cela permet de faire des _pivots_, typiques OLAP, appelés aussi _tableaux croisés_, qui consistent à créer un tableau 2D avec _une colonne_ pour chaque valeur d'un attribut.
Comme pour le fenêtrage simple, on évite la solution traditionnelle SQL:1992 avec autant de jointures que de colonnes.

**Requête** : _pour chaque service, compter le nombre d'employés avec un salaire dans l'intervalle [1, 1000[, ceux dans [1000, 2000[ etc._

On peut commencer par la requête préliminaire suivante.

```sql
SELECT depname, (1000*(salary / 1000))::text || '-' || (1000*(salary / 1000)+1000)::text  AS tranche, count(empno) AS nb
FROM emp
GROUP BY depname, salary / 1000;
```

```raw
  depname  |  tranche  | nb
-----------+-----------+----
 sales     | 5000-6000 |  1
 sales     | 4000-5000 |  3
 personnel | 3000-4000 |  2
 develop   | 5000-6000 |  2
 develop   | 4000-5000 |  2
 develop   | 6000-7000 |  1
(6 rows)
```

Elle a toutefois au moins deux problèmes :

- on a pas d'effectif de 0 quand il n'y a aucun employé du service dans la catégorie,
- on souhaiterait avoir autant de colonnes qu'il y a de tranches salariales, sous forme de _tableau de contingence_ (très utilisé en statistique).

Il faut _pivoter_ ce résultat de requête, comme dans l'illustration ci-dessous, reprise de [modern SQL](https://modern-sql.com/use-case/pivot).

![Illustration du pivot qui transforme les valeurs d'une colonne en autant de colonnes](img/pivot.png)

```sql
SELECT  depname,
        count(empno) FILTER (WHERE salary BETWEEN 3000 and 3999) AS "[3000, 4000[",
        count(empno) FILTER (WHERE salary BETWEEN 4000 and 4999) AS "[4000, 5000[",
        count(empno) FILTER (WHERE salary BETWEEN 5000 and 5999) AS "[5000, 6000[",
        count(empno) FILTER (WHERE salary BETWEEN 6000 and 6999) AS "[6000, 7000[",
        count(empno) FILTER (WHERE salary >= 7000) AS "[7000, Inf["
FROM emp
GROUP BY depname;
```

```raw
  depname  | [3000, 4000[ | [4000, 5000[ | [5000, 6000[ | [6000, 7000[ | [7000, Inf[
-----------+--------------+--------------+--------------+--------------+-------------
 personnel |            2 |            0 |            0 |            0 |           0
 sales     |            0 |            3 |            1 |            0 |           0
 develop   |            0 |            2 |            2 |            1 |           0
(3 rows)
```

On peut aussi utiliser une extension comme [`tablefunc`](https://www.postgresql.org/docs/current/tablefunc.html) qui fait quelque chose de similaire.
L'extension s'installe par la commande `CREATE EXTENSION tablefunc;`.

```sql
  SELECT *
    FROM crosstab(
        'SELECT depname, salary / 1000 AS tranche, count(empno) AS nb FROM emp GROUP BY depname, salary / 1000',
        'SELECT DISTINCT salary/1000 from emp ORDER by 1'
    ) AS (depname text, "[3000, 4000[" int, "[4000, 5000[" int, "[5000, 6000[" int, "[6000, 7000[" int);
```

Notez les `NULL` au lieu des valeurs `0` de la version avec les `FILTER`.

```bash
  depname  | [3000, 4000[ | [4000, 5000[ | [5000, 6000[ | [6000, 7000[
-----------+--------------+--------------+--------------+--------------
 sales     |            Ø |            3 |            1 |            Ø
 personnel |            2 |            Ø |            Ø |            Ø
 develop   |            Ø |            2 |            2 |            1
(3 rows)
```

Une des limites de l'approche ici est que la liste des colonnes est _statique_.
Les SGBD (R)OLAP ont des opérateurs spécifiques pour éviter ceci, mais ici on a une limite du modèle relationnel où les colonnes doivent être connues _avant_ l'exécution de la requête.
On peut, pour éviter ceci :

- faire le pivot dans l'application hôte, par exemple avec [DataFrame.pivot_table()](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.pivot_table.html#pandas.DataFrame.pivot_table) si on est en Python;
- générer la requête programmatiquement, côté serveur ou côté client, avec par exemple un _template_;
- utiliser une commande spéciale de `psql` comme `\crosstabview` qui pivote le dernier résultat de requête, mais ceci ne fonctionnera **que** pour `psql`.

```sql
SELECT  depname, salary / 1000 AS tranche, count(empno) AS nb
FROM emp
GROUP BY depname, salary / 1000;

\crosstabview
```

```raw
  depname  | 5 | 4 | 3 | 6
-----------+---+---+---+---
 sales     | 1 | 3 |   |
 personnel |   |   | 2 |
 develop   | 2 | 2 |   | 1
(3 rows)
```

### Les opérateurs de regroupement `GROUPING SETS`

Ces opérateurs permettent de spécifier plusieurs dimensions sur lesquelles agréger les données selon **toutes ou parties des dimensions**.
Là aussi, une opération typique (R)OLAP.
Par exemple, pour les capteurs, on voudrait avoir le nombre de relevés :

- pour chaque capteur et pour tous les capteurs;
- pour chaque minute et pour toutes les dates.

Si on a $c$ capteur et $d$ dates, on obtient un tableau de de taille $(c+1) \times (d+1)$ avec les _sommes marginales_.

La solution classique consiste à faire l'`UNION` des **quatre agrégats calculés séparément** :

```sql
SELECT sensorid AS sensorid, date_trunc('minute', time_stamp) AS time_stamp, count(value) AS nb
FROM sensor
GROUP BY sensorid, date_trunc('minute', time_stamp)

UNION

SELECT NULL, date_trunc('minute', time_stamp), count(value)
FROM sensor
GROUP BY date_trunc('minute', time_stamp)

UNION

SELECT sensorid AS sensorid, NULL AS time_stamp, count(value)
FROM sensor
GROUP BY sensorid

UNION

SELECT NULL AS sensorid, NULL AS time_stamp, count(value) AS nb
FROM sensor
ORDER BY sensorid NULLS FIRST, time_stamp NULLS FIRST;
```

**TODO** le faire en utilisant les `GROUPING SET`, ici l'opérateur `CUBE` en particulier

**TODO** utiliser enfin `\crosstabview` pour avoir une représentation en 2D comme suit

```raw
 sensorid |  Ø   | 14:26:00 | 14:27:00 | 14:28:00 | 14:29:00 | 14:30:00 | 14:31:00 | 14:32:00 | 14:33:00 | 14:34:00 | 14:35:00 | 14:36:00 | 14:37:00 | 14:38:00 | 14:39:00 | 14:40:00 | 14:41:00 | 14:42:00
----------+------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------
        Ø | 1000 |       58 |       60 |       60 |       60 |       60 |       60 |       60 |       60 |       60 |       60 |       60 |       60 |       60 |       60 |       60 |       60 |       42
        0 |   58 |        6 |        2 |        5 |        4 |        4 |        3 |        4 |        1 |        6 |        4 |        2 |        4 |        2 |        3 |        2 |        2 |        4
        1 |  115 |        7 |        6 |        9 |       13 |        7 |        8 |        6 |        6 |        8 |        4 |        8 |        7 |        3 |        9 |        7 |        3 |        4
        2 |   87 |        4 |       10 |        5 |        6 |       10 |        4 |        4 |        6 |        1 |        5 |        5 |        8 |        4 |        5 |        5 |        1 |        4
        3 |   91 |        6 |        6 |        5 |          |        6 |        6 |        8 |        4 |        4 |        5 |        7 |        7 |        8 |        4 |        5 |        4 |        6
        4 |   90 |        2 |        9 |        6 |        1 |        7 |        8 |        6 |        2 |        3 |        6 |        7 |        9 |        2 |        7 |        4 |        6 |        5
        5 |   99 |        9 |        3 |        4 |       10 |        4 |        4 |        4 |        6 |        8 |       10 |        7 |        4 |        8 |        5 |        5 |        6 |        2
        6 |   98 |        5 |        8 |        2 |        5 |        3 |        6 |        5 |        6 |        6 |        5 |        6 |        7 |        6 |        5 |        9 |        8 |        6
        7 |  101 |        4 |        3 |        6 |        5 |       10 |        5 |        6 |        9 |        6 |        8 |        7 |        3 |        7 |        6 |        6 |        5 |        5
        8 |  101 |        4 |        5 |        5 |        6 |        5 |        7 |        5 |        6 |        7 |        2 |        3 |        5 |        6 |        8 |        8 |       16 |        3
        9 |  117 |        8 |        6 |       10 |        8 |        3 |        7 |       11 |        7 |        7 |        9 |        6 |        5 |        8 |        5 |        8 |        6 |        3
       10 |   43 |        3 |        2 |        3 |        2 |        1 |        2 |        1 |        7 |        4 |        2 |        2 |        1 |        6 |        3 |        1 |        3 |
(12 rows)
```

## Vues, vues récursives et vues matérialisées

Les vue ne sont pas particulièrement _modernes_ mais _très utilisées_ :

- une vue est _une requête à laquelle on a donné un nom_ et qui s'utilise _comme une table_, en refaisant le calcul (s'il n'est ni dans le cache ni matérialisé).
- on peut **matérialiser la vue**, auquel cas la vue devient _vraiment_ une table avec des tuples **persistants** :
  - dans ce cas là il faut _rafraîchir_ la vue quand les données sources change et mettre à jour la table de stockage.

Les cas d'usages des vues sont :

- fournir une **interface** au client, s'abstraire des tables concrètes,
- **contrôler les accès** en limitant les colonnes ou lignes accessibles,
- **factoriser** les requêtes fréquentes,
- assurer la **performance** des requêtes analytiques via la matérialisation.

Par exemple une vue sur les services :

```sql

DROP VIEW IF EXISTS dep_summary;
CREATE VIEW dep_summary AS(
  SELECT depname, count(empno) AS nb_emp
  FROM dep LEFT OUTER JOIN emp USING (depname)
  GROUP BY depname
  ORDER BY dep
);

TABLE dep_summary;
INSERT INTO dep VALUES ('test', NULL);
TABLE dep_summary;

-- la vue est à jour : la requête a été recalculée
```

### Les _Common Table Expression_ (CTE)

- le `WITH` _non récursif_ est utilisable comme une vue _à portée locale_
  - très pratique pour _organiser les grosses requêtes_
- avec le mot-clef `[RECURSIVE]` on peut construire des vues qui font référence **à elle-même dans leur définition**
  - étend **considérablement** l'expressivité de SQL
    - permet de faire des parcours d'arbres/graphes
  - peut conduire à des requêtes _qui ne terminent jamais_ !

#### CTE non récursives

Dans l'exemple suivant, `small_dep` est une _vue_ locale, dont la définition sera utilisée soit :

- `NOT MATERIALIZED`, c'est-à-dire _dépliée_ lors de l'évaluation de la requête, son contenu est injecté dans la requête englobante et l'optimisation est faite globalement;
- `MATERIALIZED`, les évaluations sont séquentielles : la sous-requête, puis la requête englobante utilise le résultat qui a été enregistré.

```sql
WITH small_dep AS NOT MATERIALIZED (
  SELECT depname
  FROM dep LEFT OUTER JOIN emp USING (depname)
  GROUP BY depname
  HAVING count(empno) BETWEEN 1 AND 2
  ORDER BY depname
)

SELECT emp.*
FROM emp JOIN small_dep USING (depname);
```

**TODO** comparer les plans d'exécution des deux requêtes, avec/sans le mot-clef `NOT`.

**TODO** vérifier la différence de performance, qui n'est pas très importante sur ce cas. Quand peut-elle changer ?

#### CTE récursives

On peut définir des vues qui **font référence à elles-mêmes** et permet de calculer des résultats _impossible_ en SQL sans récursion, comme _la fermeture transitive_ d'une relation.

Par exemple, ici le calcul de _fermeture transitive_ des services : pour chaque service, calculer **tous les sous-services qui en dépendent directement ou pas**.
Autrement dit, dans l'arbre `dep` des services seuls les relations _enfant - parent_ sont stockées, ici on veut _tous les descendants_, qu'elle que soit la profondeur.
De base, la relation `dep` est comme suit :

```raw
   depname   |   parent
-------------+------------
 direction   | Ø
 production  | direction
 personnel   | direction
 sales       | direction
 develop     | production
 maintenance | production
 team 1      | develop
 team 2      | develop
(8 rows)
```

On construit la vue récursive, avec deux cas :

- **le cas de base**, si `e` est un _enfant_ de `p`, alors `e` est un _descendant_ de `p` : c'est le contenu de la table `dep`, les enfants immédiats;
- **le cas récursif**, si `e` est un _enfant_ de `p` et que `p` est un **descendant** de `gp`, alors `e` est un _descendant_ de `gp`.

```sql
WITH RECURSIVE dep_rec(depname, parent) AS (
  -- chemin de longueur 1
    SELECT depname, parent
    FROM dep
  UNION
  -- extension des chemins avec une nouvelle étape
    SELECT dep.depname, dep_rec.parent
    FROM dep JOIN dep_rec ON dep.parent = dep_rec.depname
)


SELECT * FROM dep_rec
ORDER BY depname, parent;
```

Si on utilise souvent la table `dep_rec`, on aura très envie d'en faire une vue (récursive), possiblement matérialisée.

```sql
DROP VIEW IF EXISTS dep_trans;

-- syntaxe abrégée pour les vues récursives, qui évite un sélect
-- https://www.postgresql.org/docs/current/sql-createview.html
CREATE RECURSIVE VIEW dep_trans(depname, parent) AS (
    SELECT depname, parent
    FROM dep
  UNION
    SELECT dep.depname, dep_trans.parent
    FROM dep JOIN dep_trans ON dep.parent = dep_trans.depname
);
```

```sql
DROP MATERIALIZED VIEW IF EXISTS dep_trans_m;

-- pas de syntaxe abrégée ici
CREATE MATERIALIZED VIEW dep_trans_m AS(
  WITH RECURSIVE dep_trans(depname, parent) AS (
      SELECT depname, parent
      FROM dep
    UNION
      SELECT dep.depname, dep_trans.parent
      FROM dep JOIN dep_trans ON dep.parent = dep_trans.depname
  )
  SELECT * FROM dep_trans
);
```

### Exercices

Écrire les requêtes suivantes :

- pour chaque service, calculer les sous-services qui en dépendent transitivement en comptant aussi **la profondeur** depuis `direction`.
- donner pour chaque service, le salaire min et le salaire max de tous les subordonnés (transitivement).
  - _Indice_ pour le service `direction` on doit avoir le min et le max de l'ensemble de la société.
- donner pour chaque service, le nombre total d'employés qui en dépendent transitivement.
  - _Indice_ calculer d'abord la table suivante puis utiliser la requête récursive.
  - Vérifier le comportement en ajoutant un tuple.
  - Penser à la réflexivité de la relation `dep_hierarchy`

```sql
INSERT INTO emp VALUES
    ('team 1'   , 13, 5200);
```

On doit avoir pour le nombre d'employés directs

```raw
   depname   | nb
-------------+----
 develop     |  5
 maintenance |  0
 personnel   |  2
 production  |  0
 sales       |  4
 team 1      |  1
 team 2      |  0
```

Et avec la transitivité

```raw
   depname   | sum
-------------+-----
 develop     |   6
 direction   |  12
 maintenance |   0
 personnel   |   2
 production  |   6
 sales       |   4
 team 1      |   1
 team 2      |   0
```
