-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <06-02-2023>
-- Description:	<Validate and get Forza points>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_ValidateForzaPoints] 
	@AccountId INT = NULL,
	@CustomerId INT = NULL,
	@GuidesList AS TblListGuides READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @AvailableForzaPoints INT = 0;
	DECLARE @MembershipId INT = 0;
	DECLARE @ForzaPointsExpirationDate INT = 0;
	DECLARE @ForzaPointsExchangeType NVARCHAR(25) = '';
	DECLARE @ForzaPointsExchangeValue INT = 0;
	DECLARE @CatSalesPackageStatusId INT = 0;
	DECLARE @PromoDiscount INT = 0;
	DECLARE @PointPromoFactor DECIMAL(12,2) = 0;
	DECLARE @PointsNeededForExchange INT = 0;
	DECLARE @ProceedWithTransaction BIT = 0;
	DECLARE @PromoDescription NVARCHAR(200) = '';
	DECLARE @MembershipLock INT = 0;
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
	DECLARE @GuidesProcessedList TABLE (GuideSerie NVARCHAR(5),
										GuideNumber INT,
										PriceShipment DECIMAL(12,2),
										IsCollect BIT);
	DECLARE @CustomerList TABLE (CustomerId INT,
								AccountId INT);

	SET @ForzaPointsExpirationDate = (SELECT ISNULL([CP].[Value], 0)
								FROM	[dbo].[ConfigParams] CP
								WHERE	[CP].[Name] = 'ForzaPointsExpirationDays');

	SET @ForzaPointsExchangeType = (SELECT  [CP].[Value]
									FROM	[dbo].[ConfigParams] CP
									WHERE	[CP].[Name] = 'ForzaPointsExchangeType');

	SET @ForzaPointsExchangeValue = (SELECT ISNULL([CP].[Value], 0)
									FROM	[dbo].[ConfigParams] CP
									WHERE	[CP].[Name] = 'ForzaPointsExchangeValue');

	SET @CatSalesPackageStatusId = (SELECT	[CSPS].[IdCatSalesPackageStatus]
									FROM	[dbo].[CatSalesPackageStatus] CSPS
									WHERE	[CSPS].[SalesPackageStatusName] = 'Anulada');

	IF (@AccountId IS NULL AND @CustomerId IS NULL)
		BEGIN 
			SELECT 0 [spResult], 'Datos incorrectos para ejecutar la consulta.' [spMessage];
			RETURN;
		END

	IF ((SELECT COUNT(Guide_Serie) FROM @GuidesList) > 0)
		BEGIN
			INSERT INTO		@CustomerList (CustomerId, AccountId)
			SELECT			[DO].[IdCustomer],
							[A].[AccIdAccount]
			FROM			[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			INNER JOIN		[dbo].[Account] A
				ON			[DO].[IdCustomer] = [A].[IdCustomer]
			INNER JOIN		@GuidesList GL
				ON			[DO].[Guide_Serie] = [GL].[Guide_Serie]
				AND			[DO].[Guide_Number] = [GL].[Guide_Number];
			
			-- Validations
			IF ((SELECT COUNT(DISTINCT(CustomerId)) FROM @CustomerList) != 1)
				BEGIN
					SELECT 0 [spResult], 'El listado de guías recibido tiene asignado más de un cliente, corrobore sus datos e intente nuevamente.' [spMessage];
					RETURN;
				END

			IF (@AccountId IS NOT NULL AND (SELECT TOP 1 AccountId FROM @CustomerList) != @AccountId)
				BEGIN
					SELECT 0 [spResult], 'El listado de guías recibido no están asignadas a la cuenta actual.' [spMessage];
					RETURN;
				END
		
			IF (@CustomerId IS NOT NULL AND (SELECT TOP 1 CustomerId FROM @CustomerList) != @CustomerId)
				BEGIN
					SELECT 0 [spResult], 'El listado de guías recibido no están asignadas a la cuenta actual.' [spMessage];
					RETURN;
				END
		
			-- Membership log
			/*SELECT		@MembershipLock = COUNT([MSL].[IdMembershipSubscriptionLog])
			FROM		[dbo].[MembershipSubscriptionLog] MSL
			INNER JOIN	[dbo].[Membership] M
				ON		[MSL].[MembershipId] = [M].[IdMembership]
			INNER JOIN	@GuidesList GL
				ON		[MSL].[LogGuideSerie] = [GL].[Guide_Serie]
				AND		[MSL].[LogGuideNumber] = [GL].[Guide_Number]
			WHERE		[MSL].[RowStatus] = 1
				AND		[MSL].[SubscriptionId] IS NULL
				AND		[MSL].[LogServiceNumber] <= [M].[MembershipMaxServiceFixedValue];

			IF (@MembershipLock > 0)
				BEGIN
					SELECT 0 [spResult], 'El proceso no puede continuar debido a que ha utilizado guías con reajuste por uso de membresía' [spMessage];
					RETURN;
				END*/

			-- Subscription log
			/*SELECT		@MembershipLock = COUNT([MSL].[IdMembershipSubscriptionLog])
			FROM		[dbo].[MembershipSubscriptionLog] MSL
			INNER JOIN	[dbo].[Subscription] S
				ON		[MSL].[SubscriptionId] = [S].[IdSubscription]
			INNER JOIN	@GuidesList GL
				ON		[MSL].[LogGuideSerie] = [GL].[Guide_Serie]
				AND		[MSL].[LogGuideNumber] = [GL].[Guide_Number]
			WHERE		[MSL].[RowStatus] = 1
				AND		[MSL].[LogServiceNumber] <= [S].[SubscriptionMaxServiceFixedValue];

			IF (@MembershipLock > 0)
				BEGIN
					SELECT 0 [spResult], 'El proceso no puede continuar debido a que ha utilizado guías con reajuste por uso de suscripción' [spMessage];
					RETURN;
				END*/
			
			-- Get data for each guide
			INSERT INTO @GuidesProcessedList(GuideSerie, 
											GuideNumber, 
											PriceShipment,
											IsCollect)
			SELECT							[DO].[Guide_Serie],
											[DO].[Guide_Number],
											[DO].[PriceShippment],
											[DO].[IsCollect]
			FROM							[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			INNER JOIN						@GuidesList GL
				ON							[DO].[Guide_Serie] = [GL].[Guide_Serie]
				AND							[DO].[Guide_Number] = [GL].[Guide_Number];

			IF ((SELECT COUNT(IsCollect) FROM @GuidesProcessedList WHERE IsCollect = 1) > 0)
				BEGIN
					SELECT 0 [spResult], 'El proceso no puede continuar debido a que se encontraron guías tipo COLLECT en el listado recibido' [spMessage];
					RETURN;
				END
		END

	-- Get available points
	IF (@AccountId IS NOT NULL) 
		BEGIN
			SET @AvailableForzaPoints = (	SELECT	SUM([M].[AvailablePoints])
											FROM	[dbo].[Membership] M
											WHERE	[M].[AccountId] = @AccountId
												AND [M].[RowStatus] = 1
												AND [M].[PointsExpirationDate] >= SYSDATETIME()
												AND [M].[CatMembershipStatusId] != @CatSalesPackageStatusId);
		END
	ELSE 
		BEGIN
			SET @AvailableForzaPoints = (	SELECT	SUM([M].[AvailablePoints])
											FROM	[dbo].[Membership] M
											WHERE	[M].[CustomerId] = @CustomerId
												AND [M].[RowStatus] = 1
												AND [M].[PointsExpirationDate] >= SYSDATETIME()
												AND [M].[CatMembershipStatusId] != @CatSalesPackageStatusId);
		END

	-- Get active promotion por exchange
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

	IF (@IsValidDay = 1)
		BEGIN
			SELECT		TOP 1 @PointPromoFactor = [CPP].[PointPromoFactor],
						@PromoDescription = [CPP].[PointPromoDescription]
			FROM		[dbo].[CatPointPromo] CPP
			WHERE		[CPP].[InPointExchange] = 1
				AND		[CPP].[RowStatus] = 1
				AND		SYSDATETIME() BETWEEN [CPP].[StartPromoDate] AND [CPP].[FinishPromoDate]
			ORDER BY	[CPP].[PointPromoWeight] DESC;
		END

	-- Get needed points for transaction
	IF (UPPER(@ForzaPointsExchangeType) = 'SERVICIO' AND ((SELECT COUNT(Guide_Serie) FROM @GuidesList) > 0))
		BEGIN
			--SET @PointsNeededForExchange = (@ForzaPointsExchangeValue * (SELECT COUNT(GuideSerie) FROM @GuidesProcessedList));
			SET @PointsNeededForExchange = (@ForzaPointsExchangeValue * (SELECT COUNT(GuideSerie) 
			FROM @GuidesProcessedList gpl
			LEFT JOIN DeliveryOrder do
		    ON gpl.GuideNumber = do.Guide_Number
			WHERE gpl.PriceShipment >0));
		END

	/*IF (UPPER(@ForzaPointsExchangeType) = 'MONTO' AND ((SELECT COUNT(Guide_Serie) FROM @GuidesList) > 0))
		BEGIN
			SET @PointsNeededForExchange = (@ForzaPointsExchangeValue * (SELECT SUM(PriceShipment) FROM @GuidesProcessedList));
		END*/

	-- Get new points price with promotion
	IF (@PointPromoFactor > 0)
		BEGIN
			SET @PromoDiscount = (@PointsNeededForExchange * (@PointPromoFactor/100));
		END
	SET @PointsNeededForExchange = @PointsNeededForExchange - @PromoDiscount;

	IF (@PointsNeededForExchange <= @AvailableForzaPoints)
		BEGIN
			SET @ProceedWithTransaction = 1;
		END

	SELECT	ISNULL(@AvailableForzaPoints, 0) [AvailableForzaPoints], 
			ISNULL(@PointPromoFactor, 0) [PointPromoFactor], 
			ISNULL(@PointsNeededForExchange, 0) [PointsNeededForExchange],
			@ProceedWithTransaction [ProceedWithTransaction],
			ISNULL(@PromoDescription, '') [PromoDescription],
			1 [spResult],
			'Consulta exitosa' [spMessage];

END