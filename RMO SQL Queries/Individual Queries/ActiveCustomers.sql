-- Simple query pulling active customers

IF OBJECT_ID('tempdb..#c') IS NOT NULL DROP TABLE #c

Select distinct c.CustomerAccount
	, c.CustomerName
	, c.CustomerRegion
	, c.Street + ', ' + c.City + ', ' + c.State + ', ' + c.ZipCode + ', ' + CountryId as Address
	, c.phone as PhoneNumber  
	,c.AccountStatus
into #c
from CustomerView c
where CustomerName not like '%Sample Acct%' and CustomerName not like '%Sample%'
	and c.AccountStatus <> 'Account Closed'

select * from #c where address not like '%Sample Acct%'
