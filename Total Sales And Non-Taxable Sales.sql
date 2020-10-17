--Return all sales revenue and tsx exempt sales revenue

IF OBJECT_ID('tempdb..#s1') IS NOT NULL DROP TABLE #s1
IF OBJECT_ID('tempdb..#s2') IS NOT NULL DROP TABLE #s2

select cast(sum(lineamount) as decimal(18,2)) as TotalSales
	, month(CREATEDDATETIME) as Month
	, c.State
	, c.City
into #s1
from RMO_PROD.dbo.SALESLINE s
left join CustomerView c
	on c.CustomerAccount = s.CustAccount
	and c.DATAAREAID = s.DataAreaId --index
	and c.PARTITION = s.Partition --index
where s.DataAreaId = 'RMO' --index
	and s.Partition = 5637144576 --index
	and c.state = 'AL'
	and c.City = 'Birmingham'
	and year(s.CREATEDDATETIME) = 2018
group by MONTH(CREATEDDATETIME), c.State, c.City

select cast(sum(lineamount) as decimal(18,2)) as ExemptSales
	, month(CREATEDDATETIME) as Month
	, c.State
	, c.City
into #s2
from RMO_PROD.dbo.SALESLINE s
left join CustomerView c
	on c.CustomerAccount = s.CustAccount
	and c.DATAAREAID = s.DataAreaId
	and c.PARTITION = s.Partition
where s.DataAreaId = 'RMO'
	and s.Partition = 5637144576
	and c.state = 'AL'
	and c.City = 'Birmingham'
	and year(s.CREATEDDATETIME) = 2018
    --Need filters to filter out taxable items or customers 
group by MONTH(CREATEDDATETIME), c.State, c.City

select * from #s1

select * from #s2

