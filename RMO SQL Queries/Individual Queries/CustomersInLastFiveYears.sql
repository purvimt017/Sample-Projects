--Getting list of Customers with Sales in the past 5 years

Select count(*) as NumberofPurchases
	, CustAccount
	, SalesName
	, c.Street + ', ' + c.City + ', ' + c.State + ', ' + c.ZipCode + ', ' + CountryId as Address
	, c.phone as PhoneNumber
	, min(invoicedate) as FirstPurchase
	, max(invoicedate) as LastPurchase  
from SalesOrderView s
Left JOIN CustomerView c
	on c.CustomerAccount = s.CustAccount
where InvoiceDate > '01-01-2014' 
	AND SalesName not like '%Sample Acct%'
group by CustAccount
	, SalesName
	, c.Street
	, c.City
	, c.State
	, c.ZipCode
	, c.CountryId
	, c.phone
