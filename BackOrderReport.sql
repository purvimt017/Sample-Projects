


--										Variables
-- ****************************************************************************************************************
declare @fromdate datetime = '04-01-2019'
	,@todate datetime = '08-31-2019'


--										TEMP Table
-- *********************************************************************************************************************

IF OBJECT_ID('tempdb..#DATA') IS NOT NULL DROP TABLE #DATA

Select distinct i.ITEMID AS 'Item Id'
	,min(sl.salesid) as 'Oldest SO'
	,min(it.SHIPPINGDATEREQUESTED) as 'Shipping Date Rqstd'

--                                           Sales Name
-- ***************************************************************************************************************** 
	,(select top 1 DELIVERYNAME 
		from SALESTABLE -- WITH (NOLOCK)
		where SALESID = min(sl.salesid) 
		and SALESTABLE.DATAAREAID = 'rmo' 
		and SALESTABLE.[PARTITION] = 5637144576)  as 'Name'

--                                           In QA/eng
-- ******************************************************************************************************************* 

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
			where s.ITEMID = i.ITEMID
			and s.DATAAREAID = 'rmo'
			and s.[PARTITION] = 5637144576) as 'In QA/Eng' 

--                                           OnHand
-- ********************************************************************************************************************
	,(select item.OnHand 
		from BusinessIntelligence.dbo.ItemExtendedView item  --WITH (NOLOCK)
		where item.ItemId = i.ITEMID 
		and item.DataAreaId = 'rmo' 
		and item.[Partition] = 5637144576) as 'On Hand' 

--                                           SO Remain Qty
-- *******************************************************************************************************************
	,((select SUM(qtyordered)
			from SALESLINE --WITH (NOLOCK)
			where salesid = min(sl.salesid)
				and ITEMID = sl.itemid
				and SALESLINE.DATAAREAID = 'rmo'
				and SALESLINE.[PARTITION] = 5637144576) -
	coalesce((select sum(qty)  
			from WMSORDERTRANS w --WITH (NOLOCK)
			join SALESLINE --WITH (NOLOCK)
			on w.INVENTTRANSID = salesline.INVENTTRANSID
			and w.EXPEDITIONSTATUS = 10
			and sl.DATAAREAID = w.DATAAREAID 
			and sl.[PARTITION] = w.[PARTITION]
			where salesline.SALESID = min(sl.salesid)
			and salesline.ITEMID = sl.itemid
			and sl.DATAAREAID = 'rmo'
			and sl.[PARTITION] = 5637144576), 0.00)) *(-1) as 'SO Remain Qty' 

			,(select SUM(qtyordered)
			from SALESLINE --WITH (NOLOCK)
			where salesid = min(sl.salesid)
				and ITEMID = sl.itemid
				and SALESLINE.DATAAREAID = 'rmo'
				and SALESLINE.[PARTITION] = 5637144576) as 'Qty Ordered'
	
	,coalesce((select sum(qty)  
			from WMSORDERTRANS w --WITH (NOLOCK)
			join SALESLINE --WITH (NOLOCK)
			on w.INVENTTRANSID = salesline.INVENTTRANSID
			and w.EXPEDITIONSTATUS = 10
			and sl.DATAAREAID = w.DATAAREAID 
			and sl.[PARTITION] = w.[PARTITION]
			where salesline.SALESID = min(sl.salesid)
			and salesline.ITEMID = sl.itemid
			and sl.DATAAREAID = 'rmo'
			and sl.[PARTITION] = 5637144576), 0.00) as 'Qty Picked' 



--                                           SO Over/Under Qty
-- ******************************************************************************************************************
	
	,(select item.OnHand 
		from BusinessIntelligence.dbo.ItemExtendedView item  --WITH (NOLOCK)
		where item.ItemId = i.ITEMID 
		and item.DataAreaId = 'rmo' 
		and item.[Partition] = 5637144576)  -- onhand
						+ 
	(((select SUM(qtyordered)
			from SALESLINE --WITH (NOLOCK)
			where salesid = min(sl.salesid)
				and ITEMID = sl.itemid
				and SALESLINE.DATAAREAID = 'rmo'
				and SALESLINE.[PARTITION] = 5637144576) -- Qty Ordered
						-
	coalesce((select sum(qty)  
			from WMSORDERTRANS w --WITH (NOLOCK)
			join SALESLINE  --WITH (NOLOCK)
			on w.INVENTTRANSID = salesline.INVENTTRANSID
			and w.EXPEDITIONSTATUS = 10
			and sl.DATAAREAID = w.DATAAREAID 
			and sl.[PARTITION] = w.[PARTITION]
			where salesline.SALESID = min(sl.salesid)
			and salesline.ITEMID = sl.itemid
			and sl.DATAAREAID = 'rmo'
			and sl.[partition] = 5637144576), 0.00))*(-1))  --WMS
	as 'SO Over/Under Qty' 

