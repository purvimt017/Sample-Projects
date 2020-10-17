--Query pulling data for Brazing Operation in Manufacturing
IF OBJECT_ID('tempdb..#d') IS NOT NULL DROP TABLE #d


select 
 cast(r.DATEWIP as date) as 'Date WIP'
 , pb.ITEMID as 'BomId'
 , i.InventBatchId as 'Bom Batch'
 , cast((select sum(OnHand) 
		from BusinessIntelligence.dbo.InventoryDetailedView 
		where ITEMID = pb.ITEMID 
			and InventBatchId = i.InventBatchId) as decimal(18,2)) as 'Bom On-Hand'
, p.ITEMID as 'ItemId'
, p.PRODID  as 'Item Batch'
, cast((select sum(OnHand) 
		from BusinessIntelligence.dbo.InventoryDetailedView 
		where ITEMID = p.ITEMID 
			and InventBatchId = p.PRODID) as decimal(18,2)) as 'Item On-Hand'
into #d 
from PRODTABLE p
inner join PRODJOURNALBOM pb
	on pb.PRODID = p.PRODID
	and pb.DATAAREAID = p.DATAAREAID
	and pb.PARTITION = p.PARTITION
inner join BusinessIntelligence.dbo.InventoryDetailedView i 
	on i.ITEMID = pb.ITEMID
	and i.INVENTDIMID = pb.INVENTDIMID
	and i.DATAAREAID = pb.DATAAREAID --index
	and i.PARTITION = pb.PARTITION --index
inner join PRODROUTETRANS r 
	on r.TRANSREFTYPE = 0
	and r.TRANSREFID = i.InventBatchId
	and r.DATAAREAID = i.DATAAREAID
	and r.PARTITION = i.PARTITION
where  r.OPRID = 2721
and r.DATEWIP between '03/26/2018' and '06/05/2019'
and p.DATAAREAID = 'RMO' --index
and p.PARTITION = 5637144576 --index
order by Datewip asc

select * from #d where ([Bom On-Hand] <> 0) or ([Item On-Hand] <> 0)

order by [Date WIP] 
