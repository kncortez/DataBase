IF OBJECT_ID('sps_DeliveryOrderDetailIds') IS not NULL
BEGIN
 Drop procedure [dbo].[sps_DeliveryOrderDetailIds] 
END
go
CREATE PROCEDURE [dbo].[sps_DeliveryOrderDetailIds]
 @GuideSerie						varchar(2) = 'FD'
,@GuideNumber						int = 0
,@IdCustomer						int = 0 
,@TypeService						varchar(3) = 'EXP'
AS 
BEGIN

	update DeliveryBackOffice.[dbo].[DeliveryOrder] 
	set IdCustomer = case when @IdCustomer <> 0 then @IdCustomer else null end 
	, TypeService = @TypeService
	where Guide_Number = @GuideNumber and Guide_Serie = @GuideSerie;

	select 1;
END 
