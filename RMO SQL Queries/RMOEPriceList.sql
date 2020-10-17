-- Get Price List For Europe Customer Group

SELECT g.GROUPID
	, g.NAME
	, t.ITEMRELATION
	, cast(t.FROMDATE as date) as FromDate
	--, t.TODATE
	--, t.AMOUNT as Discount
	, i.Price as ItemPrice
from PRICEDISCGROUP g
INNER JOIN PRICEDISCTABLE t
	on g.GROUPID = t.ACCOUNTRELATION
Left JOIN BusinessIntelligence.dbo.ItemExtendedView i 
	on i.ItemId = t.ITEMRELATION
where GROUPID in ('EU1', 'EU2') 
	and type = 0
	and TODATE = ''
	and i.Price is null
group by g.GROUPID,g.NAME, t.ITEMRELATION,i.Price, t.FROMDATE, t.TODATE, t.AMOUNT