--                                       Total SO Demand
-- ***********************************************************************************************************
	,(select sum(ONORDER)*-1 
		from INVENTSUM --WITH (NOLOCK)
		where inventsum.ITEMID = i.ITEMID 
		and INVENTSUM.DATAAREAID = 'rmo'
		and inventsum.[PARTITION] = 5637144576) as 'Total SO Demand' 

--										Oldest Pack WO
-- ***********************************************************************************************************
	,(select min(p.PRODID)  
		from PRODTABLE p --WITH (NOLOCK)
		where p.ITEMID = i.itemid
		and p.PRODSTATUS <> 5 
		and p.PRODSTATUS <> 7
		and p.DATAAREAID = 'rmo'
		and p.[PARTITION] = 5637144576) as 'Oldest Pack WO'

--										WO Pack QTY
-- ***********************************************************************************************************
	,(select sum(QTYSCHED) 
		from PRODTABLE  --WITH (NOLOCK)
		where PRODTABLE.ITEMID = i.itemid 
		and prodtable.PRODID = (select min(p.PRODID)  
									from PRODTABLE p --WITH (NOLOCK)
									where p.ITEMID = i.itemid
									and p.PRODSTATUS <> 5 
									and p.PRODSTATUS <> 7
									and p.DATAAREAID = 'rmo'
									and p.[PARTITION] = 5637144576)
		and prodtable.DATAAREAID = 'rmo'
		and prodtable.[PARTITION] = 5637144576) as 'WO Pack Qty'

--										WO Pack Total Qty
-- ************************************************************************************************************
	,(select sum(qtysched) 
		from prodtable --WITH (NOLOCK)
		where prodtable.ITEMID = i.ITEMID 
		and prodtable.PRODSTATUS not in (5,7)
		and prodtable.DATAAREAID = 'rmo'
		and PRODTABLE.[PARTITION] = 5637144576) as 'WO Pack Total Qty'
--										Bom Item
-- ************************************************************************************************************
	,(select top 1 itemid as BomId
		from BOM --WITH (NOLOCK)
		where BOMID = i.ITEMID
		and BOM.DATAAREAID = 'rmo'
		and BOM.[PARTITION] = 5637144576)  as 'BOM Item'

--										BOM in QA/Eng
-- ************************************************************************************************************
	,(select sum(PostedQty + Received - Deducted + Registered - Picked)
			from INVENTSUM s --WITH (NOLOCK)
			inner join INVENTDIM d WITH (NOLOCK)
			on s.INVENTDIMID = d.INVENTDIMID
			and (d.INVENTLOCATIONID = '110'
			or d.INVENTLOCATIONID = '111'
			or d.INVENTLOCATIONID = '113'
			or d.INVENTLOCATIONID like '6*'
			or d.INVENTLOCATIONID like '5*'
			or d.INVENTLOCATIONID like '4*')
			and s.DATAAREAID = d.DATAAREAID
			and s.[PARTITION] = d.[PARTITION]
			where s.ITEMID = (select top 1 itemid as BomId
								from BOM --WITH (NOLOCK)
								where BOMID = i.ITEMID
								and BOM.DATAAREAID = 'rmo'
								and BOM.[PARTITION] = 5637144576)
			and s.DATAAREAID = 'rmo'
			and s.[PARTITION] = 5637144576) as 'BOM in QA/Eng'

--											Bom On Hand
-- ***********************************************************************************************************

	,(select item.OnHand 
		from BusinessIntelligence.dbo.ItemExtendedView item  --WITH (NOLOCK)
		where item.ItemId = (select top 1 itemid as BomId
								from BOM --WITH (NOLOCK)
								where BOMID = i.ITEMID
								and BOM.DATAAREAID = 'rmo'
								and BOM.[PARTITION] = 5637144576) 
		and item.DataAreaId = 'rmo' 
		and item.[Partition] = 5637144576) as 'BOM On Hand'

