-- Performance de los equipos en terminos de paradas en los boxes
-- Cual fue su menor parada (en milisegundos), cual fue el tiempo promedio de paradas (en milisegundos)
-- y cuantas veces fueron la parada mas rapida de la carrera

select constructors.name,
       min(a.miliseconds) as min_ms,
       avg(a.miliseconds*1.000) as mean_ms,
       max(a.miliseconds) as max_ms,
       sum(case when a.time_rank=1 then 1 else 0 end) as n_fastest_ps
from (
select *,
       row_number() over (partition by race_id order by miliseconds) as time_rank
from f1.pit_stops) a
join f1.results on a.driver_id=results.driver_id and a.race_id=results.race_id
join f1.constructors on results.constructor_id=constructors.id
group by 1