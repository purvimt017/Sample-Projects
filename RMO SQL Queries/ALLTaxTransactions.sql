--Pulling tax transactions

select ci.InvoiceId 
	,Voucher
	,ci.SalesId
	,ci.OrderAccount
	,ci.InvoiceAccount
	,cast(TRANSDATE as date) as TransDate
	,tt.INVENTTRANSID
	,io.ITEMID
	,TAXCODE
	,cast((TAXBASEAMOUNT*-1) as decimal(18,2)) as TaxBaseAmount 
	,cast((ci.LineAmount) as decimal(18,2)) as LineAmount
	,cast((TAXAMOUNT*-1) as decimal(18,2)) as TaxAmount
	,cast(((taxamount) / nullif((taxbaseamount), 0 )) * 100 as decimal(18,2)) as TaxRate
	--,tt.tax
	, TAXPERIOD 
	,ci.TaxItemGroup
	,ci.TaxGroup
	, i.ItemGroupId
	, i.ItemSalesTaxGroup
	,case 
		when (tt.TAXAMOUNT) <> 0 then 'Taxed'
		when (tt.TAXAMOUNT) = 0 then 'Not Taxed'
	end as Taxed
	, i.TAXITEMGROUPID
	,dst.State
from TAXTRANS tt
inner join INVENTTRANSORIGIN io
	on io.INVENTTRANSID = tt.INVENTTRANSID
	and io.DATAAREAID = tt.DATAAREAID -- index
	and io.PARTITION = tt.PARTITION --index
left join BusinessIntelligence.dbo.CustInvoiceDetailsViewNEW ci
	on ci.ledgervoucher = VOUCHER
	and ci.InvoiceDate = TRANSDATE
	and ci.ItemId = io.ITEMID
	and ci.DATAAREAID = io.DATAAREAID
	and ci.PARTITION = io.PARTITION
left join BusinessIntelligence.dbo.ItemExtendedView i 
	on io.ITEMID = i.ITEMID
	and io.DATAAREAID = i.DataAreaId
	and io.PARTITION = i.Partition
left join [BusinessIntelligence].[dbo].[CustomerView]	DST
	ON	ci.OrderAccount		= DST.CustomerAccount
where tt.DATAAREAID = 'RMO' --index
 and tt.PARTITION = 5637144576 --index
 and year(TRANSDATE) > 2018
 --voucher = 'ARINVV_485993'
 and dst.[tax exempt] = 'No'
--group by dst.State, ci.TaxGroup, itemsalestaxgroup
--order by InvoiceDate
