-- Get SSRS Subscriptions
SELECT b.NAME AS JobName
	,a.SubscriptionID
	,e.NAME
	,e.Path
	,d.Description
	,d.LastStatus
	,d.EventType
	,d.LastRunTime
	,b.date_created
	,b.date_modified
FROM ReportServer.dbo.ReportSchedule AS a
INNER JOIN msdb.dbo.sysjobs AS b 
	ON CAST(a.ScheduleID AS SYSNAME) = b.NAME
INNER JOIN ReportServer.dbo.ReportSchedule AS c 
	ON b.NAME = CAST(c.ScheduleID AS SYSNAME)
INNER JOIN ReportServer.dbo.Subscriptions AS d 
	ON c.SubscriptionID = d.SubscriptionID
INNER JOIN ReportServer.dbo.CATALOG AS e 
	ON d.Report_OID = e.ItemID
