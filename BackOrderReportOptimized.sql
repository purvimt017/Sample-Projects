declare @fromdate datetime = '04-01-2019'
	,@todate datetime = '08-31-2019';

IF OBJECT_ID('tempdb..#DATA') IS NOT NULL DROP TABLE #DATA
IF OBJECT_ID('tempdb..#DATA2') IS NOT NULL DROP TABLE #DATA2
IF OBJECT_ID('tempdb..#DATA3') IS NOT NULL DROP TABLE #DATA3
IF OBJECT_ID('tempdb..#DATA4') IS NOT NULL DROP TABLE #DATA4
IF OBJECT_ID('tempdb..#DATA5') IS NOT NULL DROP TABLE #DATA5
IF OBJECT_ID('tempdb..#DATA6') IS NOT NULL DROP TABLE #DATA6
IF OBJECT_ID('tempdb..#DATA7') IS NOT NULL DROP TABLE #DATA7;

with i as (
Select distinct i.ITEMID AS 'Item Id'
		,min(sl.salesid) as 'Oldest SO'
		,min(it.SHIPPINGDATEREQUESTED) as 'Shipping Date Rqstd' 
from INVENTTABLE i --WITH (NOLOCK)
Inner Join inventtrans it --WITH (NOLOCK)
	on it.ITEMID = i.ITEMID
	and (it.STATUSISSUE = 5 or it.STATUSISSUE = 6)
	and it.SHIPPINGDATEREQUESTED >= @fromdate
	AND it.SHIPPINGDATEREQUESTED <= @todate
	and it.DATAAREAID = i.DATAAREAID
	and it.[PARTITION] = i.[PARTITION]
Inner Join INVENTTABLEMODULE im  --WITH (NOLOCK)
	on im.ITEMID = i.ITEMID
	and im.LINEDISC not like 'PW%'
	and im.MODULETYPE = 2
	and im.DATAAREAID = i.DATAAREAID
	and im.[PARTITION] = i.[PARTITION]
inner Join SALESLINE sl --WITH (NOLOCK)
	on sl.ITEMID = i.ITEMID
	and sl.DATAAREAID = i.DATAAREAID
	and sl.[PARTITION] = i.[PARTITION]
inner Join SALESTABLE s  --WITH (NOLOCK)
	on sl.SALESID = s.salesid
	--and s.SHIPPINGDATEREQUESTED = it.SHIPPINGDATEREQUESTED
	and sl.DATAAREAID = s.DATAAREAID
	and sl.[PARTITION] = s.[PARTITION]
Inner join INVENTTRANSORIGIN iyo --WITH (NOLOCK)
	on iyo.ITEMID = it.ITEMID
	and sl.INVENTTRANSID = iyo.INVENTTRANSID
	and iyo.RECID = it.INVENTTRANSORIGIN
	and iyo.DATAAREAID = it.DATAAREAID
	and iyo.[PARTITION] = it.[PARTITION]
where i.COMMISSIONGROUPID = 'Purch'
and i.DATAAREAID = 'RMO'
and i.PARTITION = 5637144576
	--and i.ITEMID = 'KQ12402'
group by i.itemid--, sl.QTYORDERED, w.QTY
)

select [Item Id], [Oldest SO], [Shipping Date Rqstd] 
	,(select top 1 DELIVERYNAME 
		from SALESTABLE -- WITH (NOLOCK)
		where SALESID = [Oldest SO] 
		and SALESTABLE.DATAAREAID = 'rmo' 
		and SALESTABLE.[PARTITION] = 5637144576)  as 'Name'
	,(select sum(PostedQty + Received - Deducted + Registered - Picked)
			from INVENTSUM s --WITH (NOLOCK)
			inner join INVENTDIM d --WITH (NOLOCK)
			on s.INVENTDIMID = d.INVENTDIMID
			and (d.INVENTLOCATIONID = '110'
			or d.INVENTLOCATIONID = '111'
			or d.INVENTLOCATIONID = '113'
			or d.INVENTLOCATIONID like '6*'
			or d.INVENTLOCATIONID like '5*'
			or d.INVENTLOCATIONID like '4*')
			and s.DATAAREAID = d.DATAAREAID
			and s.[PARTITION] = d.[PARTITION]
			where s.ITEMID = [Item Id]
			and s.DATAAREAID = 'rmo'
			and s.[PARTITION] = 5637144576) as 'In QA/Eng' 
	,(select item.OnHand 
		from BusinessIntelligence.dbo.ItemExtendedView item  --WITH (NOLOCK)
		where item.ItemId = [Item Id] 
		and item.DataAreaId = 'rmo' 
		and item.[Partition] = 5637144576) as 'On Hand'
	,(select min(SALESLINE.QTYORDERED) from SALESLINE where salesline.SALESID = [Oldest SO] and salesline.ITEMID = [Item Id] and salesline.DATAAREAID = 'RMO' and salesline.PARTITION = 5637144576) as 'Qty Ordered'
	,(select min(w.qty) as BOQTY
			from SALESLINE sl
			join  WMSORDERTRANS w
				on w.INVENTTRANSID = sl.INVENTTRANSID
				and w.EXPEDITIONSTATUS = 10
				and w.ITEMID = sl.ITEMID
				and w.DATAAREAID = sl.DATAAREAID
				and w.[PARTITION] = sl.[PARTITION]
			where (sl.salesid = [Oldest SO]
			and sl.ITEMID = i.[Item Id])
			and sl.DATAAREAID = 'RMO'
			and sl.[PARTITION] = 5637144576 ) as 'Picked Qty'
