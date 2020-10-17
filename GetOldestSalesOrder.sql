--Find Oldest Sales Order for an Item

declare @fromdate datetime = '04-01-2019'
	,@todate datetime = '08-31-2019'
	,@itemid varchar(50) = 'KQ12402'

Select --sl.ITEMID
	top 1 s.SALESID
	, s.DELIVERYNAME
from salestable s
inner join SALESLINE sl
	on sl.SALESID = s.SALESID
	and sl.DATAAREAID = s.DATAAREAID --index
	and sl.PARTITION = s.PARTITION --index
Inner Join INVENTTRANS i 
	on i.SHIPPINGDATEREQUESTED = s.SHIPPINGDATEREQUESTED
	and i.DATAAREAID = s.DATAAREAID
	and i.PARTITION = s.PARTITION
Inner join INVENTTRANSORIGIN io
	on io.ITEMID = i.ITEMID
	and sl.INVENTTRANSID = io.INVENTTRANSID
	and io.RECID = i.INVENTTRANSORIGIN
	and io.DATAAREAID = s.DATAAREAID
	and io.PARTITION = s.PARTITION
where i.SHIPPINGDATEREQUESTED >= @fromdate
	AND i.SHIPPINGDATEREQUESTED <= @todate
	AND (i.STATUSISSUE = 6 or i.STATUSISSUE = 5)
	and i.ITEMID = @itemid
	and i.DATAAREAID = 'RMO' --index
	and i.PARTITION = 5637144576 --index
group by s.salesid
	, s.DELIVERYNAME

