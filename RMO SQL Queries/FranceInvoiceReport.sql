--Pull Invoices for France (Customer)
declare @Customer varchar(20) = '100013'
	,@Date date = '2019-10-22'

select j.invoicedate
	,t.invoiceid as "Invoice ID"
	,t.SALESID as "Sales ID"
	,l.CUSTACCOUNT as "Cust Account"
	,l.deliveryname as Name
	,l.ITEMID as "Item ID"
	,l.name as "Item Name"
	,t.qty as QTY
	,l.DATAAREAID
	,s.PARTITION
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
left join dirpartytable d 
	on d.recid = c.party
	and d.DATAAREA = c.DATAAREAID
	and d.PARTITION = c.PARTITION
left join logisticspostaladdress p 
	on p.recid = s.deliverypostaladdress
	and p.PARTITION = s.PARTITION
inner join CUSTINVOICEJOUR j 
	on j.salesid = s.salesid
	and j.DATAAREAID = s.DATAAREAID
	and j.PARTITION = s.PARTITION
where s.custaccount like @Customer 
	and j.INVOICEDATE = (@Date)
	and l.DATAAREAID = 'RMO' --Index
	and l.PARTITION = 5637144576 --index
