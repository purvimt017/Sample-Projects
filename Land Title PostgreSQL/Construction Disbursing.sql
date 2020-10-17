--Construction Disbursing 
--Get order level data 
with a as(select ov.id
, ov.order_number 
, clo.ts_closed as Close_Date
, clo.loan_amount_as_cents /100 as loan_amount
, clo.fee_as_cents / 100 as fee 
, clo.ts_created as Created_Date
, max(op.name_insured) as lender1
, max(op.name_alternate) as lender2
, max(buy.name_insured)  as buyer1
, max(buy.name_alternate) as buyer2
, max(con.name_insured)  as Contractor1
, max(con.name_alternate) as Contractor2
, max(insp.name_insured)  as insp1
, max(insp.name_alternate) as insp2
, add.address
from construction_loan.order clo 
join "order".version ov on ov.id = clo.id_version 
      and ov.business_division = 'CONSTRUCTION_LOAN'
left join "order".person op on op.id_version = ov.id 
      and op.id_role = 12
left join "order".person buy on buy.id_version = ov.id
     and buy.id_role = 1
left join "order".person con on con.id_version = ov.id
     and buy.id_role = 504
left join "order".person insp on insp.id_version = ov.id
     and buy.id_role = 233
left join (select ol.id, a.address from "order".legal ol join (Select aa.id, 
case 
     when aa.address2 is not null and aa.address2 <> '' then concat(aa.address,', ',aa.address2,', ', aa.city,', ', aa.id_state,', ', aa.id_zip)
     when right(aa.address,1) = ',' then concat(aa.address, aa.city,', ', aa.id_state,', ', aa.id_zip)
     else concat(aa.address,', ', aa.city,', ', aa.id_state,', ', aa.id_zip)
end as Address 
from address.address aa 
join address.county ac 
      on ac.id = aa.id_county) a on a.id = ol.id_address) add on add.id = ov.id_legal
where clo.ts_created > '10-11-2019' 
group by  ov.id 
, ov.order_number
, add.address
, clo.ts_closed
, clo.loan_amount_as_cents
, clo.fee_as_cents
, clo.ts_created)

select a.id as "id_Version"
,a.order_number as "Order Number"
,a.address
,a.Created_Date as "Open Date"
,a.Close_Date as "Close Date"
,a.loan_amount as "Loan Amount"
,a.fee as "Fee"
,case 
     when a.lender1 is null or a.lender1 = '' then a.lender2
     else a.lender1
end as "Lender 1"
--,a.lender2 as "Lender 2"
,case 
     when a.buyer1 is null or a.buyer1 = '' then a.buyer2
     else a.buyer1
end as "Buyer 1"
--,a.Contractor1 as "Contractor 1"
--,a.Contractor2 as "Contractor 2"
--,a.insp1 as "Inspector 1"
--,a.insp2 as "Inspector 2"
, (select count(distinct ar.id) 
	from athena.receipt ar 
	where ar.id_version = a.id) as "Draws"
, (select sum(ar.amount) 
	from athena.receipt ar 
	where ar.id_version = a.id) as "Draws TD" 
,'' as "Loan Balance"
, (select sum(ad.amount) 
	from athena.disbursement ad 
	inner join athena.disb_method adm on adm.id = ad.id_disb_method 
	where (ad.status <> 'V' or ad.status is null) 
		and ad.id_version = a.id 
		and adm.type_disb = 'WIRE') as Deposits
, (select sum(ad.amount) 
	from athena.disbursement ad 
	where (ad.status <> 'V' or ad.status is null) 
		and ad.id_version = a.id) as Disbursements
from a
where a.Created_Date <'02-05-2020 23:15:00' 
	or a.Created_Date > '02-06-2020  12:40:00'



 
	

