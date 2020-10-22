import psycopg2
import pandas as pd
import logging
import os

pd.set_option("display.max_columns", None)
pd.set_option("display.max_rows", None)

logging.basicConfig(
    level=logging.INFO,
    handlers=[logging.StreamHandler()],
    format="%(message)s"
)

logger = logging.getLogger(__name__)


def get_conn():
    logger.info("Creating Database Connection...")
    conn = psycopg2.connect(
        database=os.getenv("DATABASE"),
        user=os.getenv("DATABASE_USER"),
        password=os.getenv("DATABASE_PASSWORD"),
        host=os.getenv("DATABASE_HOST"),
        port=os.getenv("DATABASE_PORT"),
    )

    cur = conn.cursor()
    logger.info("Connection to Database stablished")

    return conn, cur


conn, cur = get_conn()

if __name__ == "__main__":

    if not os.path.exists("results"):
        os.makedirs("results")

    queries = os.listdir("queries/")
    queries.sort()

    for query in queries:
        with open("queries/{}".format(query), "r") as f:
            query_str = f.read()

        query_df = pd.read_sql_query(query_str, conn)
        logger.info("Resultados {}:".format(query.replace(".csv", "")))
        logger.info(query_df)
        query_df.to_csv("results/{}".format(query.replace(".sql", ".csv")))

    cur.close()
    conn.close()
