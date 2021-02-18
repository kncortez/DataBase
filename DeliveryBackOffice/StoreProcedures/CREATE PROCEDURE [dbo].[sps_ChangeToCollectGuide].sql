use DeliveryBackOffice
go
CREATE PROCEDURE [dbo].[sps_ChangeToCollectGuide]
 @GuideSerie						varchar(2) = 'FD'
,@GuideNumber						int = 0
,@isCollect							bit = 0
AS 
BEGIN

	update DeliveryBackOffice.[dbo].[DeliveryOrder] 
	set IsCollect = @isCollect 
	where Guide_Number = @GuideNumber and Guide_Serie = @GuideSerie;
	select 1;
END
