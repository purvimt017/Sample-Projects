--Get Retail Pricing for Products
DECLARE @TYPE varchar(25) = 'PREWELD'
	,@threshold decimal(18,4) = 0.0001

IF @TYPE = 'PREWELD' --different process for prewelds
BEGIN
	SELECT			 a.LINEDISC				AS LINEDISCOUNTGROUP
					,a.ITEMID
					,y.ITEMGROUPID
					,z.NAME
					,cast(a.PRICE as decimal(18,4)) as PRICE
					,cast((	SELECT TOP 1 p.PRICE FROM INVENTTABLEMODULE p
											INNER JOIN		INVENTTABLE AS i
												ON	p.ITEMID = i.ITEMID 
												AND p.DATAAREAID = i.DATAAREAID
												AND p.PARTITION = i.PARTITION
											INNER JOIN		INVENTITEMGROUPITEM AS G -- SP_HELPINDEX INVENTITEMGROUPITEM
												ON	i.ITEMID = G.ITEMID
												AND i.DATAAREAID = G.ITEMDATAAREAID
												AND i.PARTITION = G.PARTITION
												AND G.ITEMGROUPID <> 'ZZZ'
						WHERE	p.LINEDISC = a.LINEDISC 
							AND p.DATAAREAID = a.DATAAREAID
							AND p.PARTITION = a.PARTITION
							AND p.MODULETYPE = a.MODULETYPE
							ORDER BY p.ITEMID DESC) as decimal(18,4)) FIRSTPRICE
					,a.UNITID
					,b.JSRMOSTATISTICSGROUP
					,a.PARTITION
	FROM            INVENTTABLEMODULE AS a 
	INNER JOIN		INVENTTABLE AS b 
				ON	a.ITEMID = b.ITEMID 
				AND a.DATAAREAID = b.DATAAREAID
				AND a.PARTITION = b.PARTITION
	INNER JOIN		ECORESPRODUCTTRANSLATION AS z 
				ON	b.PRODUCT = z.PRODUCT 
				AND b.PARTITION = z.PARTITION
				AND z.LANGUAGEID = 'en-us'
	INNER JOIN		INVENTITEMGROUPITEM AS y -- SP_HELPINDEX INVENTITEMGROUPITEM
				ON	b.ITEMID = y.ITEMID
				AND b.DATAAREAID = y.ITEMDATAAREAID
				AND b.PARTITION = y.PARTITION
	WHERE       a.DATAAREAID = 'RMO'
			AND a.PARTITION = 5637144576 
			AND a.MODULETYPE = '2' 
			AND y.ITEMGROUPID <> 'ZZZ'
			AND LEFT(a.LINEDISC, 2) = 'PW' 
			AND a.PRICE > @THRESHOLD
END
ELSE
BEGIN
	SELECT			 a.LINEDISC				AS LINEDISCOUNTGROUP
					,a.ITEMID
					,y.ITEMGROUPID
					,z.NAME
					,cast(a.PRICE as decimal(18,4)) as PRICE
					,cast((	SELECT TOP 1 p.PRICE FROM INVENTTABLEMODULE p
											INNER JOIN		INVENTTABLE AS i
												ON	p.ITEMID = i.ITEMID 
												AND p.DATAAREAID = i.DATAAREAID
												AND p.PARTITION = i.PARTITION
											INNER JOIN		INVENTITEMGROUPITEM AS G -- SP_HELPINDEX INVENTITEMGROUPITEM
												ON	i.ITEMID = G.ITEMID
												AND i.DATAAREAID = G.ITEMDATAAREAID
												AND i.PARTITION = G.PARTITION
												AND G.ITEMGROUPID <> 'ZZZ'
						WHERE	p.LINEDISC = a.LINEDISC 
							AND p.DATAAREAID = a.DATAAREAID
							AND p.PARTITION = a.PARTITION
							AND p.MODULETYPE = a.MODULETYPE
							ORDER BY p.ITEMID) as decimal(18,4)) FIRSTPRICE
					,a.UNITID
					,b.JSRMOSTATISTICSGROUP
					,a.PARTITION
	FROM            INVENTTABLEMODULE AS a 
	INNER JOIN		INVENTTABLE AS b 
				ON	a.ITEMID = b.ITEMID 
				AND a.DATAAREAID = b.DATAAREAID
				AND a.PARTITION = b.PARTITION
	INNER JOIN		ECORESPRODUCTTRANSLATION AS z 
				ON	b.PRODUCT = z.PRODUCT 
				AND b.PARTITION = z.PARTITION
				AND z.LANGUAGEID = 'en-us'
	INNER JOIN		INVENTITEMGROUPITEM AS y -- SP_HELPINDEX INVENTITEMGROUPITEM
				ON	b.ITEMID = y.ITEMID
				AND b.DATAAREAID = y.ITEMDATAAREAID
				AND b.PARTITION = y.PARTITION
	WHERE       a.DATAAREAID = 'RMO'
			AND a.PARTITION = 5637144576 
			AND a.MODULETYPE = '2' 
			AND y.ITEMGROUPID <> 'ZZZ'
			AND LEFT(a.LINEDISC, 2) <> 'PW' 
			AND a.PRICE >@THRESHOLD
END