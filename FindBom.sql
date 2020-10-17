--Find Billing of Material (BOM) of Item with Parameters
declare @fromdate datetime = '04-01-2019'
	,@todate datetime = '08-31-2019'
	,@itemid varchar(50) = 'A07011-A'

select top 1 itemid as BomId
from BOM
where BOMID = @itemid