into #DATA
 from i

select *
, (([Qty Ordered] - (coalesce([Picked Qty], 0.00))) * -1) as 'SO Remain Qty'
, [On Hand] + (([Qty Ordered] - (coalesce([Picked Qty], 0.00))) * -1) as 'SO Over/Under Qty' 
into #DATA2 
from #DATA 

Select * into #DATA3 from #DATA2
where [SO Over/Under Qty] < 0

SELECT *
,(select sum(ONORDER)*-1 
		from INVENTSUM --WITH (NOLOCK)
		where inventsum.ITEMID = #DATA3.[Item Id] 
		and INVENTSUM.DATAAREAID = 'rmo'
		and inventsum.[PARTITION] = 5637144576) as 'Total SO Demand'
,(select min(p.PRODID)  
		from PRODTABLE p --WITH (NOLOCK)
		where p.ITEMID = #DATA3.[Item Id]
		and p.PRODSTATUS <> 5 
		and p.PRODSTATUS <> 7
		and p.DATAAREAID = 'rmo'
		and p.[PARTITION] = 5637144576) as 'Oldest Pack WO'
into #DATA4
From #DATA3


select *
, (select sum(QTYSCHED) 
		from PRODTABLE  --WITH (NOLOCK)
		where PRODTABLE.ITEMID = #DATA4.[Item Id]
		and prodtable.PRODID = #DATA4.[Oldest Pack WO]
		and prodtable.DATAAREAID = 'rmo'
		and prodtable.[PARTITION] = 5637144576) as 'WO Pack Qty' 
, (select sum(qtysched) 
		from prodtable --WITH (NOLOCK)
		where prodtable.ITEMID = #DATA4.[Item Id]
		and prodtable.PRODSTATUS not in (5,7)
		and prodtable.DATAAREAID = 'rmo'
		and PRODTABLE.[PARTITION] = 5637144576) as 'WO Pack Total Qty'
,(select min(itemid) as BomId
		from BOM --WITH (NOLOCK)
		where BOMID = #DATA4.[Item Id]
		and BOM.DATAAREAID = 'rmo'
		and BOM.[PARTITION] = 5637144576) as 'BOM Item'
Into #DATA5
from #DATA4

SELECT *
,(select sum(PostedQty + Received - Deducted + Registered - Picked)
			from INVENTSUM s --WITH (NOLOCK)
			inner join INVENTDIM d --WITH (NOLOCK)
			on s.INVENTDIMID = d.INVENTDIMID
			and (d.INVENTLOCATIONID = '110'
			or d.INVENTLOCATIONID = '111'
			or d.INVENTLOCATIONID = '113'
			or d.INVENTLOCATIONID like '6*'
			or d.INVENTLOCATIONID like '5*'
			or d.INVENTLOCATIONID like '4*')
			and s.DATAAREAID = d.DATAAREAID
			and s.[PARTITION] = d.[PARTITION]
			where s.ITEMID = #DATA5.[BOM Item]
			and s.DATAAREAID = 'rmo'
			and s.[PARTITION] = 5637144576) as 'BOM in QA/Eng'
,(select item.OnHand 
		from BusinessIntelligence.dbo.ItemExtendedView item  --WITH (NOLOCK)
		where item.ItemId = #DATA5.[BOM Item]
		and item.DataAreaId = 'rmo' 
		and item.[Partition] = 5637144576) as 'BOM On Hand'
,(select -1*sum(onorder) 
		from INVENTSUM s
		where s.ITEMID = #DATA5.[BOM Item]
		and s.DATAAREAID = 'RMO'
		and s.[PARTITION] = 5637144576) as 'BOM On Order'
