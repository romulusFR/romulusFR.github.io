# pylint: disable=logging-fstring-interpolation
"""comparaison de performance de requêtes SQL

Installez les modules suivants avec pip :

python3 -m pip install -r requirements.txt

Ensuite, créer un fichier .env dans le même dossier que bench.py avec le contenu suivant

USER=cafe
PASSWORD=cafe
HOST=localhost
PORT=5432
DATABASE=cafe
SCHEMA=cafe

Exécuter par exemple

python3 bench.py --verbose ../queries/perf_agg_win_1.sql ../queries/perf_agg_win_2.sql

"""
import argparse
import asyncio
import logging
import statistics as stat
import urllib.parse
from collections import defaultdict
from itertools import product
from pathlib import Path
from pprint import pformat
from time import perf_counter, time
from typing import DefaultDict

import psycopg
from dotenv import dotenv_values
from psycopg_pool import AsyncConnectionPool, ConnectionPool
from tqdm import tqdm
from tqdm.asyncio import tqdm as atqdm

logger = logging.getLogger("PERF")


# charge les variables d'environnement, par défaut dans le fichier `.env`
config = dotenv_values(".env")
options = urllib.parse.quote_plus("--search_path={config['SCHEMA']},public")

# https://dba.stackexchange.com/questions/171855/how-to-set-a-search-path-default-on-a-psql-cmd-execution
CONN_PARAMS = f"postgresql://{config['USER']}:{config['PASSWORD']}@{config['HOST']}:{config['PORT']}/{config['DATABASE']}?options={options}"  # pylint: disable=line-too-long


def get_parser():
    """Configuration de argparse pour les options de ligne de commandes"""
    parser = argparse.ArgumentParser(
        prog=f"python {Path(__file__).name}",
        description="Comparaison des performances entre deux requêtes SQL. Préfixe utomatiquement avec une commande EXPLAIN.",  # pylint: disable=line-too-long
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    parser.add_argument(
        "--verbose",
        "-v",
        action="count",
        default=0,
        help="niveau de verbosité, -v pour INFO, -vv pour DEBUG. WARNING par défaut",
    )

    parser.add_argument(
        "--async",
        "-a",
        action=argparse.BooleanOptionalAction,
        default=False,
        help="active le mode asynchrone de psycog. False par défaut",
        dest="with_async",
    )

    parser.add_argument(
        "filenames",
        metavar="FILENAME",
        nargs="+",
        action="store",
        help="fichier(s) à lire",
    )

    parser.add_argument(
        "--repeat",
        "-r",
        action="store",
        default=20,
        type=int,
        help="nombre de répétitions",
    )
    return parser


def do_sync(queries: dict[str, str], repeat):
    """version SYNC"""
    res: DefaultDict[str, list[float]] = defaultdict(list)
    pool = ConnectionPool(CONN_PARAMS)
    # with psycopg.connect(CONN_PARAMS) as conn:  # pylint: disable=not-context-manager
    with pool.connection() as conn:
        with conn.cursor() as cur:
            for filename, query in queries.items():
                for i in tqdm(range(repeat)):
                    logger.debug("SYNChronous query #%i", i)
                    cur.execute(EXPLAIN + query)
                    res_time = cur.fetchone()[0][0]["Execution Time"]  # type: ignore
                    res[filename].append(res_time)
                logger.info("...%s done", filename)
    return res


async def do_async(queries: dict[str, str], repeat):
    """version ASYNC, parallélisation = nb requêtes"""
    res: DefaultDict[str, list[float]] = defaultdict(list)
    pool = AsyncConnectionPool(CONN_PARAMS, min_size=0, max_size=min(repeat, 20))

    async def async_job(filename, query):
        async with pool.connection() as aconn: # HERE
            async with aconn.cursor() as cur:
                for i in range(repeat):
                    logger.debug("ASYNChronous query #%i for '%s'", i, filename)
                    await cur.execute(EXPLAIN + query)
                    data = await cur.fetchone()
                return filename, data[0][0]["Execution Time"]

    res_times = await atqdm.gather(*[async_job(f, q) for (f, q) in queries.items()], total=len(queries))
    for f, t in res_times:
        res[f].append(t)

    logger.debug(pformat(res))
    return res


async def do_async_product(queries: dict[str, str], repeat):
    """version ASYNC, parallélisation = nb requêtes * répétitions"""
    res: DefaultDict[str, list[float]] = defaultdict(list)
    pool = AsyncConnectionPool(CONN_PARAMS, min_size=0, max_size=min(repeat, 20))

    async def async_job(filename, query, id_job=-1):
        async with pool.connection() as aconn:
            async with aconn.cursor() as cur:
                logger.debug("ASYNChronous query #%i for '%s'", id_job, filename)
                await cur.execute(EXPLAIN + query)
                data = await cur.fetchone()
                return filename, data[0][0]["Execution Time"]

    # async with await psycopg.AsyncConnection.connect(CONN_PARAMS) as aconn:

    # avec ces boucles, c'est un lancement async sur la même connection : pas de // effective de PG
    # il faut passer dans la task

    # async with pool.connection() as aconn:
    #     for filename in filenames:
    #         async with aconn.cursor() as cur:
    #             res_times = await atqdm.gather(*[async_job(cur, i) for i in range(repeat)])

    # tqdm overload of asyncio.gather
    res_times = await atqdm.gather(
        *[async_job(f, q, i) for (f, q), i in product(queries.items(), range(repeat))], total=len(queries) * repeat
    )
    for f, t in res_times:
        res[f].append(t)
    return res


EXPLAIN = "EXPLAIN (ANALYZE, TIMING, FORMAT JSON) "


def read_sql_files(filenames):
    """Reads files and returns (SQL) contents"""

    for filename in filenames:
        with open(filename, "r", encoding="utf-8") as file:
            logger.info("loading %s...", filename)
            yield filename, file.read()


if __name__ == "__main__":
    args = get_parser().parse_args()

    if args.verbose == 1:
        DEBUG_LEVEL = logging.INFO
    elif args.verbose >= 2:
        DEBUG_LEVEL = logging.DEBUG
    else:
        DEBUG_LEVEL = logging.WARNING

    logging.basicConfig(level=DEBUG_LEVEL)
    logger.debug(vars(args))
    logger.debug(CONN_PARAMS)
    logger.debug(f"psycopg: {psycopg.__version__}, libpq: {psycopg.pq.version()}")

    if args.repeat < 2:
        raise ValueError(f"must specify at least 2 repetitions, only {args.repeat} given")

    logger.info("Launching %i times each query (async=%s)", args.repeat, args.with_async)

    sql_contents = dict(read_sql_files(args.filenames))
    if DEBUG_LEVEL >= logging.DEBUG:
        for k, v in sql_contents.items():
            logger.debug("file %s\n%s", k, v)

    start_time = time()
    if args.with_async:
        results = asyncio.run(do_async(sql_contents, args.repeat))
    else:
        results = do_sync(sql_contents, args.repeat)
    end_time = time()

    logger.info("Total running time %.2f", end_time - start_time)
    max_length = max(len(filename) for filename in args.filenames)
    for key, vals in results.items():
        print(
            f"{key:<{max_length}} mean = {stat.mean(vals):.2f} ms, stdev = {stat.stdev(vals):.2f} ms, median = {stat.median(vals):.2f} ms"  # pylint: disable=line-too-long
        )
