-- Ahora, la pregunta que ons estabamos haciendo todos: Shumacher vs Hamilton
-- Vamos a buscar la cantidad de carreras que gano cada uno, y la proporcion de carreras ganadas
-- Tambien buscamos la cantidad de podios de cada uno, y la proporcion de carreras terminadas en el podio

select drivers.forename,
       drivers.surname,
       sum(case when position=1 then 1 else 0 end) as wins,
       sum(case when position=1 then 1.00 else 0.00 end)/count(*) as win_ratio,
       sum(case when position<=3 then 1 else 0 end) as podiums,
       sum(case when position<=3 then 1.00 else 0.00 end)/count(*) as podium_ratio,
       count(*) as races
from f1.results
join f1.drivers on results.driver_id=drivers.id
where drivers.driver_ref in ('michael_schumacher','hamilton')
group by 1,2


