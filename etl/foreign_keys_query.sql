
ALTER TABLE f1.races ADD FOREIGN KEY (circuit_id) REFERENCES f1.circuits(id);
ALTER TABLE f1.constructor_results ADD FOREIGN KEY (race_id) REFERENCES f1.races(id);
ALTER TABLE f1.constructor_results ADD FOREIGN KEY (race_id) REFERENCES f1.races(id);
ALTER TABLE f1.constructor_standings ADD FOREIGN KEY (race_id) REFERENCES f1.races(id);
ALTER TABLE f1.constructor_standings ADD FOREIGN KEY (constructor_id) REFERENCES f1.constructors(id);
ALTER TABLE f1.driver_standings ADD FOREIGN KEY (race_id) REFERENCES f1.races(id);
ALTER TABLE f1.driver_standings ADD FOREIGN KEY (driver_id) REFERENCES f1.drivers(id);
ALTER TABLE f1.lap_times ADD FOREIGN KEY (race_id) REFERENCES f1.races(id);
ALTER TABLE f1.lap_times ADD FOREIGN KEY (driver_id) REFERENCES f1.drivers(id);
ALTER TABLE f1.pit_stops ADD FOREIGN KEY (race_id) REFERENCES f1.races(id);
ALTER TABLE f1.pit_stops ADD FOREIGN KEY (driver_id) REFERENCES f1.drivers(id);
ALTER TABLE f1.qualifying ADD FOREIGN KEY (race_id) REFERENCES f1.races(id);
ALTER TABLE f1.qualifying ADD FOREIGN KEY (driver_id) REFERENCES f1.drivers(id);
ALTER TABLE f1.qualifying ADD FOREIGN KEY (constructor_id) REFERENCES f1.constructors(id);
ALTER TABLE f1.results ADD FOREIGN KEY (race_id) REFERENCES f1.races(id);
ALTER TABLE f1.results ADD FOREIGN KEY (driver_id) REFERENCES f1.drivers(id);
ALTER TABLE f1.results ADD FOREIGN KEY (constructor_id) REFERENCES f1.constructors(id);