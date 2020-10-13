-- Pilotos que en los ultimos 5 años tengan mas de 5 carrreras corridas, ordenados por los puntos promedio obtenidos

select drivers.forename,
       drivers.surname,
       sum(results.points)/count(distinct races.id) as mean_points,
       count(distinct races.id) n_races
from f1.results
join f1.races on results.race_id=races.id
join f1.drivers on results.driver_id=drivers.id
where extract(day from now()::timestamp - races.date::timestamp)/365 <= 5
group by 1,2
having count(distinct races.id) >= 5
order by 3 desc