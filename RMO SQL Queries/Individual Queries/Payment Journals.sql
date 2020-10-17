-- Return payment receipts/journals for reporting
declare @fromdate date = '2018-10-22'
	,@todate date = '2019-10-22'

select 
	c.ACCOUNTNUM as Account
	,n.NAME as AccountName
	,t.TXT as Description
	,cast(t.TRANSDATE as date) as Date
	,t.voucher as Voucher
	,t.PAYMREFERENCE as PaymentReference
	,cast(t.AMOUNTCURDEBIT as decimal(18,2)) as Debit
	,cast(t.AMOUNTCURCREDIT as decimal(18,2)) as Credit
	,t.CURRENCYCODE as Currency 
from ledgerjournaltrans t
left join CUSTTRANS c
	on t.CUSTTRANSID = c.RECID
	and t.DATAAREAID = c.DATAAREAID --index
	and t.PARTITION = c.PARTITION --index
left join CUSTTABLE ct
	on ct.ACCOUNTNUM = c.ACCOUNTNUM
	and ct.DATAAREAID = c.DATAAREAID
	and ct.PARTITION = c.[PARTITION]
LEFT JOIN	RMO_PROD.dbo.DirPartyTable N
	ON Ct.PARTY	= N.RECID
	AND	Ct.PARTITION	= N.PARTITION
join LEDGERJOURNALTABLE jt
	on jt.JOURNALNUM = t.JOURNALNUM
	and jt.DATAAREAID = t.DATAAREAID
	and jt.PARTITION = t.PARTITION
where t.DATAAREAID = 'RMO' --index
	and t.PARTITION = 5637144576 --index
	and t.ACCOUNTTYPE = 1
	and t.CANCEL = 0
	and t.TRANSDATE between @fromdate and @todate
	and jt.POSTED = 1
	and jt.JOURNALTYPE = 7
order by t.journalnum, t.transdate, c.ACCOUNTNUM
