import psycopg2
import pandas as pd
import numpy as np
import logging
import requests
import os
import zipfile
import json

logging.basicConfig(level=logging.INFO,
                    handlers=[logging.StreamHandler()],
                    format="%(asctime)s [%(levelname)s] %(message)s")

logger = logging.getLogger(__name__)

with open('config.json','r') as j:
    config = json.load(j)

def get_conn():
    logger.info('Creating Database Connection...')
    conn = psycopg2.connect(database=config['DATABASE'],
                            user=config['DATABASE_USER'],
                            password=config['DATABASE_PASSWORD'],
                            host=config['DATABASE_HOST'],
                            port=config['DATABASE_PORT'])

    cur = conn.cursor()
    logger.info('Connection to Database stablished')
    
    return conn, cur

def download_url(url, save_path, chunk_size=128):
    logger.info('Downloading F1 Database...')
    r = requests.get(url, stream=True)
    with open(save_path, 'wb') as fd:
        for chunk in r.iter_content(chunk_size=chunk_size):
            fd.write(chunk)
            
    logger.info('F1 Database downloaded')

download_url('http://ergast.com/downloads/f1db_csv.zip', 'db.zip')

with zipfile.ZipFile('db.zip', 'r') as zip_ref:
    zip_ref.extractall('db')

conn, cur = get_conn()

# hardcdeo el nombre de los archivos porque sino me rompe cuando inserto los valores de una tabla que tiene un foreign key,
# y todavia no inserte los valores en esa tabla
# con este orden, se me respetan bien las inserciones y las dependencias de tablas 
files = ['circuits.csv', 'races.csv', 'constructors.csv', 'constructor_results.csv', 'constructor_standings.csv',
         'drivers.csv', 'driver_standings.csv', 'lap_times.csv', 'pit_stops.csv', 'qualifying.csv', 'results.csv',
         'seasons.csv', 'status.csv']

for file in files:
    
    tablename = file.replace('.csv','')
    data = pd.read_csv('db/{}'.format(file), na_values='\\N')
    data = data.replace({np.nan: None})

    logger.info('Uploading {} to the table {}...'.format(len(data), tablename))
    args_str = b','.join(cur.mogrify('('+'%s,'*(len(data.columns)-1) + '%s)', x) for x in tuple(map(tuple,data.values)))
    cur.execute("INSERT INTO f1.{} VALUES ".format(tablename) + args_str.decode("utf-8"))
    conn.commit()

    logger.info('{} uploaded to the Database...'.format(tablename))
    
cur.close()
conn.close()

