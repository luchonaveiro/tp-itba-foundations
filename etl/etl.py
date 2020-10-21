import psycopg2
import pandas as pd
import numpy as np
import logging
import requests
import os
import zipfile

logging.basicConfig(
    level=logging.INFO,
    handlers=[logging.StreamHandler()],
    format="%(asctime)s [%(levelname)s] %(message)s",
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


def download_url(url, save_path, chunk_size=128):
    logger.info("Downloading F1 Database...")
    r = requests.get(url, stream=True)
    with open(save_path, "wb") as fd:
        for chunk in r.iter_content(chunk_size=chunk_size):
            fd.write(chunk)

    logger.info("F1 Database downloaded")


if __name__ == "__main__":
    download_url("http://ergast.com/downloads/f1db_csv.zip", "db.zip")

    with zipfile.ZipFile("db.zip", "r") as zip_ref:
        zip_ref.extractall("db")

    conn, cur = get_conn()

    for file in os.listdir("db"):

        tablename = file.replace(".csv", "")
        data = pd.read_csv("db/{}".format(file), na_values="\\N")
        data = data.replace({np.nan: None})

        logger.info(
            "Uploading {} records to the table {}...".format(len(data), tablename)
        )
        args_str = b",".join(
            cur.mogrify("(" + "%s," * (len(data.columns) - 1) + "%s)", x)
            for x in tuple(map(tuple, data.values))
        )
        cur.execute(
            "INSERT INTO f1.{} VALUES ".format(tablename) + args_str.decode("utf-8")
        )
        conn.commit()

        logger.info("{} uploaded to the Database".format(tablename))

    logger.info("Creating Foreign Keys constraints...")

    with open("foreign_keys_query.sql", "r") as f:
        constraints_query = f.read()

    cur.execute(constraints_query)
    conn.commit()

    logger.info("Foreign Keys constraints created")

    cur.close()
    conn.close()