--											Bom On Order
-- ************************************************************************************************************
	,(select -1*sum(onorder) 
		from INVENTSUM s
		where s.ITEMID =(select top 1 itemid as BomId
								from BOM --WITH (NOLOCK)
								where BOMID = i.ITEMID
								and BOM.DATAAREAID = 'rmo'
								and BOM.[PARTITION] = 5637144576)) as 'BOM On Order'

--											Oldest WO
-- ************************************************************************************************************
	,(select min(p.PRODID)  
		from PRODTABLE p --WITH (NOLOCK)
		where p.ITEMID = (select top 1 itemid as BomId
								from BOM --WITH (NOLOCK)
								where BOMID = i.ITEMID
								and BOM.DATAAREAID = 'rmo'
								and BOM.[PARTITION] = 5637144576)
		and p.PRODSTATUS <> 5 
		and p.PRODSTATUS <> 7
		and p.DATAAREAID = 'rmo'
		and p.[PARTITION] = 5637144576) as 'Oldest WO'

--											WO Status
-- ***************************************************************************************************************
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
		where PRODTABLE.ITEMID = (select top 1 itemid as BomId
									from BOM --WITH (NOLOCK)
									where BOMID = i.ITEMID
									and BOM.DATAAREAID = 'rmo'
									and BOM.[PARTITION] = 5637144576) 
		and prodtable.PRODID = (select min(p.PRODID)  
									from PRODTABLE p --WITH (NOLOCK)
									where p.ITEMID = (select top 1 itemid as BomId
														from BOM --WITH (NOLOCK)
														where BOMID = i.ITEMID
														and BOM.DATAAREAID = 'rmo'
														and BOM.[PARTITION] = 5637144576)
									and p.PRODSTATUS <> 5 
									and p.PRODSTATUS <> 7
									and p.DATAAREAID = 'rmo'
									and p.[PARTITION] = 5637144576)
		and prodtable.DATAAREAID = 'rmo'
		and prodtable.[PARTITION] = 5637144576) as 'WO Status'

--											WO QTY
-- ***************************************************************************************************************
	,(select sum(QTYSCHED) 
		from PRODTABLE  --WITH (NOLOCK)
		where PRODTABLE.ITEMID = (select top 1 itemid as BomId
									from BOM --WITH (NOLOCK)
									where BOMID = i.ITEMID
									and BOM.DATAAREAID = 'rmo'
									and BOM.[PARTITION] = 5637144576) 
		and prodtable.PRODID = (select min(p.PRODID)  
									from PRODTABLE p --WITH (NOLOCK)
									where p.ITEMID = (select top 1 itemid as BomId
														from BOM --WITH (NOLOCK)
														where BOMID = i.ITEMID
														and BOM.DATAAREAID = 'rmo'
														and BOM.[PARTITION] = 5637144576)
									and p.PRODSTATUS <> 5 
									and p.PRODSTATUS <> 7
									and p.DATAAREAID = 'rmo'
									and p.[PARTITION] = 5637144576)
		and prodtable.DATAAREAID = 'rmo'
		and prodtable.[PARTITION] = 5637144576) as 'WO Qty'

--											Total WO QTY
-- ***************************************************************************************************************
	,(select sum(qtysched) 
		from prodtable --WITH (NOLOCK)
		where prodtable.ITEMID = (select top 1 itemid as BomId
														from BOM --WITH (NOLOCK)
														where BOMID = i.ITEMID
														and BOM.DATAAREAID = 'rmo'
														and BOM.[PARTITION] = 5637144576) 
		and prodtable.PRODSTATUS not in (5,7)
		and prodtable.DATAAREAID = 'rmo'
		and PRODTABLE.[PARTITION] = 5637144576) as 'Total WO Qty'
