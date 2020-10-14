FROM ubuntu:18.04

RUN apt-get update
RUN apt-get -y install postgresql-client

COPY . /app

WORKDIR /app

CMD bash ./create_database.sh