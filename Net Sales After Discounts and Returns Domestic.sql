-- Return net sales for domestic customers after discounts were applied by state

IF OBJECT_ID('tempdb..#DATA') IS NOT NULL DROP TABLE #DATA
IF OBJECT_ID('tempdb..#DATA2') IS NOT NULL DROP TABLE #DATA2
IF OBJECT_ID('tempdb..#DATA3') IS NOT NULL DROP TABLE #DATA3
IF OBJECT_ID('tempdb..#DATA4') IS NOT NULL DROP TABLE #DATA4
--get all sales and the associated discounts
select salesid as SalesID
	, CUSTACCOUNT as Customer
	, itemid as ItemId
	, cast(SALESQTY as decimal(18,2)) as Qty
	, cast(SALESPRICE as decimal(18,2)) as OriginalPrice
	, cast(salesprice * salesqty as decimal(18,2)) as OriginalAmount
	, cast(LINEDISC as decimal(18,2)) as LineDisc
	, cast(LINEPERCENT as decimal(18,2)) as Percentageoff
	, cast((100 - LINEPERCENT) as decimal(18,2)) as PercofPrice
	,case
		when LINEPERCENT = 0 
			then cast((SALESPRICE - LINEDISC) as decimal(18,2))
		when (LINEPERCENT > 0 and LINEDISC > 0) 
			then cast((SALESPRICE - LINEDISC)* ((100 - LINEPERCENT) / 100) as decimal(18,2))
		when (LINEPERCENT > 0 and LINEDISC = 0)   
			then cast(SALESPRICE * ((100 - LINEPERCENT) / 100 ) as decimal(18,2))
	end as NewPrice
	,cast(LINEAMOUNT as decimal(18,2)) as ActualAmount 
	,case
		when LINEPERCENT = 0 
			then cast((SALESPRICE - LINEDISC)* SALESQTY as decimal(18,2))
		when (LINEPERCENT > 0 and LINEDISC > 0)
			then cast((SALESPRICE - LINEDISC)* ((100 - LINEPERCENT) / 100) * SALESQTY as decimal(18,2))
		when (LINEPERCENT > 0 and LINEDISC = 0)  
			then cast(SALESPRICE * ((100 - LINEPERCENT) / 100 ) * SALESQTY as decimal(18,2))
	end as ExpectedAmount
	,State
	,INVENTLOCATIONID as Warehouse
	,Case 
		when inventdim.INVENTLOCATIONID = 400
			then 'Return' 
		when inventdim.inventlocationid <> 400
			then 'Not a Return'
	end as 'Return?'
into #DATA
from RMO_PROD.dbo.SALESLINE 
left join CustomerView 
	on CustomerView.CustomerAccount = salesline.CUSTACCOUNT
	and customerview.DATAAREAID = salesline.DATAAREAID
	and customerview.PARTITION = salesline.PARTITION
left join RMO_PROD.dbo.INVENTDIM
	on inventdim.INVENTDIMID = SALESLINE.INVENTDIMID
	and inventdim.DATAAREAID = salesline.DATAAREAID
	and inventdim.PARTITION = salesline.PARTITION
where SALESLINE.DATAAREAID = 'rmo' 
	and salesline.PARTITION = 5637144576 
	and LINEAMOUNT <> 0 
	and year(salesline.CREATEDDATETIME) = 2018
	and customerview.CountryId = 'USA'

--select * from #DATA --where ExpectedAmount <> ActualAmount 

--Aggregate the discounts ans show price change
select *
	,originalamount - ExpectedAmount as Discounts
	,ExpectedAmount - ActualAmount as AdditionalDiscount
	,NewPrice - OriginalPrice as PriceChange
into #DATA2 
from #DATA 

-- Show number of returns and total return amounts by state
select state as State
	,  count(salesid) as 'Returns'
	, sum(actualamount) as 'Return Amount' 
into #DATA3 
from #DATA where [Return?] like 'Return' 
group by State 
order by State

--select * from #DATA3 order by State

-- pull sales, discounts and net sales where transactions are not returns
select State
	, sum(originalamount) as GrossSales
	, sum(Discounts) + sum(AdditionalDiscount)  as TotalDiscounts
	, SUM(actualamount) as NetSales
into #DATA4 
from #DATA2 where [Return?] not like 'Return'
group by State
order by State

-- return gross sales, total discounts, total returns and net sales by state
select #DATA4.State 
	,#DATA4.GrossSales
	,#data4.TotalDiscounts
	, coalesce([Return Amount],0.00) as 'TotalReturns'
	, NetSales + coalesce([Return Amount],0.00) as NetSales 
from #DATA4 
Left JOIN #DATA3
	on #DATA3.State = #DATA4.State
order by #DATA4.State
