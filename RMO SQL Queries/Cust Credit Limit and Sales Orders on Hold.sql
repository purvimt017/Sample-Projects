--Pull Customers with a credit limit and their corresponding Sales Orders that are on hold

select salestable.SALESID
	, salestable.CUSTACCOUNT
	, cast(custtable.CREDITMAX as decimal(18,2)) as CreditLimit
	, case 
			when SALESTABLE.SALESSTATUS = 8 then 'On-Hold'
			else 'Unkown'
			end as SalesStatus
	, cast(sum(SALESLINE.LINEAMOUNT) as decimal(18,2)) as SalesAmount 
from salestable 
inner join SALESLINE 
	on salestable.SALESID = salesline.SALESID 
	and salestable.DATAAREAID = salesline.DATAAREAID --index
	and salestable.PARTITION = salesline.PARTITION --index
inner join CUSTTABLE 
	on SALESTABLE.CUSTACCOUNT = CUSTTABLE.ACCOUNTNUM
	and SALESTABLE.DATAAREAID = CUSTTABLE.DATAAREAID
	and salestable.PARTITION = custtable.PARTITION
where SALESTABLE.SALESSTATUS = 8
	and SALESTABLE.DATAAREAID = 'RMO' --index
	and salestable.PARTITION = 5637144576 --index
group by salestable.SALESID
	, salestable.CUSTACCOUNT
	, CUSTTABLE.CREDITMAX
	, salestable.SALESSTATUS