,(select min(p.PRODID)  
		from PRODTABLE p --WITH (NOLOCK)
		where p.ITEMID = #DATA5.[BOM Item]	
		and p.PRODSTATUS <> 5 
		and p.PRODSTATUS <> 7
		and p.DATAAREAID = 'rmo'
		and p.[PARTITION] = 5637144576) as 'Oldest WO'
Into 
#DATA6
from #DATA5

SELECT * 
,(select CASE PRODSTATUS
			WHEN 0 THEN 'Created'
			WHEN 1 THEN 'Estimated'
			WHEN 2 THEN 'Scheduled'
			WHEN 3 THEN 'Released'
			WHEN 4 THEN 'Started'
			WHEN 5 THEN 'Reported as finished'
			WHEN 7 THEN 'Ended'
			ELSE 'Other - '  END	 
		from PRODTABLE  --WITH (NOLOCK)
		where PRODTABLE.ITEMID = #DATA6.[BOM Item]
		and prodtable.PRODID = #DATA6.[Oldest WO]
		and prodtable.DATAAREAID = 'rmo'
		and prodtable.[PARTITION] = 5637144576) as 'WO Status'
,(select sum(QTYSCHED) 
		from PRODTABLE  --WITH (NOLOCK)
		where PRODTABLE.ITEMID = #DATA6.[BOM Item] 
		and prodtable.PRODID = #DATA6.[Oldest WO]
		and prodtable.DATAAREAID = 'rmo'
		and prodtable.[PARTITION] = 5637144576) as 'WO Qty'
,(select sum(qtysched) 
		from prodtable --WITH (NOLOCK)
		where prodtable.ITEMID = #DATA6.[BOM Item]
		and prodtable.PRODSTATUS not in (5,7)
		and prodtable.DATAAREAID = 'rmo'
		and PRODTABLE.[PARTITION] = 5637144576) as 'Total WO Qty'
,(select  concat(max(r.WRKCTRID),concat(' - ', (select rv.ResourceName from businessintelligence.dbo.resourceview rv where r.WRKCTRID = rv.ResourceId)))
				from PRODROUTESCHEDULINGVIEW r
				join PRODTABLE p
				on r.PRODID = #DATA6.[Oldest WO]
				and p.DATAAREAID = r.DATAAREAID
				and p.[PARTITION] = r.[PARTITION]
				where p.ITEMID = #DATA6.[BOM Item]
				and r.BACKORDERSTATUS <> 5
				and r.BACKORDERSTATUS <> 3 
				and p.PRODSTATUS <> 5 and p.PRODSTATUS <> 7
				and p.DATAAREAID = 'RMO'
				and p.[PARTITION] = 5637144576
				group by r.WRKCTRID, r.OPRID) as 'WO Next Resource'
,(select concat(max(r.OPRID), concat(' - ' ,(select opr.name from ROUTEOPRTABLE opr where r.OPRID = opr.oprid)))
				from PRODROUTESCHEDULINGVIEW r
				join PRODTABLE p
				on r.PRODID = #DATA6.[Oldest WO]
				and r.DATAAREAID = p.DATAAREAID
				and r.[PARTITION] = p.[PARTITION]
				where p.ITEMID =#DATA6.[BOM Item]
				and r.BACKORDERSTATUS <> 5
				and r.BACKORDERSTATUS <> 3 
				and p.PRODSTATUS <> 5 and p.PRODSTATUS <> 7
				and p.DATAAREAID = 'RMO'
				and p.[PARTITION] = 5637144576
				group by r.WRKCTRID, r.OPRID) as 'WO Next Operation'
,(select min(NAME) 
		from PRODGROUP where PRODGROUPID = (select PRODGROUPID
												from INVENTTABLE 
												where INVENTTABLE.itemid =  #DATA6.[BOM Item]
												and INVENTTABLE.DATAAREAID = 'RMO'
												and INVENTTABLE.[PARTITION] = 5637144576
																									)
						and PRODGROUP.DATAAREAID = 'RMO'
						and PRODGROUP.[Partition] = 5637144576 ) as 'Prod Group Name'
,(select COMMISSIONGROUPID
			from INVENTTABLE 
			where INVENTTABLE.itemid =  #DATA6.[BOM Item]
			and INVENTTABLE.DATAAREAID = 'RMO'
			and INVENTTABLE.[PARTITION] = 5637144576
	 ) as 'Source'
into #DATA7
FROM #DATA6

SELECT * FROM #DATA7
order by [Shipping Date Rqstd], [Item Id]