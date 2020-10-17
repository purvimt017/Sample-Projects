--Underwriter Report
--Get Endorsements by Product
with c as (select ap.id_version
	,app.id_product
	, sum(ap.premium) as Endorsements
from apollo.product ap 
join apollo.product app 
      on ap.id_related_product = app.id 
where ap.id_endorsement is not null 
      and ap.id_invoice is not null 
group by ap.id_version, app.id_product)

--Get Invoice and Policy Data for Underwriter Report
select invoice_number
	, invoice_date
	, date_effect
	, coverage 
	, underwriter_number
	, premium
	, ap.id_product
	, ap.id_version
	, c.endorsements
from apollo.product ap
join c on c.id_version = ap.id_version
	and c.id_product = ap.id_product
join apollo.invoice ai on ai.id = ap.id_invoice


 
	

