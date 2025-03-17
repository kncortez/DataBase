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
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
		WHERE
			[DO].[Guide_Serie] = @GuideSerie
			AND
			[DO].[Guide_Number] = @GuideNumber
	)

	DECLARE @GuideServiceType NVARCHAR(3) = @TypeService;

	IF(@OriginGuideSystem IS NULL)
		SET @GuideServiceType = dbo.fn_GetGuideServiceType(@GuideSerie, @GuideNumber, NULL, (CASE WHEN @IdCustomer != 0 THEN @IdCustomer ELSE (SELECT TOP 1 ECM.IdCustomer FROM dbo.Ecommerce ECM WITH(NOLOCK) WHERE ECM.UserKey = @CodApp) END));

	UPDATE DeliveryBackOffice.[dbo].[DeliveryOrder] 
	SET IdCustomer =
			CASE 
			WHEN @IdCustomer != 0 
			THEN @IdCustomer 
			ELSE (SELECT TOP 1 e.IdCustomer 
				FROM dbo.Ecommerce e 
				WHERE e.UserKey = @CodApp)
			END 
	, TypeService = @GuideServiceType
	,IndicationsToSendOrigin = @IndicationsOrigin
	, IndicationsToSendDestination = @IndicationsDestination
	,Ticket_Number = @Ticket_Number
	,Sender_Mail = @Sender_Mail
	,IsInsuarance = @IsInsuarance
	,InsuranceAmount = @InsuranceAmount
	,idDeliveryOption =
			CASE
			WHEN @IdDeliveryOption != 0
			THEN @IdDeliveryOption
			ELSE NULL 
			END
	,ReceiverIdSettlement = CASE
			WHEN @ReceiverIdSettlement > 0
			THEN @ReceiverIdSettlement
			ELSE NULL 
			END
	,SalePipeLineId = CASE
			WHEN @IdSalePipeLine > 0
			THEN @IdSalePipeLine
			ELSE NULL 
			END
	,Receiver_ID = @ReceiverId
	,OriginSenderId = @OriginSenderId
	,IsReturn = @IsReturn
	,OrderUserCreated = @OrderUserCreated
	WHERE Guide_Number = @GuideNumber AND Guide_Serie = @GuideSerie;

	DECLARE @Price DECIMAL(12,2)
	DECLARE @CouponApplied BIT

	SELECT @Price = ISNULL(dr.PriceShippment,0) 
	FROM dbo.DeliveryOrder dr WITH (NOLOCK)
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
	FROM DeliveryBackOffice.dbo.DeliveryOrder
	WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber;
END