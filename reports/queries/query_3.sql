-- que proporcion de carreras gano cada partida en la grilla? 
-- que proporcion llego al podio?

select grid,
       cast(sum(case when position_order=1 then 1.000 else 0.000 end)/count(distinct race_id) as decimal(10,2)) as win_ratio,
       cast(sum(case when position_order<=3 then 1.000 else 0.000 end)/count(distinct race_id) as decimal(10,2)) as podium_ratio
from f1.results
where grid>0
group by 1
order by 1
