USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_DeliveryOrderDetailIds]    Script Date: 3/05/2021 14:45:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
,@IsInsuarance						bit = 0
,@CodApp							varchar(200)
,@InsuranceAmount					decimal(12,2)=0
,@IdDeliveryOption					int = 0
,@ReceiverIdSettlement				bigint =0
AS 
BEGIN

	update DeliveryBackOffice.[dbo].[DeliveryOrder] 
	set IdCustomer =
			case 
			when @IdCustomer != 0 
			then @IdCustomer 
			else (select top 1 e.IdCustomer 
				from dbo.Ecommerce e 
				where e.UserKey = @CodApp)
			end 
	, TypeService = @TypeService
	,IndicationsToSendOrigin = @IndicationsOrigin
	, IndicationsToSendDestination = @IndicationsDestination
	,Ticket_Number = @Ticket_Number
	,Sender_Mail = @Sender_Mail
	,IsInsuarance = @IsInsuarance
	,InsuranceAmount = @InsuranceAmount
	,idDeliveryOption =
			case
			when @IdDeliveryOption != 0
			then @IdDeliveryOption
			else NULL 
			end
	,ReceiverIdSettlement = case
			when @ReceiverIdSettlement > 0
			then @ReceiverIdSettlement
			else NULL 
			end
	where Guide_Number = @GuideNumber and Guide_Serie = @GuideSerie;

	select 1;
END