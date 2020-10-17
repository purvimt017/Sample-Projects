--Pulling Customer Invoices with Parameters

declare @Customer varchar(20) = '100013' --test customer
	,@Date date = '2019-10-22' --test date

select cast(j.invoicedate as date) as "Invoice Date"
	,t.invoiceid as "Invoice ID"
	,t.SALESID as "Sales ID"
	,l.CUSTACCOUNT as "Cust Account"
	,l.deliveryname as Name
	,l.ITEMID as "Item ID"
	,l.name as "Item Name"
	,cast(t.qty as decimal(18,2)) as QTY
from salestable s
inner join salesline l 
	on l.salesid = s.salesid
	and l.DATAAREAID = s.DATAAREAID --index
	and l.PARTITION = s.PARTITION --index
inner join custinvoicetrans t 
	on t.salesid = l.salesid 
	and t.itemid = l.itemid
	and t.DATAAREAID = l.DATAAREAID
	and t.PARTITION = l.PARTITION
left join custtable c 
	on c.accountnum = s.custaccount
	and c.DATAAREAID = s.DATAAREAID
	and c.PARTITION = s.PARTITION
--left join dirpartytable d 
--	on d.recid = c.party
--	and d.DATAAREA = c.DATAAREAID
--	and d.PARTITION = c.PARTITION
--left join logisticspostaladdress p 
--	on p.recid = s.deliverypostaladdress
--	and p.PARTITION = s.PARTITION
inner join CUSTINVOICEJOUR j 
	on j.SALESID = s.SALESID
	and j.SALESID = t.SALESID
	and j.INVOICEID = t.INVOICEID
	and j.INVOICEDATE = t.INVOICEDATE
	and j.NUMBERSEQUENCEGROUP = t.NUMBERSEQUENCEGROUP
	and j.DATAAREAID = s.DATAAREAID
	and j.PARTITION = s.PARTITION
where s.custaccount like @Customer 
	and j.INVOICEDATE = (@Date)
	and l.DATAAREAID = 'RMO' --index
	and l.PARTITION = 5637144576 --index
