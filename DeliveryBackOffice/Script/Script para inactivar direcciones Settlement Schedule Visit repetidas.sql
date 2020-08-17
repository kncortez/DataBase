USE [DeliveryBackOffice]
GO

update Settlement 
set SettlementSatus = 'FALSE',
TokenUpdated = 'SYS-ERAMIREZ',
DateUpdated = GETDATE()
where IdSettlement IN (814, 819,822,858,558,657)


UPDATE [dbo].[ScheduledVisitSettlement]
   SET [SettScheduleVisitStatus] = 'FALSE'
      ,[TokenUpdated] = 'SYS-ERAMIREZ'
      ,[DateUpdated] = GETDATE()
 WHERE IdSettScheduleVisit IN (814, 819,822,858, 558,657)
 and IdSettlement IN (814, 819,822,858,558,657)

GO


