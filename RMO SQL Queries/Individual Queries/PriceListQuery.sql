--grt Price Lists for Customers
declare @Pricegroup varchar(10) = 'EU1'
	,@dataareaid varchar(5) = 'RMO'
	,@partition varchar(20) = 5637144576;

SELECT 
	 c.LINEDISC
	--,a.itemid
	--,z.name
	--,b.price as 'Cost'
	,c.price as 'Retail'
	--,d.Amount as 'Discount Amount'
	,d.PERCENT1 as 'Percentage Off'
	,c.price * ((100 - d.PERCENT1)/100) as 'Price List Amount'
	--,a.jsrmostatisticsgroup
FROM inventtable as a	WITH (NOLOCK)
INNER JOIN inventtablemodule b 
	ON	a.itemid = b.itemid 
	AND b.moduletype = '0'
	AND a.DATAAREAID = b.DATAAREAID --index
	AND a.PARTITION = b.PARTITION --index
INNER JOIN inventtablemodule c	WITH (NOLOCK) 
	ON	a.itemid = c.itemid 
	AND c.moduletype = '2'
	AND a.DATAAREAID = c.DATAAREAID
	AND a.PARTITION = c.PARTITION
INNER JOIN PriceDiscTable d	WITH (NOLOCK) 
	ON	c.linedisc = d.itemrelation 
	AND d.accountrelation = (@PriceGroup) 
	AND (todate >= getdate() OR year(todate) = 1900)
	AND a.DATAAREAID = d.DATAAREAID
	AND a.PARTITION = d.PARTITION
INNER JOIN ECORESPRODUCTTRANSLATION z	WITH (NOLOCK) 
	ON	a.Product = z.Product --AX 2012 Conversion
	--AND a.DATAAREAID = z sp_helpindex ECORESPRODUCTTRANSLATION
	AND a.PARTITION = z.PARTITION
INNER JOIN InventItemGroupItem y	WITH (NOLOCK) 
	ON a.itemid = y.itemid
	AND a.DATAAREAID = y.ITEMDATAAREAID --sp_helpindex InventItemGroupItem
	AND a.PARTITION = y.PARTITION
WHERE	NOT (y.itemgroupid like 'ZZ%')
	and	a.DATAAREAID = @dataareaid --index
	AND a.PARTITION = @partition --index
	and d.TODATE = ''
group by c.LINEDISC, c.PRICE, PERCENT1
--ORDER BY a.itemid