--											WO Next Resource
-- ***************************************************************************************************************
	,(select  concat(max(r.WRKCTRID),concat(' - ', (select rv.ResourceName from businessintelligence.dbo.resourceview rv where r.WRKCTRID = rv.ResourceId)))
				from PRODROUTESCHEDULINGVIEW r
				join PRODTABLE p
				on r.PRODID = (select min(p.PRODID)  
									from PRODTABLE p --WITH (NOLOCK)
									where p.ITEMID = (select top 1 itemid as BomId
															from BOM --WITH (NOLOCK)
															where BOMID = i.ITEMID
															and BOM.DATAAREAID = 'rmo'
															and BOM.[PARTITION] = 5637144576)
															and p.PRODSTATUS <> 5 
															and p.PRODSTATUS <> 7
															and p.DATAAREAID = 'rmo'
															and p.[PARTITION] = 5637144576)
				where p.ITEMID = (select top 1 itemid as BomId
											from BOM --WITH (NOLOCK)
											where BOMID = i.ITEMID
											and BOM.DATAAREAID = 'rmo'
											and BOM.[PARTITION] = 5637144576)
				and r.BACKORDERSTATUS <> 5
				and r.BACKORDERSTATUS <> 3 
				and p.PRODSTATUS <> 5 and p.PRODSTATUS <> 7
				group by r.WRKCTRID, r.OPRID) as 'WO Next Resource'

--											WO Next Operation
-- ***************************************************************************************************************
	,(select concat(max(r.OPRID), concat(' - ' ,(select opr.name from ROUTEOPRTABLE opr where r.OPRID = opr.oprid)))
				from PRODROUTESCHEDULINGVIEW r
				join PRODTABLE p
				on r.PRODID = (select min(p.PRODID)  
									from PRODTABLE p --WITH (NOLOCK)
									where p.ITEMID = (select top 1 itemid as BomId
															from BOM --WITH (NOLOCK)
															where BOMID = i.ITEMID
															and BOM.DATAAREAID = 'rmo'
															and BOM.[PARTITION] = 5637144576)
															and p.PRODSTATUS <> 5 
															and p.PRODSTATUS <> 7
															and p.DATAAREAID = 'rmo'
															and p.[PARTITION] = 5637144576)
				where p.ITEMID = (select top 1 itemid as BomId
											from BOM --WITH (NOLOCK)
											where BOMID = i.ITEMID
											and BOM.DATAAREAID = 'rmo'
											and BOM.[PARTITION] = 5637144576)
				and r.BACKORDERSTATUS <> 5
				and r.BACKORDERSTATUS <> 3 
				and p.PRODSTATUS <> 5 and p.PRODSTATUS <> 7
				group by r.WRKCTRID, r.OPRID) as 'WO Next Operation'

--											Prod Group Name
-- ***************************************************************************************************************
	,(select min(NAME) 
		from PRODGROUP where PRODGROUPID = (select PRODGROUPID
												from INVENTTABLE 
												where INVENTTABLE.itemid =  (select top 1 itemid as BomId
																									from BOM --WITH (NOLOCK)
																									where BOMID = i.ITEMID
																									and BOM.DATAAREAID = 'rmo'
																									and BOM.[PARTITION] = 5637144576)
																									)) as 'Prod Group Name'

--											Source
-- ***************************************************************************************************************
	,(select COMMISSIONGROUPID
			from INVENTTABLE 
			where INVENTTABLE.itemid =  (select top 1 itemid as BomId
												from BOM --WITH (NOLOCK)
												where BOMID = i.ITEMID
												and BOM.DATAAREAID = 'rmo'
												and BOM.[PARTITION] = 5637144576)
	 ) as 'Source'


INTO #DATA
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
	--and i.ITEMID = 'A01432'
group by i.itemid, sl.ITEMID, i.DATAAREAID, i.PARTITION, sl.DATAAREAID, sl.PARTITION
--order by [Shipping Date Rqstd], [Item Id]



select * from #DATA WITH (NOLOCK)
group by [SO Over/Under Qty]
	, [Item Id]
	, [Oldest SO]
	, [Shipping Date Rqstd]
	, Name
	, [In QA/Eng]
	, [On Hand]
	,[SO Remain Qty]
	, [Qty Ordered]
	, [Qty Picked]
	,[Total SO Demand]
	, [Oldest Pack WO]
	, [WO Pack Qty]
	, [WO Pack Total Qty]
	, [BOM Item]
	, [BOM in QA/Eng]
	, [BOM On Hand]
	, [BOM On Order]
	, [Oldest WO]
	, [WO Status]
	, [WO Next Resource]
	, [WO Next Operation]
	, [Prod Group Name]
	, Source
	, [WO Qty]
	, [Total WO Qty]
having [SO Over/Under Qty] < 0
--order by [Shipping Date Rqstd], [Item Id]
 