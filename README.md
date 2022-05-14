# **TP Final Foundations & Cloud Architect**

[![Generic badge](https://img.shields.io/badge/PostgreSQL-13-blue.svg)](https://www.postgresql.org/)
[![Generic badge](https://img.shields.io/badge/Python-3.6-blue.svg)](https://www.python.org/)
[![Generic badge](https://img.shields.io/badge/Docker-20.10.6-blue.svg)](https://www.docker.com/)
 
La base de datos elegida para este trabajo, es una correspondiente a la información sobre las carreras de Fórmula 1 (F1).
Los datos los consigo de este [sitio](http://ergast.com/mrd/db/), y contiene datos de todas las carreras de la F1 desde el 5 de Mayo de 1950, hasta la última que ocurrió el 11 de octubre de 2020. Estos datos se actualizan unos minutos terminada cada carrera y tiene información de todo tipo, entre los que se destacan:
 
- resultados de las carreras, con las posiciones de todos los pilotos que la corrieron.
- datos de las clasificaciones (las carreras del día previo que definen las posiciones de largada).
- datos de los equipos.
- datos de los pilotos.
- datos de las paradas en los boxes.
- datos de los circuitos.
- datos de cada vuelta, de cada circuito para cada piloto que la corrió.
 
 
Elegí esta base de datos, por mi interés en la F1, y porque seguramente encuentre cosas super interesantes cuando me ponga a consultar esta información.
 
Este trabajo consta de 3 partes, que mediante Docker, Python y SQL, se debe:
- levantar una base de datos (elegí usar PostgreSQL) y crear la estructura de las tablas.
- popular esa base de datos con los datos de la F1.
- realizar consultas sobre esa base de datos.
 
## **Estructura del Proyecto**
El proyecto está separado en distintos directorios, uno para cada parte del proceso:
- `/db` tiene los scripts y Dockerfile necesarios para la creación de la base de datos.
- `/etl` tiene los scripts, archivos y Dockerfile necesarios para ejecutar el proceso de ETL.
- `/reports` tiene los scripts, queries, archivos y Dockerfile necesarios para construir los reportes consultando la base de datos.
- `/assets` tiene las imágenes que están incluidas en este README.
 
Ósea, generando un árbol del directorio, obtenemos lo siguiente:
 
```
📦tp-itba-foundations
  - Archivos .PNG utiles para el README.md
┣ 📂assets
┃ ┗ ...
  - Archivos referentes a la base de datos
┣ 📂db
┃ ┣ 📜Dockerfile
┃ ┣ 📜docker-compose.yml
┃ ┣ 📜create_database.sh
┃ ┗ 📜init.sql
  - Archivos referentes a la ejecución del ETL
┣ 📂etl
┃ ┣ 📜Dockerfile
┃ ┣ 📜config.json
┃ ┣ 📜etl.py
┃ ┗ 📜requirements.txt
  - Archivos referentes a la generación de reportes
┣ 📂reports
┃ ┣ 📂queries
┃ ┃ ┣ 📜query_1.sql
┃ ┃ ┣ 📜query_2.sql
┃ ┃ ┣ 📜query_3.sql
┃ ┃ ┣ 📜query_4.sql
┃ ┃ ┣ 📜query_5.sql
┃ ┃ ┣ 📜query_6.sql
┃ ┃ ┗ 📜query_7.sql
┃ ┣ 📜Dockerfile
┃ ┣ 📜config.json
┃ ┣ 📜reports.py
┃ ┗ 📜requirements.txt
┣ 📜README.md
┗ 📜Trabajo Practico - CDE - Foundations.pdf
```
 
## **Tecnologías y Versiones**
Es importante remarcar que este trabajo se realizó con las siguientes tecnologías y versiones:
- Docker (version: 19.03.13, API version: 1.40)
- Docker Compose (version: 1.27.4)
 
## **Docker Network**
Primero vamos a crear la red en la que van a correr todos los containers. De esta manera podemos comunicar los containers entre si. Ejecutamos el siguiente comando que crea la red _tp-itba_:
 
```
$ docker network create tp-itba
```
 
## **Base de Datos**
 
Como comenté, elegí usar PostgreSQL como base de datos para guardar toda la información de la F1.
 
La vamos a levantar mediante docker compose. Esto va a levantar la base de datos (va a buildear y correr una imagen de postgres), va a esperar a que la base esté operativa, y después va a correr el container generado por la imagen que está en el directorio `/db`, que contiene un script de bash que ejecuta un script de sql que crea todas las tablas necesarias. A su vez, indicamos en el docker-compose.yml, que se conecte a la red previamente creada, así podemos comunicarnos con el resto de los containers.
 
Tanto la definición de los campos de las tablas como las foreign keys, las obtengo de [acá](http://ergast.com/schemas/f1db_schema.txt).
 
Para lograr todo esto, ejecutamos los siguientes comandos,suponiendo que estamos en la ruta principal del proyecto:
```
$ cd db
$ docker-compose up
```
 
Vamos a ver que primero va a pullear la imagen de `postgres:13.0`, luego buildea la imagen de `create-db`, luego crea `pg-docker` (osea, corre la imagen de postgres) y al final crea `create-db`. Si todo sale bien, vamos a ver que se crearon las tablas correctamente:
 
![create database logs](./assets/db/logs_create_database.png)
 
Ok, ya tenemos levantada la base de datos, con las tablas y relaciones creadas. A su vez, podemos graficar el diagrama ER de la base para entender cuáles son estas relaciones:
 
![diagrama ER](./assets/db/ER_Diagram.png)
 
## **ETL**
 
Una vez que ya tenemos la base de datos corriendo, iniciamos el proceso de ETL de los datos. Este proceso consiste en descargar los datos crudos desde internet, hacerle una pequeña modificación e insertarlos en cada tabla correspondiente.
 
Para esto, abrimos otra terminal y nos dirigimos al directorio `/etl` de este proyecto, y buildeamos la imagen de Docker que contiene el script de Python con el proceso de ETL.
 
```
$ cd etl
$ docker build -t etl .
```
 
donde:
- `-t` es el tag con el que creamos la imagen, como nos vamos a referir a ella cuando queramos correrla.
 
Una vez buildeada, ya podemos ejecutarla.
 
 
```
$ docker run --rm -e DATABASE_HOST=pg-docker \
-e DATABASE_PORT=5432 \
-e DATABASE=postgres \
-e DATABASE_USER=postgres \
-e DATABASE_PASSWORD=docker \
--network=tp-itba etl
```
 
donde:
- `--rm` es una buena práctica automáticamente remover el container.
- `-e` le pasamos algunas variables de entorno, en este caso las relacionadas a la base de datos, para poder conectarnos. Acá se ve como el DATABASE_HOST es el nombre con el que llamamos al container de la imagen que se encuentra en /db (tal como está especificado en el archivo docker-compose.yml de ese directorio). Por eso es importante haber definido un nombre.
- `--network` conecta el container a la red `tp-itba` que creamos al principio de todo.
 
Habiendo ejecutado ese comando, vamos a ver los logs impresos en la terminal de que se descargó la base de la F1, y se están insertando en cada tabla correspondiente, y al final de todo el script, define los constraints de las foreign keys entre las distintas tablas:
 
![logs ETL](./assets/etl/logs_etl.png)
 
## **Reportes**
 
Ahora que ya tenemos la base de datos populada con toda la información podemos empezar a realizarle consultas para obtener nuevos insights y sacarle valor a los datos.
 
Para ejecutar estos reportes, buildeamos y corremos la imagen de Docker que se encuentra en el directorio `/reports`:
 
```
$ cd ../reports
$ docker build -t reports .
$ docker run --rm -e DATABASE_HOST=pg-docker \
-e DATABASE_PORT=5432 \
-e DATABASE=postgres \
-e DATABASE_USER=postgres \
-e DATABASE_PASSWORD=docker \
-v $PWD/results:/app/results \
--network=tp-itba reports
```
Donde los argumentos son iguales al caso del ETL, excepto por el `-v`, este argumento nos monta un directorio `/results` (en este caso también lo crea, dado que no existe) de nuestro sistema, con el directorio `/app/results` del container. Ese directorio es donde se van a guardar los resultados de las queries, por si queremos persisitir los resultados.
 
NOTA: La sintaxis de `$PWD/results` que indica la ruta de nuestro sistema, puede variar un poco según el sistema operativo desde el que se esté corriendo el comando (este ejemplo es para MacOS).
 
Acá vamos a ver cómo se van imprimiendo los resultados de las queries en la terminal. Es importante notar que según la fecha en la que se ejecute el proceso anterior, los resultados pueden variar levemente a los que yo voy a presentar, dado que esta información se va actualizando con las nuevas carreras.
 
Inspeccionemos los resultados de cada query:
 
### Query 1
 
Realizando esta consulta, obtenemos los pilotos que terminaron en una posición menor o igual a 10 en las carrreras de los ultimos 5 años. También devolvemos la cantidad de veces que hicieron la vuelta más rápida de la carrera y los puntos obtenidos en estos 5 años. Los resultados están ordenados decrecientemente por la cantidad de puntos obtienidos en estos 5 años.
 
Obvio que encontramos que los dos pilotos de Mercedez (Hamilton y Bottas) están ahí arriba, pero lo que sí es interesante, es encontrar a Sergio Perez en la posición 8. Quizás los directivos de Force India realizaron esta query cuando decidieron no renovarle a Esteban Ocon y quedarse con Perez en el 2018, que fue muy criticada por la proyección que tenía Ocon.
 
|forename|surname    |id  |earned_points|times_fastest_lap|
|--------|-----------|----|-------------|-----------------|
|Lewis   |Hamilton   |1   |1794.0       |52               |
|Valtteri|Bottas     |822 |1124.0       |16               |
|Sebastian|Vettel     |20  |1106.0       |38               |
|Max     |Verstappen |830 |1046.0       |10               |
|Daniel  |Ricciardo  |817 |758.0        |15               |
|Kimi    |Räikkönen  |8   |687.0        |45               |
|Nico    |Rosberg    |3   |385.0        |20               |
|Sergio  |Pérez      |815 |383.0        |4                |
|Charles |Leclerc    |844 |366.0        |4                |
|Carlos  |Sainz      |832 |300.0        |1                |
|Nico    |Hülkenberg |807 |231.0        |2                |
|Pierre  |Gasly      |842 |177.0        |2                |
|Esteban |Ocon       |839 |172.0        |0                |
|Alexander|Albon      |848 |156.0        |0                |
|Lance   |Stroll     |840 |124.0        |0                |
|Fernando|Alonso     |4   |121.0        |23               |
|Lando   |Norris     |846 |114.0        |2                |
|Romain  |Grosjean   |154 |104.0        |1                |
|Kevin   |Magnussen  |825 |103.0        |2                |
|Felipe  |Massa      |13  |96.0         |15               |
|Daniil  |Kvyat      |826 |81.0         |1                |
|Stoffel |Vandoorne  |838 |26.0         |0                |
|Jenson  |Button     |18  |21.0         |8                |
|Antonio |Giovinazzi |841 |17.0         |0                |
|Marcus  |Ericsson   |828 |9.0          |0                |
|Jolyon  |Palmer     |835 |9.0          |0                |
|Pascal  |Wehrlein   |836 |6.0          |0                |
|Brendon |Hartley    |843 |4.0          |0                |
|Felipe  |Nasr       |831 |2.0          |0                |
|Robert  |Kubica     |9   |1.0          |1                |

 
### Query 2
 
Acá obtenemos los pilotos que en los últimos 5 años tengan mas de 5 carreras corridas, traemos los puntos promedios por carrera y la cantidad de carreras corridas, ordenados por los puntos promedio por carrera obtenidos.
 
Volvemos a encontrar que Perez es algo superior que Esteban Ocon, y obvio que los top pilotos de los últimos 5 años estan ahi primeros.
 
|forename|surname    |mean_points|n_races|
|--------|-----------|-----------|-------|
|Lewis   |Hamilton   |19.085106382978722|94     |
|Nico    |Rosberg    |18.333333333333332|21     |
|Valtteri|Bottas     |11.957446808510639|94     |
|Sebastian|Vettel     |11.76595744680851|94     |
|Max     |Verstappen |11.127659574468085|94     |
|Daniel  |Ricciardo  |8.063829787234043|94     |
|Kimi    |Räikkönen  |7.308510638297872|94     |
|Charles |Leclerc    |6.90566037735849|53     |
|Alexander|Albon      |4.875      |32     |
|Sergio  |Pérez      |4.163043478260869|92     |
|Lando   |Norris     |3.5625     |32     |
|Carlos  |Sainz      |3.1914893617021276|94     |
|Pierre  |Gasly      |3.0517241379310347|58     |
|Esteban |Ocon       |2.819672131147541|61     |
|Nico    |Hülkenberg |2.686046511627907|86     |
|Felipe  |Massa      |2.4        |40     |
|Fernando|Alonso     |2.0166666666666666|60     |
|Lance   |Stroll     |1.7222222222222223|72     |
|Daniil  |Kvyat      |1.1911764705882353|68     |
|Romain  |Grosjean   |1.1063829787234043|94     |
|Kevin   |Magnussen  |1.0957446808510638|94     |
|Jenson  |Button     |0.9545454545454546|22     |
|Stoffel |Vandoorne  |0.6190476190476191|42     |
|Antonio |Giovinazzi |0.5        |34     |
|Jolyon  |Palmer     |0.24324324324324326|37     |
|Brendon |Hartley    |0.16       |25     |
|Pascal  |Wehrlein   |0.15384615384615385|39     |
|Marcus  |Ericsson   |0.14516129032258066|62     |
|Felipe  |Nasr       |0.09523809523809523|21     |
|Robert  |Kubica     |0.047619047619047616|21     |
|Sergey  |Sirotkin   |0.047619047619047616|21     |
|Esteban |Gutiérrez  |0.0        |21     |
|Rio     |Haryanto   |0.0        |12     |
|Nicholas|Latifi     |0.0        |11     |
|George  |Russell    |0.0        |32     |

 
### Query 3
 
En este reporte, encontramos la proporción de pilotos en toda la historia, que largando en las distintas posiciones, llegaron en primer lugar al final de la carrera. O sea, el 42% de pilotos que largaron en primer lugar, terminaron ganando la carrera, mientras que el 24% de los que la arrancaron en segundo lugar, levantaron el título.
 
Haciendo un análisis parecido, llegamos a que el 63% de los que largaron en la primera posición, llegaron en primer, segundo o tercer lugar. Mientras que el 54% de los pilotos que largaron en segundo lugar, se subieron al podio.
 
Es muy claro cómo decrecen las chances de ganar o subirse al podio a medida que arrancas más lejos de la carrera, dejándole un papel fundamental a la qualy del dia anterior (la que define la posición de largada)
 
|grid|win_ratio  |podium_ratio|
|----|-----------|------------|
|1   |0.42       |0.63        |
|2   |0.24       |0.54        |
|3   |0.12       |0.46        |
|4   |0.06       |0.34        |
|5   |0.05       |0.25        |
|6   |0.04       |0.19        |
|7   |0.02       |0.14        |
|8   |0.02       |0.11        |
|9   |0.0        |0.09        |
|10  |0.01       |0.06        |
|11  |0.0        |0.04        |
|12  |0.0        |0.04        |
|13  |0.0        |0.03        |
|14  |0.01       |0.03        |
|15  |0.0        |0.01        |
|16  |0.0        |0.02        |
|17  |0.0        |0.01        |
|18  |0.0        |0.01        |
|19  |0.0        |0.0         |
|20  |0.0        |0.01        |
|21  |0.0        |0.0         |
|22  |0.0        |0.0         |
|23  |0.0        |0.0         |
|24  |0.0        |0.0         |
|25  |0.0        |0.0         |
|26  |0.0        |0.01        |
|27  |0.0        |0.0         |
|28  |0.0        |0.04        |
|29  |0.0        |0.0         |
|30  |0.0        |0.0         |
|31  |0.0        |0.0         |
|32  |0.0        |0.06        |
|33  |0.0        |0.0         |
|34  |0.0        |0.0         |

 
### Query 4
 
Ahora bien, viendo el reporte anterior, encontramos que hubo pilotos que largaron bastante atrás e igual se subieron al podio.
 
Busquemos los pilotos que hayan largado una carrera después de la posición 15 (grid), pero que hayan terminado en el podio (1, 2 o 3) y la fecha en que realizaron tremenda hazaña. Ordenado por las carreras en las que el piloto arrancó desde más atrás.
 
|forename|surname    |position_order|grid|date      |
|--------|-----------|--------------|----|----------|
|Jim     |Rathmann   |2             |32  |1957-05-30|
|Onofre  |Marimón    |3             |28  |1954-07-17|
|Paul    |Goldsmith  |3             |26  |1960-05-30|
|Don     |Freeland   |3             |26  |1956-05-30|
|Ron     |Flockhart  |3             |26  |1956-09-02|
|George  |Amick      |2             |25  |1958-05-30|
|Sebastian|Vettel     |3             |24  |2012-11-04|
|Emerson |Fittipaldi |3             |24  |1980-03-30|
|Niki    |Lauda      |2             |23  |1983-03-27|
|Teo     |Fabi       |3             |23  |1984-06-24|
|Lewis   |Hamilton   |3             |22  |2014-07-27|
|John    |Watson     |1             |22  |1983-03-27|
|Kimi    |Räikkönen  |3             |22  |2006-03-12|
|John    |Watson     |3             |21  |1983-06-05|
|Lewis   |Hamilton   |3             |21  |2016-08-28|
|Wolfgang|von Trips  |3             |21  |1958-07-06|
|Juan    |Pablo Montoya|2             |20  |2005-07-24|
|Carlos  |Sainz      |3             |20  |2019-11-17|
|Sebastian|Vettel     |2             |20  |2019-07-28|
|Jarno   |Trulli     |3             |20  |2009-03-29|
|Rubens  |Barrichello|3             |20  |2005-06-12|
|Jacques |Laffite    |2             |20  |1985-11-03|
|Lewis   |Hamilton   |3             |20  |2014-07-20|
|Bill    |Vukovich   |1             |19  |1954-05-31|
|Alexander|Wurz       |3             |19  |2007-06-10|
|Max     |Verstappen |2             |18  |2018-10-21|
|Mark    |Webber     |3             |18  |2011-04-17|
|Peter   |Whitehead  |3             |18  |1950-07-02|
|Rubens  |Barrichello|1             |18  |2000-07-30|
|Riccardo|Patrese    |3             |18  |1982-04-04|
|Jacques |Laffite    |3             |18  |1983-03-13|
|Philippe|Streiff    |3             |18  |1985-11-03|
|Eddie   |Cheever    |3             |17  |1989-06-04|
|Nelson  |Piquet Jr. |2             |17  |2008-07-20|
|Tiago   |Monteiro   |3             |17  |2005-06-19|
|Kimi    |Räikkönen  |1             |17  |2005-10-09|
|Lewis   |Hamilton   |3             |17  |2009-10-18|
|John    |Watson     |1             |17  |1982-06-06|
|Emerson |Fittipaldi |3             |17  |1971-07-04|
|Rolf    |Stommelen  |3             |17  |1970-08-16|
|Romain  |Grosjean   |3             |17  |2013-10-27|
|Denny   |Hulme      |3             |16  |1970-08-02|
|Mario   |Andretti   |3             |16  |1970-04-19|
|Jackie  |Stewart    |1             |16  |1973-03-03|
|Onofre  |Marimón    |3             |16  |1953-06-21|
|Jacky   |Ickx       |2             |16  |1975-04-27|
|Alan    |Jones      |3             |16  |1977-09-11|
|Jean-Pierre|Jarier     |3             |16  |1979-07-14|
|Fernando|Alonso     |3             |16  |2005-10-09|
|Clay    |Regazzoni  |2             |16  |1979-05-27|
|Jacques |Laffite    |3             |16  |1985-07-21|
|Rubens  |Barrichello|3             |16  |2008-07-06|
|Max     |Verstappen |3             |16  |2017-04-09|
|Jyrki   |Järvilehto |3             |16  |1991-04-28|
|Michael |Schumacher |1             |16  |1995-08-27|
|Jean-Pierre|Beltoise   |2             |16  |1968-06-23|

 
### Query 5
 
En este reporte entendemos que tanto suelen cambiarse de equipo los pilotos, se imprime la proporción de pilotos que hayan tenido más de uno, dos o tres equipos en los últimos 5 años
 
|mas_un_equipo|mas_dos_equipos|mas_tres_equipos|
|-------------|---------------|----------------|
|0.4444444444444444|0.1388888888888889|0.0             |

 
### Query 6
 
Aca nos centramos más en los equipos y su performance en términos de paradas en los boxes: cual fue su menor parada (en milisegundos), cual fue el tiempo promedio de paradas (en milisegundos) y cuantas veces fueron la parada más rápida de la carrera
 
|name|min_ms     |mean_ms|max_ms |n_fastest_ps|
|----|-----------|-------|-------|------------|
|Marussia|13981      |34396.83690987124|1135937|5           |
|McLaren|13173      |52996.2625994695|2010062|25          |
|Caterham|14250      |33924.61825726141|1133381|4           |
|Sauber|13201      |44546.52495974235|2008206|8           |
|Haas F1 Team|15073      |68018.29761904762|2011147|3           |
|Lotus F1|16120      |32463.750877192982|1133680|5           |
|Ferrari|13259      |49937.5518134715|2010637|18          |
|Virgin|13914      |24236.194805194806|49849  |1           |
|Toro Rosso|14641      |44486.98389458272|2011266|12          |
|Mercedes|13199      |57946.07301173403|2010361|29          |
|Renault|12959      |63261.833746898265|2008979|4           |
|Racing Point|16546      |104668.64406779662|1524989|2           |
|AlphaTauri|17522      |164468.68421052632|1524139|1           |
|Force India|14128      |50845.77011494253|2008504|4           |
|Red Bull|13335      |51784.38331160365|2009643|41          |
|Manor Marussia|16218      |84025.75|2009052|2           |
|HRT |14160      |32677.766666666666|1004718|1           |
|Alfa Romeo|17594      |86599.75968992249|1521825|3           |
|Lotus|20652      |24444.21176470588|51684  |0           |
|Williams|12897      |54748.44345616264|2009630|28          |

 
### Query 7
 
Aca respondemos la pregunta que nos estamos haciendo todos (o deberíamos).
 
**Schumacher vs Hamilton**: quien es el rey de la F1?
Vemos que con la victoria de la última carrera disputada el domingo 11/10 en el GP de Eifel, Hamilton lo empato a Schumacher en la cantidad de carreras ganadas, solo que Hamilton lo hizo en menos carreras, llegando a ganar el 34.8% de sus carreras y registrando 61.3% de podios, mientras que Schumacher gano el 29.5% de todas las carreras y ese subió al podio en el 50.3%.
 
Obviamente que son dos monstruos de la F1, y no queda otra que disfrutar de las carreras de Hamilton que sigue estando vigente.
 
|forename|surname    |wins|win_ratio|podiums|podium_ratio      |races|
|--------|-----------|----|---------|-------|------------------|-----|
|Lewis   |Hamilton   |91  |0.3486590038314176|160    |0.6130268199233716|261  |
|Michael |Schumacher |91  |0.29545454545454547|155    |0.5032467532467533|308  |

 
Aca hay una [nota](https://www.infobae.com/deportes/2020/10/12/hamilton-alcanzo-el-record-historico-de-schumacher-es-el-mejor-piloto-en-la-historia-de-la-formula-1/) publicada en Infobae después de la carrera  del 11/10, donde realizan estas y otras comparaciones entre Shcumacher y Hamilton.
 
## **Clean Up**
Una vez que obtuvimos los insights necesarios, ya podemos limpiar todo el proyecto. Para eso, abrimos otra terminal en `/db`:
```
$ docker-compose down
```
 
Con este comando, dejamos de exponer la base de datos. Ahora ya podemos remover la red creada al principio de todo:
```
$ docker network rm tp-itba
```
