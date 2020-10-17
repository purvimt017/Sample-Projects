select split_part(wo.unidata_id, '*',1) as "BankID"
	, split_part(wo.unidata_id, '*',2) as "WireNumber"
	, wo.ts_initiator + INTERVAL '1 day' as "Post Date"
	, CONCAT(mu.name_first, ' ',mu.name_last) as "Closer"
	, case 
		when wo.notes is null then wo.further_credit
		else wo.notes
	end as "Comments"
	, ov.order_number as "Order Number"
	, wo.further_credit as "Instructions"
	, ' '  as "Other Wires"
	, ' ' as "Rqst By"
	, CONCAT(muu.name_first, ' ',muu.name_last) as "Requestor"
	, wo.ts_requested as "Rqst Date"
	, wo.ts_requested::timestamp as "Rqst Time"
	, wo.bank_name as "To Bank"
	, wo.payee_name as "To Customer"
	, wo.attention as "To Personnel"
	, es.amount_as_cents
	, wo.ts_initiator as "Wire Date"
	, CONCAT(muuu.name_first, ' ',muuu.name_last) as "Wire User"
	, wo.status as "Status"
	, wo.ts_initiator as "Stat Date"
	, wo.ts_initiator as "Stat Time"
	, wo.status_message as "Stat Message"
	, wo.id_wire_out_batch as "Batch ID"
from accounting.wire_out wo
left join "order".version ov 
    on ov.id = wo.id_version
left join master.team mt 
    on mt.id = ov.id_team
left join master.user_team_role mutr
    on mutr.id_team = mt.id
    and mutr.id_role = 14
    and mutr.is_primary = True
left join master.user mu
    on mu.id = mutr.id_user
left join master.user muu
    on muu.id = wo.id_user_requested
left join accounting.escrow_status es
    on es.id = wo.id_escrow_status
left join master.user muuu
    on muuu.id = wo.id_user_initiator
where wo.unidata_id <> '' 
	and wo.ts_initiator > '12-31-2017'


 
	

