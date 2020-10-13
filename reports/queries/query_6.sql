-- Performance de los equipos en terminos de paradas en los boxes
-- Cual fue su menor parada (en milisegundos), cual fue el tiempo promedio de paradas (en milisegundos)
-- y cuantas veces fueron la parada mas rapida de la carrera

with avg_pitstops as (
select results.constructor_id,
       min(pit_stops.miliseconds) as min_ms,
       avg(pit_stops.miliseconds*1.000) as mean_ms,
       max(pit_stops.miliseconds) as max_ms
from f1.pit_stops
join f1.results on pit_stops.driver_id=results.driver_id and pit_stops.race_id=results.race_id
group by 1
)

, pit_stop_record as (
select results.constructor_id,
       sum(case when a.time_rank=1 then 1 else 0 end) as n_fastest_ps
from (
select *,
       row_number() over (partition by race_id order by miliseconds) as time_rank
from f1.pit_stops) a
join f1.results on a.driver_id=results.driver_id and a.race_id=results.race_id
group by 1)

select constructors.name,
       a.min_ms,
       a.mean_ms,
       a.max_ms,
       b.n_fastest_ps
from avg_pitstops a
left join pit_stop_record b on a.constructor_id=b.constructor_id
join f1.constructors on a.constructor_id=constructors.id