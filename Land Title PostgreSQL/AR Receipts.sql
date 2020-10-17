--Grab AR Receipts
Select ar.id as "ID"
,(Select min(ts_paid) from athena.disbursement sad 
  inner join "order".version sov 
     on sov.id = sad.id_version
     and sov.business_division = 'CONSTRUCTION_LOAN'
  inner join construction_loan."order" sclo
     on sclo.id_version = sov.id 
     and sov.business_division = 'CONSTRUCTION_LOAN'
  where sov.order_number = ov.order_number 
     and sad.status <> 'V' 
     and sad.ts_paid >= ts_arrived_for_accounting + interval '-1 day'
     ) as "DATE_CHECKS_SENT"
, ts_arrived_for_accounting as "DATE_FUNDS_RECVD"
, sum(amount) as "DRAW AMOUNT"
,(Select count(distinct sar.id) 
  from athena.receipt sar 
  inner join "order".version ssov 
     on ssov.id = sar.id_version
     and ssov.business_division = 'CONSTRUCTION_LOAN'
  inner join construction_loan."order" ssclo
     on ssclo.id_version = ssov.id 
     and ssov.business_division = 'CONSTRUCTION_LOAN'
  where ssov.order_number = ov.order_number
     and sar.ts_arrived_for_accounting <= ar.ts_arrived_for_accounting
     )  as "DRAW_NO"
,clo.loan_amount_as_cents /100 as "LOAN_AMOUNT"
,order_number as "ORDER_NUMBER"
,clo.fee_as_cents / 100  as "LOAN_FEE"
from athena.receipt ar
inner join "order".version ov on ov.id = ar.id_version
	and ov.business_division = 'CONSTRUCTION_LOAN'
inner join construction_loan."order" clo on clo.id_version = ov.id 
	and ov.business_division = 'CONSTRUCTION_LOAN'
group by ar.id, order_number
	, ts_arrived_for_accounting
	, clo.loan_amount_as_cents
	, clo.fee_as_cents 
order by ts_arrived_for_accounting



 
	

