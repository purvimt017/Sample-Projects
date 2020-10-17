--Get Loan Disbursements
Select ov.order_number
, sum(amount) as disbursed
, ts_paid as date_checks_sent
, ts_paid as date_close
from athena.disbursement ad 
inner join "order".version ov on ov.id = ad.id_version
     and ov.business_division = 'CONSTRUCTION_LOAN'
inner join construction_loan."order" clo on clo.id_version = ov.id 
     and ov.business_division = 'CONSTRUCTION_LOAN'
where ov.order_number = '55071359CL'  --TEST CASE
	and ad.status <> 'V'
group by ov.order_number
	, ts_paid
order by ts_paid



 
	

