-- =============================================
-- Author:		<Oscar Rodriguez>
-- Create date: <Update date,2025-04-28>
-- Description:	<Se agrega codigo de ruta para manejar en impresion de guias en metodo de creacion de guias api core>
-- =============================================
CREATE PROCEDURE [dbo].[sps_DeliveryOrderDetailIds]
 @GuideSerie						varchar(2) = 'FD'
,@GuideNumber						int = 0
,@IdCustomer						int = 0 
,@TypeService						varchar(4) = NULL
,@IndicationsOrigin					varchar(1500) = ''
,@IndicationsDestination			varchar(1500) = ''
,@Sender_Mail						varchar(200) = ''
,@Ticket_Number						varchar(300) = ''
,@IsInsuarance						bit = 0
,@CodApp							varchar(200)
,@InsuranceAmount					decimal(12,2)=0
,@IdDeliveryOption					int = 0
,@ReceiverIdSettlement				bigint =0
,@IdSalePipeLine					int = 0
,@ReceiverId						int = 0
,@OriginSenderId					int = 0
,@IsReturn							bit = 0
,@IsCreditCardPayment				bit = 0
,@OrderUserCreated                  varchar(100) = ''
,@UseMembership bit=0
,@CategoryProductId int = 0
,@ProductId int = 0
AS 
BEGIN

	DECLARE @OriginGuideSystem INT = 
	(
		SELECT 
			TOP (1) 
				[DO].[CatSystemId] 
		FROM 
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) 
		WHERE
			[DO].[Guide_Serie] = @GuideSerie
			AND
			[DO].[Guide_Number] = @GuideNumber
	)

	DECLARE @GuideServiceType NVARCHAR(3) = @TypeService;

	IF(@OriginGuideSystem IS NULL)
		SET @GuideServiceType = dbo.fn_GetGuideServiceType(@GuideSerie, @GuideNumber, NULL, (CASE WHEN @IdCustomer != 0 THEN @IdCustomer ELSE (SELECT TOP 1 ECM.IdCustomer FROM dbo.Ecommerce ECM WITH(NOLOCK) WHERE ECM.UserKey = @CodApp) END));

	update DeliveryBackOffice.[dbo].[DeliveryOrder] 
	set IdCustomer =
			case 
			when @IdCustomer != 0 
			then @IdCustomer 
			else (select top 1 e.IdCustomer 
				from dbo.Ecommerce e 
				where e.UserKey = @CodApp)
			end 
	, TypeService = @GuideServiceType
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
	,SalePipeLineId = case
			when @IdSalePipeLine > 0
			then @IdSalePipeLine
			else NULL 
			end
	,Receiver_ID = @ReceiverId
	,OriginSenderId = @OriginSenderId
	,IsReturn = @IsReturn
	,OrderUserCreated = @OrderUserCreated
	where Guide_Number = @GuideNumber and Guide_Serie = @GuideSerie;

	DECLARE @Price DECIMAL(12,2)
	DECLARE @CouponApplied BIT

	SELECT @Price = ISNULL(dr.PriceShippment,0) FROM dbo.DeliveryOrder dr WITH(NOLOCK) 
	WHERE dr.Guide_Serie = @GuideSerie AND dr.Guide_Number =@GuideNumber

	SET @CouponApplied = ISNULL((
	SELECT
		TOP 1
			1
	FROM
		[DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH(NOLOCK)
	WHERE
		PC.GuideSerieDestination = @GuideSerie
		AND
		PC.GuideNumberDestination = @GuideNumber
		AND
		PC.FinalActiveDate >= GETDATE()
		AND
		PC.RowStatus = 1), 0)

		
	DECLARE @RC INT;
	--SE COMENTA PARA CÁLCULAR MEMBRESÍAS
	--IF @Price =0 AND @CouponApplied = 0 
	--BEGIN
		EXECUTE @RC = DeliveryBackOffice.dbo.spws_revalue_guide
					@GuideSerie = @GuideSerie,
					@GuideNumber = @GuideNumber,
					@CodeApp = '',
					@Format = 'Non',
					@CalculateTaxes = 'true',
					@IdModule = 33,
					@SetUpdate = 'true',
					@Token = 'sps_DeliveryOrderDetailIds',
					@IsReturn = 'false',
					@ParIsCreditCard = @IsCreditCardPayment,
					@UseMembership = @UseMembership,
					@CategoryProductId = @CategoryProductId,
					@ProductId = @ProductId
	--END

	select 1,
		ISNULL(@GuideServiceType, 'STD') [GuideServiceType]
		, PriceShippment
		, ISNULL(CAST(DSC.RouteCode AS varchar),'') [Route_Code]
	FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
    LEFT JOIN DumpServiceCoverage DSC WITH(NOLOCK)
        ON DSC.IdSettlement = do.ReceiverIdSettlement 
    LEFT JOIN Settlement s WITH(NOLOCK)
        ON DSC.IdSettlement = s.IdSettlement
	WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND s.SettlementSatus = 1;

END