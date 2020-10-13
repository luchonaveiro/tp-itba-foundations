-- Pilotos que hayan largado despues de la posicion 15, pero que hayan terminado en el podio (1,2 o 3)

select drivers.forename,
       drivers.surname,
       position_order,
       grid,
       date
from f1.results
join f1.drivers on results.driver_id=drivers.id
join f1.races on results.race_id=races.id
where grid > 15 and position_order <=3
order by grid desc