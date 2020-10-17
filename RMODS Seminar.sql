--Find Sales for RMOD Seminar products

select
 itemid as ItemId
 ,case MonthCreated 
	when 2 then 'Feb - 2019'
	when 4 then 'Apr - 2019'
	when 5 then 'May - 2019'
	when 6 then 'Jun - 2019'
	when 7 then 'Jul - 2019'
	when 8 then 'Aug - 2019'
end as Month
--, YearCreated as Year 
, count(ItemId) as QtyOrdered
, sum(LineAmount) as TotalAmount 
from SalesLineView 
where ItemId in ('RMODS-SE1', 'RMODS-SE2')
and monthcreated < 10
and yearcreated = 2019
group by ItemId, MonthCreated, YearCreated
order by MonthCreated-- where ItemId = 'RMODS Seminar 1'