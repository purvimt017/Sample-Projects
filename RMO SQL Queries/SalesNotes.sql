--Get notes written by sales reps for Customers

select d.REFRECID
	,d.name
	,d.TYPEID
	,d.NOTES
	,cast(d.CREATEDDATETIME as date) as CreatedDate
	,d.CREATEDBY
	,d.PARTITION 
	,c.SalesGroupId
	,c.CustomerAccount
from DOCUREF d
INNER JOIN BusinessIntelligence.dbo.CustomerView c
	ON c.recid = d.REFRECID
	and c.PARTITION = d.PARTITION --index
where year(CREATEDDATETIME) > 2014
and SalesGroupId is not null
