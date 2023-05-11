# pylint: disable=logging-fstring-interpolation
"""comparaison de performance de requêtes SQL

Installez les modules suivants avec pip :

python3 -m pip install -r requirements.txt

Ensuite, créer un fichier .env dans le même dossier que bench.py avec le contenu suivant

PGUSER=cafe
PGPASSWORD=cafe
PGHOST=localhost
PGPORT=5432
PGDATABASE=cafe
PGSCHEMA=cafe
PGAPPNAME=py-sql-bencher

Exécuter par exemple

python3 bench.py --verbose ../queries/perf_agg_win_1.sql ../queries/perf_agg_win_2.sql

"""

# %%

import argparse
import asyncio
import logging
import statistics as stat
from collections import defaultdict
from itertools import combinations
from pathlib import Path
from random import sample
from time import time
from typing import DefaultDict

import pandas as pd
import psycopg
import seaborn as sns
from dotenv import dotenv_values
from psycopg_pool import AsyncConnectionPool, ConnectionPool
from scipy.stats import kruskal, median_test, ttest_ind
from tqdm import tqdm
from tqdm.asyncio import tqdm as atqdm

# logger
logger = logging.getLogger("PERF")

# charge les variables d'environnement, par défaut dans le fichier `.env`
config = dotenv_values(".env")

# postgres connection string, les variables d'environnement ne sont pas prises directement
CONN_PARAMS = f"postgresql://{config['PGUSER']}:{config['PGPASSWORD']}@{config['PGHOST']}:{config['PGPORT']}/{config['PGDATABASE']}?application_name={config['PGAPPNAME']}"  # pylint: disable=line-too-long

# maximum number of parallel connection by psycopg
MAX_PARALLEL_CONN = 16

# to be added to each query
EXPLAIN = "EXPLAIN (ANALYZE, TIMING, FORMAT JSON) "

