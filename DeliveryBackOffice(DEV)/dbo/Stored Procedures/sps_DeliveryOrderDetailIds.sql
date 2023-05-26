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
		SET @GuideServiceType = dbo.fn_GetGuideServiceType(@GuideSerie, @GuideNumber, @TypeService, (CASE WHEN @IdCustomer != 0 THEN @IdCustomer ELSE (SELECT TOP 1 ECM.IdCustomer FROM dbo.Ecommerce ECM WITH(NOLOCK) WHERE ECM.UserKey = @CodApp) END));

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

	SELECT @Price = ISNULL(dr.PriceShippment,0) FROM dbo.DeliveryOrder dr
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
-------------------------------------------SEGMENT------------------
		DECLARE @Customer INT = 0;
		DECLARE @CustomerType INT = 0;

		SET @Customer =
			CASE 
			WHEN @IdCustomer != 0 
			THEN @IdCustomer 
			ELSE (SELECT TOP 1 ec.IdCustomer 
				FROM dbo.Ecommerce ec WITH (NOLOCK)
				WHERE ec.UserKey = @CodApp)
			END 

		SET @CustomerType = (SELECT IdCustomerType FROM Customer WITH (NOLOCK)
								     WHERE IdCustomer = @IdCustomer)


					DECLARE @TownSenderID INT;
		DECLARE @TownDestinyID INT;
		DECLARE @SegmentGuide Varchar(5);

		IF(@CustomerType = 1)
			BEGIN
				SET @TownSenderID = (SELECT TWS.IdTownship FROM DeliveryOrder DOR WITH(NOLOCK)
				INNER JOIN Township TWS WITH(NOLOCK)
				ON DOR.Sender_Town = TWS.TownshipName )

				SET @TownDestinyID = (SELECT TWS.IdTownship  FROM DeliveryOrder DOR WITH(NOLOCK)
				INNER JOIN Township TWS WITH(NOLOCK)
				ON DOR.Receiver_Town = TWS.TownshipName )

				SET @SegmentGuide =  (SELECT TOP 1 Crs.CrsShortName FROM CorporateTownshipCoverage ctc WITH(NOLOCK)
				INNER JOIN CatRateSegment crs WITH(NOLOCK)
				ON ctc.SegmentTypeId = crs.CrsId
				WHERE  ctc.TownshipSourceId = @TownSenderID
				AND ctc.TownshipDestinyId = @TownDestinyID)
				      IF (@SegmentGuide != NULL)
							BEGIN
								UPDATE do
								SET do.Segment = @SegmentGuide
								FROM DeliveryOrder do WITH(NOLOCK)
								WHERE do.Guide_Number = @GuideNumber
								AND do.Guide_Serie = @GuideSerie

							END
					 ELSE
							BEGIN
								UPDATE do
								SET do.Segment = 'FOR'
								FROM DeliveryOrder do WITH(NOLOCK)
								WHERE Guide_Number = @GuideNumber
								AND Guide_Serie = @GuideSerie
							END
		  END
		ELSE
			BEGIN
			DECLARE @TariffId INT = 0; 
			SET @TariffId = (SELECT TOP 1 RbcIdRate FROM RatebyCustomer WITH(NOLOCK) WHERE RbcIdCustomer = @IdCustomer AND RbcRowStatus = 1)

				
				SET @TownSenderID = (SELECT TWS.IdTownship FROM DeliveryOrder DOR WITH(NOLOCK)
				INNER JOIN Township TWS WITH(NOLOCK)
				ON DOR.Sender_Town = TWS.TownshipName )

				SET @TownDestinyID = (SELECT TWS.IdTownship  FROM DeliveryOrder DOR WITH(NOLOCK)
				INNER JOIN Township TWS WITH(NOLOCK)
				ON DOR.Receiver_Town = TWS.TownshipName )

				SET @SegmentGuide =  (SELECT TOP 1 Crs.CrsShortName FROM RateTownshipCoverage rtc WITH(NOLOCK)
				INNER JOIN CatRateSegment crs WITH(NOLOCK)
				ON rtc.SegmentTypeId = crs.CrsId
				WHERE RateId = @TariffId
				AND rtc.TownshipSourceId = @TownSenderID
				AND rtc.TownshipDestinyId = @TownDestinyID)


					IF (@SegmentGuide != NULL)
							BEGIN
								UPDATE do
								SET do.Segment = @SegmentGuide
								FROM DeliveryOrder do WITH(NOLOCK)
								WHERE do.Guide_Number = @GuideNumber
								AND do.Guide_Serie = @GuideSerie;

							END

					   ELSE
							BEGIN
								UPDATE do
								SET do.Segment = 'FOR'
								FROM DeliveryOrder do WITH(NOLOCK)
								WHERE do.Guide_Number = @GuideNumber
								AND do.Guide_Serie = @GuideSerie;
							END


			END
		



--------------------------FIN SEGMENTO---------------



		
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
					@UseMembership = @UseMembership
	--END

	select 1,
		ISNULL(@GuideServiceType, 'STD') [GuideServiceType];
END