-- Proporcion de pilotos que hayan tenido mas de uno, dos o tres equipos en los ultimos 5 años

with drivers_constructors as (
select results.driver_id,
       count(distinct results.constructor_id) as n_constructors
from f1.results
join f1.races on results.race_id=races.id
where extract(day from now()::timestamp - races.date::timestamp)/365 <= 5
group by 1)

select count(case when n_constructors>1 then driver_id end)*1.00/count(*) as mas_un_equipo,
       count(case when n_constructors>2 then driver_id end)*1.00/count(*) as mas_dos_equipos,
       count(case when n_constructors>3 then driver_id end)*1.00/count(*) as mas_tres_equipos
from drivers_constructors