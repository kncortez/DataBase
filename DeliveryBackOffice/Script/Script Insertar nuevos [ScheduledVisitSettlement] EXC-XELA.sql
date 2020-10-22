
    INSERT INTO [dbo].[ScheduledVisitSettlement]
    SELECT 
		[IdSettlement], 
		CASE [IdSegmentArea] WHEN 1 THEN 6 WHEN 2 THEN 7 WHEN 3 THEN 8 WHEN 4 THEN 9 WHEN 5 THEN 10 ELSE 1 END  [IdSegmentArea] ,
		'EXC GT-XELA' Comment, 
		[OrderSequence], 
		[ScheduledVisitSunday], 
		[ScheduledVisitMonday], 
		[ScheduledVisitTuesday], 
		[ScheduledVisitWednesday], 
		[ScheduledVisitThursday], 
		[ScheduledVisitFriday], 
		[ScheduledVisitSaturday], 
		[SettScheduleVisitStatus], 
		[TokenCreated], 
		GETDATE(),
		[TokenUpdated], 
		[DateUpdated], 
		4244 IdVisitPointClient
  FROM [DeliveryBackOffice].[dbo].[ScheduledVisitSettlement] vstl