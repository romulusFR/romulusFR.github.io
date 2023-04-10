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

"""
import argparse
import logging
import statistics as stat
import urllib.parse
from collections import defaultdict
from pathlib import Path
from typing import DefaultDict

from tqdm import tqdm
import psycopg
from dotenv import dotenv_values

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
        description="Comparaison des performances entre deux requêtes SQL. Ajoute implicitement et automatiquement une commande EXPLAIN.",  # pylint: disable=line-too-long
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


EXPLAIN = "EXPLAIN (ANALYZE, TIMING, FORMAT JSON) "

if __name__ == "__main__":
    args = get_parser().parse_args()

    if args.verbose == 1:
        DEBUG_LEVEL = logging.INFO
    elif args.verbose >= 2:
        DEBUG_LEVEL = logging.DEBUG
    else:
        DEBUG_LEVEL = logging.WARNING

    logging.basicConfig(level=DEBUG_LEVEL)
    logger.debug(args)
    logger.debug(CONN_PARAMS)
    logger.debug(f"psycopg: {psycopg.__version__}, libpq: {psycopg.pq.version()}")

    if args.repeat < 2:
        raise ValueError(
            f"must specify at least 2 repetitions, only {args.repeat} given"
        )

    logger.info("Launching %i times each query", args.repeat)
    with psycopg.connect(CONN_PARAMS) as conn:  # pylint: disable=not-context-manager
        results: DefaultDict[str, list[float]] = defaultdict(list)

        # Open a cursor to perform database operations
        with conn.cursor() as cur:
            for filename in args.filenames:
                with open(filename, "r", encoding="utf-8") as file:
                    logger.info("reading %s...", filename)
                    sql_content = file.read()
                    logger.debug("content\n%s", sql_content)

                    for _ in tqdm(range(args.repeat)):
                        cur.execute(EXPLAIN + sql_content)
                        res = cur.fetchone()[0][0]["Execution Time"]  # type: ignore
                        results[filename].append(res)
                    logger.info("...%s done", filename)
    length = max(len(filename) for filename in args.filenames)
    for key, vals in results.items():
        print(
            f"{key}, mean = {stat.mean(vals):.2f} ms, stdev = {stat.stdev(vals):.2f} ms, median = {stat.median(vals):.2f} ms"
        )
        # print(f"quartiles {stat.quantiles(vals, n=4)}")


# format du retour de fetchone()
# [
#     {
#         "Plan": {
#             "Node Type": "WindowAgg",
#             "Parallel Aware": False,
#             "Async Capable": False,
#             "Startup Cost": 11143.12,
#             "Total Cost": 13393.12,
#             "Plan Rows": 100000,
#             "Plan Width": 50,
#             "Actual Startup Time": 280.394,
#             "Actual Total Time": 400.407,
#             "Actual Rows": 100000,
#             "Actual Loops": 1,
#             "Plans": [
#                 {
#                     "Node Type": "Sort",
#                     "Parent Relationship": "Outer",
#                     "Parallel Aware": False,
#                     "Async Capable": False,
#                     "Startup Cost": 11143.12,
#                     "Total Cost": 11393.12,
#                     "Plan Rows": 100000,
#                     "Plan Width": 18,
#                     "Actual Startup Time": 280.34,
#                     "Actual Total Time": 306.645,
#                     "Actual Rows": 100000,
#                     "Actual Loops": 1,
#                     "Sort Key": ["depname"],
#                     "Sort Method": "external merge",
#                     "Sort Space Used": 2936,
#                     "Sort Space Type": "Disk",
#                     "Plans": [
#                         {
#                             "Node Type": "Seq Scan",
#                             "Parent Relationship": "Outer",
#                             "Parallel Aware": False,
#                             "Async Capable": False,
#                             "Relation Name": "emp",
#                             "Alias": "emp",
#                             "Startup Cost": 0.0,
#                             "Total Cost": 1637.0,
#                             "Plan Rows": 100000,
#                             "Plan Width": 18,
#                             "Actual Startup Time": 0.008,
#                             "Actual Total Time": 11.869,
#                             "Actual Rows": 100000,
#                             "Actual Loops": 1,
#                         }
#                     ],
#                 }
#             ],
#         },
#         "Planning Time": 0.069,
#         "Triggers": [],
#         "Execution Time": 407.003,
#     }
# ]
