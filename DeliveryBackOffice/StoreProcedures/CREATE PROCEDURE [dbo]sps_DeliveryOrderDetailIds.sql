USE DeliveryBackOffice
GO
ALTER PROCEDURE [dbo].[sps_DeliveryOrderDetailIds]
 @GuideSerie						varchar(2) = 'FD'
,@GuideNumber						int = 0
,@IdCustomer						int = 0 
,@TypeService						varchar(3) = 'EXP'
,@IndicationsOrigin					varchar(1500) = ''
,@IndicationsDestination			varchar(1500) = ''
,@Sender_Mail						varchar(200) = ''
,@Ticket_Number						varchar(300) = ''
AS 
BEGIN

	update DeliveryBackOffice.[dbo].[DeliveryOrder] 
	set IdCustomer = case when @IdCustomer <> 0 then @IdCustomer else null end 
	, TypeService = @TypeService
	,IndicationsToSendOrigin = @IndicationsOrigin
	, IndicationsToSendDestination = @IndicationsDestination
	,Ticket_Number = @Ticket_Number
	,Sender_Mail = @Sender_Mail
	where Guide_Number = @GuideNumber and Guide_Serie = @GuideSerie;

	select 1;
END