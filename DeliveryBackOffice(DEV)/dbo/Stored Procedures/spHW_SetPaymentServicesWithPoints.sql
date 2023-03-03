-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <08-02-2023>
-- Description:	<Payment of services with Forza points>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_SetPaymentServicesWithPoints] 
	@AccountId INT = NULL,
	@CustomerId INT = NULL,
	@GuidesList AS TblListGuides READONLY,
	@Token NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @TypeOfInOutMoneyId INT;
	DECLARE @TimePlaId INT;
	DECLARE @ForzaPointsExchangeType NVARCHAR(25) = '';
	DECLARE @ForzaPointsExchangeValue INT = 0;
	DECLARE @CatSalesPackageStatusId INT = 0;
	DECLARE @PointPromoId INT = NULL;
	DECLARE @PointPromoFactor DECIMAL(12,2) = 0;
	DECLARE @AuxPointsToSubstract INT = 0;
	DECLARE @DayName NVARCHAR(20) = '';
	DECLARE @IsValidDay BIT = 0;
	DECLARE @CatPointPromoTbl TABLE (	IdPointPromo INT, 
									PointPromoDescription NVARCHAR(400),
									Monday BIT,
									Tuesday BIT,
									Wednesday BIT,
									Thursday BIT,
									Friday BIT,
									Saturday BIT,
									Sunday BIT,
									PointPromoFactor DECIMAL);
	DECLARE @ValidationForzaPoints TABLE(AvailableForzaPoints INT,
										PointPromoFactor DECIMAL(12,2),
										PointsNeededForExchange INT,
										ProceedWithTransaction BIT,
										PromoDescription NVARCHAR(200), 
										spResult INT,
										spMessage NVARCHAR(200));
	DECLARE @GuidesProcessedList TABLE (GuideSerie NVARCHAR(5),
										GuideNumber INT,
										PriceShipment DECIMAL(12,2),
										CustomerId INT);
	DECLARE @MembershipList TABLE (	MembershipId INT,
									PointsAvailable INT,
									PointsToSubstract INT);

	IF (@AccountId IS NULL AND @CustomerId IS NULL)
		BEGIN
			SELECT 0 [spResult], 'Datos incorrectos para ejecutar la consulta.' [spMessage];
			RETURN;
		END

	SET @TimePlaId = (	SELECT	[CPT].[TimePlaId] 
						FROM	[dbo].[CatPaymentTime] CPT
						WHERE	[CPT].[TimePlaName] = 'Ahora' );

	-- REVALIDAR PUNTOS FORZA
	INSERT INTO @ValidationForzaPoints
	EXEC spHW_ValidateForzaPoints @AccountId, @CustomerId, @GuidesList;

	IF ((SELECT spResult FROM @ValidationForzaPoints) = 0) 
		BEGIN
			SELECT spResult [spResult] ,spMessage [spMessage] FROM @ValidationForzaPoints;
			RETURN;
		END

	IF ((SELECT ProceedWithTransaction FROM @ValidationForzaPoints) = 0)
		BEGIN
			SELECT 0 [spResult] ,'No es posible realizar el canje de puntos porque no cuenta con la cantidad requerida.' [spMessage];
			RETURN;
		END


	BEGIN TRANSACTION
	BEGIN TRY

		SET @ForzaPointsExchangeType = (SELECT  [CP].[Value]
										FROM	[dbo].[ConfigParams] CP
										WHERE	[CP].[Name] = 'ForzaPointsExchangeType');

		SET @ForzaPointsExchangeValue = (SELECT ISNULL([CP].[Value], 0)
										FROM	[dbo].[ConfigParams] CP
										WHERE	[CP].[Name] = 'ForzaPointsExchangeValue');

		SET @CatSalesPackageStatusId = (SELECT	[CSPS].[IdCatSalesPackageStatus]
										FROM	[dbo].[CatSalesPackageStatus] CSPS
										WHERE	[CSPS].[SalesPackageStatusName] = 'Anulada');

		SET @DayName = (SELECT DATENAME(dw, SYSDATETIME()));

		INSERT INTO @CatPointPromoTbl
		SELECT	TOP 1	[CPP].[IdPointPromo],
						[CPP].[PointPromoDescription],
						[CPP].[Monday],
						[CPP].[Tuesday],
						[CPP].[Wednesday],
						[CPP].[Thursday],
						[CPP].[Friday],
						[CPP].[Saturday],
						[CPP].[Sunday],
						[CPP].[PointPromoFactor]
		FROM			[dbo].[CatPointPromo] CPP
		WHERE			[CPP].[RowStatus] = 1
			AND			[CPP].[InPointExchange] = 1
			AND			SYSDATETIME() BETWEEN [CPP].[StartPromoDate] AND [CPP].[FinishPromoDate]
		ORDER BY		[CPP].[PointPromoWeight] DESC;

		SET @IsValidDay =	CASE 
								WHEN @DayName = 'Monday'	THEN (SELECT TOP 1 Monday FROM @CatPointPromoTbl)
								WHEN @DayName = 'Tuesday'	THEN (SELECT TOP 1 Tuesday FROM @CatPointPromoTbl)
								WHEN @DayName = 'Wednesday' THEN (SELECT TOP 1 Wednesday FROM @CatPointPromoTbl)
								WHEN @DayName = 'Thursday'	THEN (SELECT TOP 1 Thursday FROM @CatPointPromoTbl)
								WHEN @DayName = 'Friday'	THEN (SELECT TOP 1 Friday FROM @CatPointPromoTbl)
								WHEN @DayName = 'Saturday'	THEN (SELECT TOP 1 Saturday FROM @CatPointPromoTbl)
								WHEN @DayName = 'Sunday'	THEN (SELECT TOP 1 Sunday FROM @CatPointPromoTbl)
								ELSE 0
							END

		IF(@IsValidDay = 1)
			BEGIN
				SELECT		TOP 1 @PointPromoId = [CPP].[IdPointPromo],
							@PointPromoFactor = [CPP].[PointPromoFactor]
				FROM		[dbo].[CatPointPromo] CPP
				WHERE		[CPP].[InPointExchange] = 1
					AND		[CPP].[RowStatus] = 1
					AND		SYSDATETIME() BETWEEN [CPP].[StartPromoDate] AND [CPP].[FinishPromoDate]
				ORDER BY	[CPP].[PointPromoWeight] DESC;
			END

		INSERT INTO @GuidesProcessedList(GuideSerie, 
										GuideNumber, 
										PriceShipment,
										CustomerId)
		SELECT							[DO].[Guide_Serie],
										[DO].[Guide_Number],
										[DO].[PriceShippment],
										[DO].[IdCustomer]
		FROM							[dbo].[DeliveryOrder] DO WITH(NOLOCK)
		INNER JOIN						@GuidesList GL
			ON							[DO].[Guide_Serie] = [GL].[Guide_Serie]
			AND							[DO].[Guide_Number] = [GL].[Guide_Number]; 

		SET @TypeOfInOutMoneyId = (	SELECT	TOP 1 [TIO].[tio_pk_id] 
									FROM	[dbo].[ctgTypeOfInOutOfMoney] TIO
									WHERE	[TIO].[tio_pk_name] = 'Puntos Forza' );
		
		-- Update DeliveryOrderPaymentDetail 
		UPDATE		[DOPD]
		SET			[DOPD].[TypeofInOutMoneyId] = @TypeOfInOutMoneyId,
					[DOPD].[amount] = [GL].[PriceShipment],
					[DOPD].[TimePlaId] = @TimePlaId,
					[DOPD].[ShipmentCompleted] = 1,
					[DOPD].[TokenUpdated] = @Token,
					[DOPD].[DateUpdated] = SYSDATETIME()
		FROM		[dbo].[DeliveryOrderPaymentDetail] DOPD
		INNER JOIN	@GuidesProcessedList GL
			ON		[DOPD].[GuideSerie] = [GL].[GuideSerie]
			AND		[DOPD].[GuideNumber] = [GL].[GuideNumber];

		-- Update Cost
		UPDATE		[C]
		SET			[C].[TotalAmountPaid] = [GPL].[PriceShipment],
					[C].[PaymentDate] = SYSDATETIME(),
					[C].[TokenUpdated] = @Token,
					[C].[DateUpdated] = SYSDATETIME()
		FROM		[dbo].[Cost] C
		INNER JOIN	@GuidesProcessedList GPL
			ON		[C].[GuideSerie] = [GPL].[GuideSerie]
			AND		[C].[GuideNumber] = [GPL].[GuideNumber];

		-- Insert Cost Detail
		INSERT INTO [dbo].[CostDetail] ([IdCost],
										[IdTypeOfMoney],
										[Amount],
										[RowStatus],
										[TokenCreated],
										[DateCreated])
		SELECT							[C].[IdCost],
										@TypeOfInOutMoneyId,
										[GPL].[PriceShipment],
										1, 
										@Token,
										SYSDATETIME()
		FROM							@GuidesProcessedList GPL
		INNER JOIN						[dbo].[Cost] C
			ON							[GPL].[GuideSerie] = [C].[GuideSerie]
			AND							[GPL].[GuideNumber] = [C].[GuideNumber];

		-- CANJE DE PUNTOS FORZA
		SET @AuxPointsToSubstract = (SELECT TOP 1 PointsNeededForExchange FROM @ValidationForzaPoints);

		-- Get available memberships
		INSERT INTO @MembershipList (	MembershipId,
										PointsAvailable,
										PointsToSubstract)
		SELECT							[M].[IdMembership],
										[M].[AvailablePoints],
										IIF(([M].[AvailablePoints] >= @AuxPointsToSubstract), (@AuxPointsToSubstract - ISNULL((SELECT SUM(PointsToSubstract) FROM	@MembershipList), 0)), [M].[AvailablePoints])
		FROM							[dbo].[Membership] M
		WHERE							[M].[CustomerId] = (SELECT TOP 1 CustomerId FROM @GuidesProcessedList)
			AND							[M].[PointsExpirationDate] >= SYSDATETIME()
			AND							[M].[CatMembershipStatusId] != @CatSalesPackageStatusId
			AND							[M].[AvailablePoints] > 0
			AND							[M].[RowStatus] = 1
		ORDER BY						[M].[ExpirationDate] ASC;

		-- Substract points from memberships
		UPDATE		[M]
		SET			[M].[AvailablePoints] = ([M].[AvailablePoints] - [ML].[PointsToSubstract]),
					[M].[DateUpdated] = SYSDATETIME(),
					[M].[TokenUpdated] = @Token
		FROM		[dbo].[Membership] M
		INNER JOIN	@MembershipList ML
			ON		[M].[IdMembership] = [ML].[MembershipId];

		-- Insert in Points By Service Log
		INSERT INTO [dbo].[PointsByServiceLog] ([MembershipId],
												[GuideSerie],
												[GuideNumber],
												[GuidePrice],
												[PointsConsumed],
												[RowStatus],
												[DateCreated],
												[TokenCreated],
												[TypeTransaction],
												[CatPointPromoId])
		SELECT									(SELECT TOP 1 MembershipId FROM @MembershipList ORDER BY MembershipId DESC),
												[GPL].[GuideSerie],
												[GPL].[GuideNumber],
												[GPL].[PriceShipment],
												CASE 
													WHEN (@ForzaPointsExchangeType = 'MONTO') THEN (([GPL].[PriceShipment] * @ForzaPointsExchangeValue) - CAST(([GPL].[PriceShipment] * (@PointPromoFactor/100)) AS INT))
													WHEN (@ForzaPointsExchangeType = 'SERVICIO') THEN (@ForzaPointsExchangeValue)
													ELSE 0
												END,						-- PointsConsumed
												1,							-- RowStatus
												SYSDATETIME(),
												@Token,
												@ForzaPointsExchangeType,	-- TypeTransaction
												@PointPromoId				-- CatPointPromoId
		FROM									@GuidesProcessedList GPL;

		SELECT 1 [spResult], 'Se ha realizado el pago del servicio con puntos Forza' [spMessage];

		IF (@@TRANCOUNT > 0) 
			COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH
		SELECT 0 [spResult],
				ERROR_NUMBER() AS [ErrorNumber],
				ERROR_SEVERITY() AS [ErrorSeverity],
				ERROR_STATE() AS [ErrorState],
				ERROR_PROCEDURE() AS [ErrorProcedure],
				ERROR_LINE() AS [ErrorLine],
				ERROR_MESSAGE() AS [ErrorMessage],
				'No se ha podido procesar el pago solicitado con puntos Forza' AS [spMessage];

		ROLLBACK TRANSACTION
	END CATCH
END