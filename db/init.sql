CREATE SCHEMA f1;

CREATE TABLE f1.circuits
(
    id int primary key,
    circuit_ref varchar(255) not null,
    name varchar(255) not null,
    location varchar(255),
    country varchar(255),
    lat float,
    lng float,
    alt float,
    url varchar(255) not null
);

CREATE TABLE f1.races
(
	id int primary key,
	year int not null,
	round int not null,
	circuit_id int not null,
	name varchar(255) not null,
	date timestamp not null,
	time varchar(255),
	url varchar(255)
);

CREATE TABLE f1.constructors
(
	id int primary key,
	constructor_ref varchar(255) not null,
	name varchar(255) not null,
	nationality varchar(255),
	url varchar(255) not null
);

CREATE TABLE f1.constructor_results
(
	id int primary key,
	race_id int not null,
	constructor_id int not null,
	points float,
	status varchar(255)

);

CREATE TABLE f1.constructor_standings
(
	id int primary key,
	race_id int not null,
	constructor_id int not null,
	points float not null,
	position int,
	position_text varchar(255),
	wins int not null
);

CREATE TABLE f1.drivers
(
	id int primary key,
	driver_ref varchar(255) not null,
	number float,
	code varchar(3),
	forename varchar(255) not null,
	surname varchar(255) not null,
	dob timestamp,
	nationality varchar(255),
	url varchar(255)
);

CREATE TABLE f1.driver_standings
(
	id int primary key,
	race_id int not null,
	driver_id int not null,
	points float not null,
	position int,
	position_text varchar(255),
	wins int not null
);

CREATE TABLE f1.lap_times
(
	race_id int,
	driver_id int,
	lap int,
	position float,
	time varchar(255),
	miliseconds int,
	PRIMARY KEY (race_id, driver_id, lap)
);

CREATE TABLE f1.pit_stops
(
	race_id int,
	driver_id int,
	stop int,
	lap float,
	time varchar(255),
	duration varchar(255),
	miliseconds int,
	PRIMARY KEY (race_id, driver_id , stop)
);

CREATE TABLE f1.qualifying
(
	id int primary key,
	race_id int not null,
	driver_id int not null,
	constructor_id int not null,
	number int not null,
	position float,
	q1 varchar(255),
	q2 varchar(255),
	q3 varchar(255)
);

CREATE TABLE f1.results
(
	id int primary key,
	race_id int not null,
	driver_id int not null,
	constructor_id int not null,
	number float,
	grid int not null,
	position float,
	position_text varchar(255) not null,
	position_order int not null,
	points float not null,
	laps int not null,
	time varchar(255),
	miliseconds float,
	fastest_lap float,
	rank float,
	fastest_lap_time varchar(255),
	fastest_lap_speed varchar(255),
	status_id int not null
);

CREATE TABLE f1.seasons
(
	year int primary key,
	url varchar(255) not null
);

CREATE TABLE f1.status
(
	status_id int primary key,
	status varchar(255) not null
);