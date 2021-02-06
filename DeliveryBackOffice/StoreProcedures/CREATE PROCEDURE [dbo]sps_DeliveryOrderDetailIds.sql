USE DeliveryBackOffice
GO
CREATE PROCEDURE [dbo].[sps_DeliveryOrderDetailIds]
 @GuideSerie						varchar(2) = 'FD'
,@GuideNumber						int = 0
,@IdCustomer						int = 0 
,@TypeService						varchar(3) = 'EXP'
,@IndicationsOrigin					varchar(1500) = ''
,@IndicationsDestination			varchar(1500) = ''
AS 
BEGIN

	update DeliveryBackOffice.[dbo].[DeliveryOrder] 
	set IdCustomer = case when @IdCustomer <> 0 then @IdCustomer else null end 
	, TypeService = @TypeService
	,IndicationsToSendOrigin = @IndicationsOrigin
	, IndicationsToSendDestination = @IndicationsDestination
	where Guide_Number = @GuideNumber and Guide_Serie = @GuideSerie;

	select 1;
END