def get_parser():
    """Configuration de argparse pour les options de ligne de commandes"""
    parser = argparse.ArgumentParser(
        prog=f"python {Path(__file__).name}",
        description="Comparaison des performances entre deux requêtes SQL. Préfixe **automatiquement** avec une commande EXPLAIN.",  # pylint: disable=line-too-long
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    parser.add_argument(
        "--verbose",
        "-v",
        action="count",
        default=0,
        help="verbosité, -v pour 20 (INFO), -vv pour 10 (DEBUG), 30 (WARNING) par défaut.",
    )

    parser.add_argument(
        "--async",
        "-a",
        action=argparse.BooleanOptionalAction,
        default=False,
        help="active le mode asynchrone de psycopg, une connection par fichier.",
        dest="with_async",
    )

    parser.add_argument(
        "--full",
        action=argparse.BooleanOptionalAction,
        default=False,
        help="active le mode asynchrone entièrement en parallèle avec mélange de l'ordre des requêtes, à ajouter à --async, pas d'effet sinon.",
        dest="full_async",
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

    parser.add_argument(
        "--save-fig",
        "-f",
        action=argparse.BooleanOptionalAction,
        default=False,
        help="sauvegarde un boxplot PNG des mesures.",
    )

    parser.add_argument(
        "--save-csv",
        "-c",
        action=argparse.BooleanOptionalAction,
        default=False,
        help="sauvegarde un fichier CSV des mesures.",
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
                for _ in tqdm(range(repeat), postfix=filename):
                    # logger.debug("SYNChronous query #%i", i)
                    cur.execute(EXPLAIN + query)
                    res_time = cur.fetchone()[0][0]["Execution Time"]  # type: ignore
                    res[filename].append(res_time)
                logger.info("...%s done", filename)
    return res


# remarque
# avec les boucles suivantes, c'est un lancement async sur la même connection !
# pas de // effective de PG : il faut passer dans la task. Mais on reste async

# async with pool.connection() as aconn:
#     for filename in filenames:
#         async with aconn.cursor() as cur:
#             res_times = await atqdm.gather(*[async_job(cur, i) for i in range(repeat)])


async def do_async(queries: dict[str, str], repeat):
    """version ASYNC, parallélisation = nb requêtes"""
    res: DefaultDict[str, list[float]] = defaultdict(list)
    pool = AsyncConnectionPool(CONN_PARAMS, min_size=0, max_size=min(repeat, MAX_PARALLEL_CONN))

    async def async_job(filename, query):
        async with pool.connection() as aconn:  # HERE
            async with aconn.cursor() as cur:
                local_times = []
                for _ in atqdm(range(repeat), postfix=filename):
                    # logger.debug("ASYNChronous query #%i for '%s'", i, filename)
                    await cur.execute(EXPLAIN + query)
                    data = await cur.fetchone()
                    local_times.append(data[0][0]["Execution Time"])
                return filename, local_times

    res = await asyncio.gather(*[async_job(f, q) for (f, q) in queries.items()])
    return dict(res)


async def do_async_full(queries: dict[str, str], repeat):
    """version ASYNC, parallélisation = nb requêtes * répétitions"""
    res: DefaultDict[str, list[float]] = defaultdict(list)
    pool = AsyncConnectionPool(CONN_PARAMS, min_size=0, max_size=min(repeat, MAX_PARALLEL_CONN))

    async def async_job(filename, query):
        async with pool.connection() as aconn:
            async with aconn.cursor() as cur:
                # logger.debug("ASYNChronous query from '%s'", filename)
                await cur.execute(EXPLAIN + query)
                data = await cur.fetchone()
                return filename, data[0][0]["Execution Time"]

    # each query "q" from file "f" is repeated "repeat" times
    all_queries = [(f, q) for (f, q) in queries.items() for _ in range(repeat)]

    # tqdm overload of asyncio.gather
    res_times = await atqdm.gather(
        *[async_job(f, q) for (f, q) in sample(all_queries, k=len(all_queries))], total=len(all_queries)
    )
    for filename, times in res_times:
        res[filename].append(times)

    return res


def read_sql_files(filenames):
    """Reads files and returns (SQL) contents"""

    for filename in filenames:
        with open(filename, "r", encoding="utf-8") as file:
            logger.info("loading %s...", filename)
            yield filename, file.read()


def summary_stats(vals):
    """statistical summary"""
    _mean = stat.mean(vals)
    _stdev = stat.stdev(vals)
    _median = stat.median(vals)
    # _pvalue = chisquare(vals).pvalue

    # return f"mean = {_mean:.2f} ms, stdev = {_stdev:.2f} ms, median = {_median:.2f} ms, pvalue = {_pvalue:.2f}"
    return f"mean = {_mean:.2f} ms, stdev = {_stdev:.2f} ms, median = {_median:.2f} ms"


def pretty_pvalue(pvalue):
    """Pretty printing of significativity"""
    if pvalue <= 1e-4:
        return "****"
    if pvalue <= 1e-3:
        return "***"
    if pvalue <= 1e-2:
        return "**"
    if pvalue <= 5e-2:
        return "*"
    return "NS"


def do_measures(sql_contents: dict[str, str], repeat: int = 20, with_async: bool = False, full_async: bool = False):
    """Launch experiments. Wraps do_async_full/do_async/do_sync methods

    sql_contents is a dict with filenames as key and sql content as values
    """
    start_time = time()
    if with_async:
        if full_async:
            results = asyncio.run(do_async_full(sql_contents, repeat))
        else:
            results = asyncio.run(do_async(sql_contents, repeat))
    else:
        results = do_sync(sql_contents, repeat)
    end_time = time()

    duration = end_time - start_time
    nb_queries = len(sql_contents) * repeat
    logger.info("Total running time %.2f s for %i queries: %.2f ms by query (w/ parallelism)", duration, nb_queries, 1000*duration / nb_queries)

    return results


def print_stats(results: dict[str, list[float]]):
    """Computes and print statistics from runs.

    results is a dict with filenames as key and a list of measaures as values"""

    print("Statistics for each file")
    max_length = max(len(filename) for filename in results.keys())
    for key, vals in results.items():
        print(f"{key:<{max_length}} {summary_stats(vals)}")
    # for key, vals in results.items():
    #     logger.debug("%s: %s", key, vals)

    if len(results) > 1:
        print("Pairwise (Welch) T-tests")
    for (n_a, v_a), (n_b, v_b) in combinations(results.items(), 2):
        # means
        m_a, m_b = stat.mean(v_a), stat.mean(v_b)
        # reorder if needed so m_a < m_b
        if m_b < m_a:
            (n_a, v_a), (n_b, v_b) = (n_b, v_b), (n_a, v_a)
            m_a, m_b = m_b, m_a
        pval_less = ttest_ind(v_a, v_b, equal_var=False, alternative="less").pvalue
        pval_diff = ttest_ind(v_a, v_b, equal_var=False, alternative="two-sided").pvalue

        print(
            f"{n_a:<{max_length}} < {n_b:<{max_length}}: pvalue = {pval_less:.2%} ({pretty_pvalue(pval_less)}) (!= {pval_diff:.2%})"
        )

    if len(results) > 1:
        pval_mood = median_test(*results.values()).pvalue
        pval_kruskal = kruskal(*results.values()).pvalue
        print(
            f"Median tests: Mood = {pval_mood:.2%} ({pretty_pvalue(pval_mood)}), Kruskal = {pval_kruskal:.2%} ({pretty_pvalue(pval_kruskal)})"
        )


def main():
    """Entry point"""
    args = get_parser().parse_args()
    debug_level = logging.WARNING

    if args.verbose == 1:
        debug_level = logging.INFO
    if args.verbose >= 2:
        debug_level = logging.DEBUG

    logging.basicConfig(level=debug_level)
    logger.debug(vars(args))
    logger.debug(CONN_PARAMS)
    logger.debug(f"psycopg: {psycopg.__version__}, libpq: {psycopg.pq.version()}")

    if args.repeat < 2:
        raise ValueError(f"must specify at least 2 repetitions, only {args.repeat} given")

    logger.info("Launching %i times each query (async=%s)", args.repeat, args.with_async)

    sql_contents = dict(read_sql_files(args.filenames))
    if debug_level >= logging.DEBUG:
        for key, content in sql_contents.items():
            logger.debug("file %s\n%s", key, content)

    the_results = do_measures(sql_contents, args.repeat, args.with_async, args.full_async)
    print_stats(the_results)
    the_df = pd.DataFrame(the_results)
    the_filename = f"{'-'.join(Path(k).stem for k in the_df.columns)}"

    output_dir = Path("output/")
    if args.save_fig or args.save_csv:
        output_dir.mkdir(exist_ok=True)
    if args.save_fig:
        meanprops = {"marker": "o", "markerfacecolor": "white", "markeredgecolor": "black", "markersize": "10"}
        the_boxplot = sns.boxplot(the_df, showmeans=True, meanprops=meanprops)
        the_boxplot.figure.savefig(output_dir / f"{the_filename}.png", dpi=300)
    if args.save_csv:
        the_df.to_csv(output_dir / f"{the_filename}.csv")


if __name__ == "__main__":
    main()
