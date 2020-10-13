-- Pilotos que terminaron en una posicion menor o igual a 10 en las carrreras de los ultimos 5 años,
-- junto con la cantidad de veces que hicieron la vuelta mas rapida de la carrera.
-- Ordenados decrecientemente por la cantidad de puntos obtienidos en estos 5 años

with profitable_drivers as (
select drivers.forename,
       drivers.surname,
       drivers.id,
       sum(results.points) as earned_points
from f1.results
join f1.races on results.race_id=races.id
join f1.drivers on results.driver_id=drivers.id
where extract(day from now()::timestamp - races.date::timestamp)/365 <= 5 and position <= 10
group by 1,2,3),

fastest_lap as (
select driver_id,
       count(*) times_fastest_lap
from (
select race_id,
       driver_id,
       time,
       row_number() over (partition by race_id order by miliseconds) as fastest_lap
from f1.lap_times) as a
where fastest_lap=1
group by 1
)

select a.*,
       coalesce(b.times_fastest_lap,0) as times_fastest_lap
from profitable_drivers a
left join fastest_lap b on a.id=b.driver_id
order by earned_points desc