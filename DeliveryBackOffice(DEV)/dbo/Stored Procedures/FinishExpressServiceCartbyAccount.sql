
-- =============================================
-- Author:		<Andres Ruiz>
-- Create date: <2023-05-31>
-- Description:	< Finaliza un carrito de compra de express centers >
-- =============================================
CREATE PROCEDURE [dbo].[FinishExpressServiceCartbyAccount]
	-- Add the parameters for the stored procedure here
	@IdAccount BIGINT,
	@TypeOfPayment INT,
	@Voucher NVARCHAR(50) = NULL,
	@Token NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ExpressCenterWebSystem INT =
	(
		SELECT 
			TOP (1)
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Hermes Web-ExpressCenter'
	)
	DECLARE @CollectPaymentTime INT = 
	(
		SELECT 
			TOP 1 
				[CPT].[TimePlaId] 
		FROM 
			[DeliveryBackOffice].[dbo].[CatPaymentTime] CPT  WITH(NOLOCK)  
		WHERE 
			[CPT].[TimePlaName] = 'Destino' COLLATE Latin1_General_CI_AI
	);
	DECLARE @CreditPaymentTime INT = 
	(
		SELECT 
			TOP 1 
				[CPT].[TimePlaId] 
		FROM 
			[DeliveryBackOffice].[dbo].[CatPaymentTime] CPT  WITH(NOLOCK)  
		WHERE 
			[CPT].[TimePlaName] = 'Post-Venta' COLLATE Latin1_General_CI_AI
	);
	DECLARE @InmediateTimePaymentId INT = 
	(
		SELECT 
			TOP (1)
				[CPT].[TimePlaId] 
		FROM 
			[DeliveryBackOffice].[dbo].[CatPaymentTime] CPT  WITH(NOLOCK) 
		WHERE 
			[CPT].[TimePlaName] = 'Ahora'
	);

	DECLARE @RequestedStatusId INT = 
	(
		SELECT 
			TOP (1)
				[SO].[StatusOrderId]
		FROM
			[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
		WHERE
			[SO].[OrderDescription] = 'Solicitado'  COLLATE Latin1_General_CI_AI 
	)

	DECLARE @ExpressCenterKindOfVisitPoint INT = 
	(
		SELECT 
			TOP 1
				[KOVPC].[IdKindOfVPClient]
		FROM
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  WITH(NOLOCK) 
		WHERE
			[KOVPC].[KindOfVPName] = 'Express Center'  COLLATE Latin1_General_CI_AI 
	);

	DECLARE @AccountVisitPointClient INT =
	(
		SELECT 
			TOP (1)
				[VPC].[CodeOfReference] 
		FROM
			[DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA  WITH(NOLOCK) 
			INNER JOIN
				[DeliveryBackOffice].[dbo].[RegisterUser] RU  WITH(NOLOCK) 
				ON
					[RU].[UsrIdUser] = [RBUBA].[RuaIdUser]
					AND
					[RU].[UsrRowStatus] = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[VisitPointByUser] VPBU  WITH(NOLOCK) 
				ON
					[VPBU].[RegisterUserID] = [RU].[UsrIdUser]
					AND
					[VPBU].[RowStatus] = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPC  WITH(NOLOCK) 
				ON
					[VPC].[IdVisitPointClient] = [VPBU].[IdVisitPointClient]
					AND
					[VPC].[IdKindOfVPClient] = @ExpressCenterKindOfVisitPoint
		WHERE
			[RBUBA].[RuaIdAccount] = @IdAccount
			AND
			[RBUBA].[RuaRowStatus] = 1
	);

	DECLARE @CountUpdated INT = 0;
	DECLARE @CountValid INT = 0;

	DECLARE @CartGuides AS TABLE(
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		INDEX INDX_TEMP_CartGuides_Guides NONCLUSTERED ([GuideSerie], [GuideNumber])
	);

	DECLARE @ValidCartGuides AS TABLE (
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		INDEX INDX_TEMP_ValidCartGuides_Guides NONCLUSTERED ([GuideSerie], [GuideNumber])
	);

	DECLARE @UpdatedGuidesInCart AS TABLE (
		IdUpdated INT
	);

	BEGIN TRANSACTION

	BEGIN TRY

		-- Tomar guías del carrito
		INSERT INTO
			@CartGuides
			(
				[GuideSerie]
				, [GuideNumber]
			)
		SELECT
			DISTINCT
				[AccSCD].[GuideSerie],
				[AccSCD].[GuideNumber]
		FROM
			[DeliveryBackOffice].[dbo].[ExpressAccountServiceCart] AccSC WITH(NOLOCK)
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ExpressAccountServiceCartDetail] AccSCD WITH(NOLOCK)
				ON
					[AccSC].[IdExpressAccountServiceCart] = [AccSCD].[ExpressAccountServiceCartId]
					AND
					[AccSCD].[RowStatus] = 1
		WHERE
			[AccSC].[AccountId] = @IdAccount
			AND
			[AccSC].[IsPending] = 1
			AND
			[AccSC].[RowStatus] = 1

		-- Verificar guías validas, guías collect o confirmadas de pago en carrito de compras
		INSERT INTO
			@ValidCartGuides
			(
				[GuideSerie]
				, [GuideNumber]
			)
		SELECT
			DISTINCT
				[CG].[GuideSerie]
				,[CG].[GuideNumber]
		FROM
			@CartGuides CG
			LEFT JOIN -- Guías marcadas como pago inmediato
				[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPDInmediate WITH(NOLOCK)
				ON
					[CG].[GuideSerie] = [DOPDInmediate].[GuideSerie]
					AND
					[CG].[GuideNumber] = [DOPDInmediate].[GuideNumber]
					AND
					[DOPDInmediate].[TimePlaId] = @InmediateTimePaymentId
			LEFT JOIN -- Guías marcadas como collect
				[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPDcollect WITH(NOLOCK)
				ON
					[CG].[GuideSerie] = [DOPDcollect].[GuideSerie]
					AND
					[CG].[GuideNumber] = [DOPDcollect].[GuideNumber]
					AND
					[DOPDcollect].[TimePlaId] = @CollectPaymentTime
			LEFT JOIN -- Guías marcadas como crédito
				[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPDcredit WITH(NOLOCK)
				ON
					[CG].[GuideSerie] = [DOPDcredit].[GuideSerie]
					AND
					[CG].[GuideNumber] = [DOPDcredit].[GuideNumber]
					AND
					[DOPDcredit].[TimePlaId] = @CreditPaymentTime
			LEFT JOIN -- Guías en detalle de transacción bancaria
				[DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomerDetail] CCTBCD WITH(NOLOCK)
				ON
					[CG].[GuideSerie] = [CCTBCD].[SerieNumber]
					AND
					[CG].[GuideNumber] = [CCTBCD].[ProductNumber]
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] CCTBCdet WITH(NOLOCK)
				ON
					[CCTBCD].[OrderNumber] = [CCTBCdet].[OrderNumber]
					AND
					[CCTBCdet].[ReasonCode] = '00'
			LEFT JOIN -- Guías pagadas como número de orden
				[DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] CCTBCmain WITH(NOLOCK)
				ON
					CONCAT([CG].[GuideSerie], [CG].[GuideNumber]) = [CCTBCmain].[OrderNumber]
					AND
					[CCTBCmain].[ReasonCode] = '00'
			LEFT JOIN -- Guías con membresia o suscripción y monto 0
				[DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSL WITH(NOLOCK)
				ON
					[CG].[GuideSerie] = [MSL].[LogGuideSerie]
					AND
					[CG].[GuideNumber] = [MSL].[LogGuideNumber]
					AND
					[MSL].[LogGuideNewValue] = 0
					AND
					[MSL].[RowStatus] = 1
			LEFT JOIN -- Guías pagadas con cupon de monto completo
				[DeliveryBackOffice].[dbo].[PromoCoupon] PC  WITH(NOLOCK)
				ON
					[CG].[GuideSerie] = [PC].[GuideSerieDestination]
					AND
					[CG].[GuideNumber] = [PC].[GuideNumberDestination]
					AND
					[PC].[FinalAmount] = 0
					AND
					[PC].[RowStatus] = 1
		WHERE
			[DOPDInmediate].[DopId] IS NOT NULL
			OR
			[DOPDcollect].[DopId] IS NOT NULL
			OR
			[DOPDcredit].[DopId] IS NOT NULL
			OR
			[CCTBCdet].[IdTransaction] IS NOT NULL
			OR
			[CCTBCmain].[IdTransaction] IS NOT NULL
			OR
			[MSL].[IdMembershipSubscriptionLog] IS NOT NULL
			OR
			[PC].[IdPromoCoupon] IS NOT NULL
		
		-- Actualizar guías validas que fueron procesadas
		UPDATE
			[DOPD]
		SET
			[DOPD].[ShipmentCompleted] = 1
		FROM
			DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOPD WITH(NOLOCK)
			INNER JOIN
				@ValidCartGuides CG
				ON
					DOPD.GuideSerie = CG.GuideSerie
					AND
					DOPD.GuideNumber = CG.GuideNumber

		-- Actualizar guías que si fueron procesadas o son collect
		UPDATE
			ASCD
		SET
			ASCD.RowStatus = 0
			,ASCD.DateUpdated = GETDATE()
			,ASCD.TokenUpdated = @Token
		OUTPUT
			inserted.IdExpressAccountServiceCartDetail INTO @UpdatedGuidesInCart(IdUpdated)
		FROM
			DeliveryBackOffice.dbo.ExpressAccountServiceCartDetail ASCD WITH(NOLOCK)
			INNER JOIN
				@ValidCartGuides CG
				ON
					ASCD.GuideSerie = CG.GuideSerie
					AND
					ASCD.GuideNumber = CG.GuideNumber

		-- Procesar guías para solicitud de recolección
		UPDATE
			[DO]
		SET
			[DO].[StatusOrderId] = @RequestedStatusId
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
			INNER JOIN
				@ValidCartGuides CG
				ON
					[DO].[Guide_Serie] = [CG].[GuideSerie]
					AND
					[DO].[Guide_Number] = [CG].[GuideNumber]

		INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
		(
		    [Guide_Serie],
		    [Guide_Number],
		    [StatusOrderId],
		    [UserCreated],
		    [DateCreated],
		    [DateCreatedInSystem],
		    [Observations],
		    [Temperature_Celsius],
		    [PieceId],
		    [RowStatus],
		    [DeliveryAttemptId],
		    [SystemOrigin]
		)
		SELECT 
			[CG].[GuideSerie]
			,[CG].[GuideNumber]
			,@RequestedStatusId
			,@Token
			,GETDATE()
			,GETDATE()
			,NULL
			,NULL
			,NULL
			,1
			,NULL
			,@ExpressCenterWebSystem
		FROM
			@ValidCartGuides CG

		-- Procesar transacción 
		DECLARE @InmediatePaymentGuides TABLE 
		(
			GuideSerie NVARCHAR(2),
			GuideNumber INT
		);

		INSERT INTO @InmediatePaymentGuides
		(
		    [GuideSerie],
		    [GuideNumber]
		)
		SELECT 
			[CG].[GuideSerie]
			,[CG].[GuideNumber]
		FROM
			@ValidCartGuides CG
			INNER JOIN
				[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD  WITH(NOLOCK) 
				ON
					[CG].[GuideSerie] = [DOPD].[GuideSerie]
					AND
					[CG].[GuideNumber] = [DOPD].[GuideNumber]
					AND
					[DOPD].[TimePlaId] = @InmediateTimePaymentId
					
		-- Actualizar pago de guías
		IF ( EXISTS ( SELECT TOP 1 1 FROM @InmediatePaymentGuides ) )
		BEGIN

			UPDATE
				[Co]
			SET
				[Co].[TotalAmountPaid] = [Co].[TotalAmount]
				,[Co].[TokenUpdated] = @Token
				,[Co].[DateUpdated] = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[Cost] Co  WITH(NOLOCK) 
				INNER JOIN
					@InmediatePaymentGuides CG
					ON
						[CG].[GuideSerie] = [Co].[GuideSerie]
						AND
						[CG].[GuideNumber] = [Co].[GuideNumber]

			INSERT INTO [DeliveryBackOffice].[dbo].[CostDetail]
			(
				[IdCost],
				[IdTypeOfMoney],
				[Amount],
				[Voucher],
				[RowStatus],
				[TokenCreated],
				[DateCreated]
			)
			SELECT 
				[Co].[IdCost]
				,@TypeOfPayment
				,[Co].[TotalAmountPaid]
				,(CASE WHEN @TypeOfPayment IN (2,6) THEN @Voucher ELSE NULL END)
				,1
				,@Token
				,GETDATE()
			FROM
				@InmediatePaymentGuides CG
				INNER JOIN
					[DeliveryBackOffice].[dbo].[Cost] Co  WITH(NOLOCK) 
					ON
						[Co].[GuideSerie] = [CG].[GuideSerie]
						AND
						[Co].[GuideNumber] = [CG].[GuideNumber]
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[CostDetail] CD  WITH(NOLOCK) 
					ON
						[CD].[IdCost] = [Co].[IdCost]
			WHERE
				[CD].[IdCostDetail] IS NULL;
		END

		-- Registrar transacción de guías al express center
		IF ( EXISTS ( SELECT TOP 1 1 FROM @InmediatePaymentGuides ) )
		BEGIN

			INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentTransaction]
			(
			    [GuideSerie],
			    [GuideNumber],
			    [PayTypeId],
			    [TypeofInOutMoneyId],
			    [TimePlaId],
			    [amount],
			    [TokenCreated],
			    [DateCreated],
			    [TokenUpdated],
			    [DateUpdated],
			    [PaymentRecollections],
			    [PaymentNow],
			    [PaymentDelivery],
			    [StartDate],
			    [EndDate],
			    [ShipmentCompleted],
			    [RecollectionCompleted],
			    [PaidGuide],
			    [TransaccionFAC],
			    [IdHeaderRecolection],
			    [RecolectNow],
			    [RecolectDelivery],
			    [RecolectPayment],
			    [TypeServiceId],
			    [AccountId],
			    [CODAmountProcess],
			    [Fel],
			    [VisitPoint]
			)
			SELECT 
				[CG].[GuideSerie]
				,[CG].[GuideNumber]
				,[DOPD].[PayTypeId]
				,@TypeOfPayment
				,[DOPD].[TimePlaId]
				,[Co].[TotalAmountPaid]
				,@Token
				,GETDATE()
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,[DOPD].[ShipmentCompleted]
				,NULL
				,1
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,1
				,@IdAccount
				,NULL
				,NULL
				,@AccountVisitPointClient
			FROM
				@InmediatePaymentGuides CG
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
					ON
						[CG].[GuideSerie] = [DO].[Guide_Serie]
						AND
						[CG].[GuideNumber] = [DO].[Guide_Number]
				INNER JOIN
					[DeliveryBackOffice].[dbo].[Cost] Co  WITH(NOLOCK) 
					ON
						[Co].[GuideSerie] = [CG].[GuideSerie]
						AND
                        [Co].[GuideNumber] = [CG].[GuideNumber]
						AND
						ISNULL([Co].[TotalAmountPaid], 0) > 0
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD  WITH(NOLOCK) 
					ON
						[DOPD].[GuideSerie] = [CG].[GuideSerie]
						AND
                        [DOPD].[GuideNumber] = [CG].[GuideNumber]
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentTransaction] DOPT  WITH(NOLOCK) 
					ON
						[DOPT].[GuideSerie] = [CG].[GuideSerie]
						AND
                        [DOPT].[GuideNumber] = [CG].[GuideNumber]
			WHERE
				[DOPT].[GuideNumber] IS NULL;
		    
		END


		-- Procesar puntos forza
		IF ( EXISTS ( SELECT TOP 1 1 FROM @InmediatePaymentGuides ) )
		BEGIN

			-- Existen guías de pago inmediato
			DECLARE @MembershipId INT = 0;
			DECLARE @MaxServiceMembership INT = 0;
			DECLARE @DayName NVARCHAR(20) = '';
			DECLARE @IsValidDay BIT = 0;
			DECLARE @PointsGenerated INT = 0;
			
			DECLARE @ForzaPointsGenerationType NVARCHAR(50) = 
			(	
				SELECT
					TOP (1)
						[CP].[Value]
				FROM	
					[DeliveryBackOffice].[dbo].[ConfigParams] CP  WITH(NOLOCK) 
				WHERE	
					[CP].[Name] = 'ForzaPointsGenerationType'  COLLATE Latin1_General_CI_AI 
					AND 
					[CP].[Status] = 1
			);
			DECLARE @ForzaPointsGenerationValue DECIMAL = 
			( 
				SELECT
					TOP (1)
						[CP].[Value]
				FROM
					[DeliveryBackOffice].[dbo].[ConfigParams] CP  WITH(NOLOCK) 
				WHERE	
					[CP].[Name] = 'ForzaPointsGenerationValue'  COLLATE Latin1_General_CI_AI 
					AND 
					[CP].[Status] = 1
			);
			DECLARE @CatSalesPackageStatusId INT = 
			(	
				SELECT	
					TOP (1)
						[CSPS].[IdCatSalesPackageStatus]
				FROM	
					[DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS  WITH(NOLOCK) 
				WHERE	
					[CSPS].[SalesPackageStatusName] = 'Activa' 
					AND 
					[CSPS].[RowStatus] = 1 
			);
			
			DECLARE @AcceptedPointGuides TABLE 
			(
				GuideSerie NVARCHAR(2),
				GuideNumber INT,
				GuidePriceShipment DECIMAL(14, 2),
				CustomerId INT,
				AccountId BIGINT,
				LogServiceNumber INT
			);
			DECLARE @CatPointPromoTbl TABLE 
			(	
				IdPointPromo INT, 
				PointPromoDescription NVARCHAR(400),
				Monday BIT,
				Tuesday BIT,
				Wednesday BIT,
				Thursday BIT,
				Friday BIT,
				Saturday BIT,
				Sunday BIT,
				PointPromoFactor DECIMAL
			);
											
			INSERT INTO @CatPointPromoTbl
			(
			    [IdPointPromo],
			    [PointPromoDescription],
			    [Monday],
			    [Tuesday],
			    [Wednesday],
			    [Thursday],
			    [Friday],
			    [Saturday],
			    [Sunday],
			    [PointPromoFactor]
			)
			SELECT	
				TOP 1	
					[CPP].[IdPointPromo],
					[CPP].[PointPromoDescription],
					[CPP].[Monday],
					[CPP].[Tuesday],
					[CPP].[Wednesday],
					[CPP].[Thursday],
					[CPP].[Friday],
					[CPP].[Saturday],
					[CPP].[Sunday],
					[CPP].[PointPromoFactor]
			FROM	
				[DeliveryBackOffice].[dbo].[CatPointPromo] CPP  WITH(NOLOCK) 
			WHERE	
				[CPP].[RowStatus] = 1
				AND 
				[CPP].[InPointGeneration] = 1
				AND 
				SYSDATETIME() BETWEEN [CPP].[StartPromoDate] AND [CPP].[FinishPromoDate]
			ORDER BY 
				[CPP].[PointPromoWeight] DESC;

			INSERT INTO @AcceptedPointGuides
			(
			    [GuideSerie],
			    [GuideNumber],
			    [GuidePriceShipment],
			    [CustomerId],
				[AccountId],
			    [LogServiceNumber]
			)
			SELECT		
				[TDOL].[GuideSerie],
				[TDOL].[GuideNumber],
				[DO].[PriceShippment],
				[DO].[IdCustomer],
				[MMBSHP].[AccountId],
				ISNULL([MSL].[LogServiceNumber], 0)
			FROM
				@InmediatePaymentGuides TDOL
				INNER JOIN	
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
					ON		
						[TDOL].[GuideSerie] = DO.Guide_Serie
						AND		
						[TDOL].[GuideNumber] = DO.Guide_Number
				LEFT JOIN	
					[DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSL  WITH(NOLOCK) 
					ON		
						[TDOL].[GuideNumber] = [MSL].[LogGuideNumber]
						AND		
						[TDOL].[GuideSerie] = [MSL].[LogGuideSerie]
						AND		
						[MSL].[RowStatus] = 1
						AND		
						[MSL].[SalesPackageStatusId] = @CatSalesPackageStatusId
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[Membership] MMBSHP  WITH(NOLOCK) 
					ON
						[MSL].[MembershipId] = [MMBSHP].[IdMembership]
						AND
						[MMBSHP].[RowStatus] = 1;

			DECLARE @MembershipCustomerId INT = 
			(	
				SELECT 
					TOP 1 
						[APG].[CustomerId]
				FROM 
					@AcceptedPointGuides APG
			);

			DECLARE @MembershipAccountId BIGINT = 
			(	
				SELECT 
					TOP 1 
						[APG].[AccountId]
				FROM @AcceptedPointGuides APG
			);

			SELECT	
				@MembershipId = [M].[IdMembership],
				@MaxServiceMembership = [M].[MembershipMaxServiceFixedValue]
			FROM	
				[DeliveryBackOffice].[dbo].[Membership] M  WITH(NOLOCK) 
			WHERE	
				[M].[AccountId] = @MembershipAccountId
				AND	
				[M].[RowStatus] = 1
				AND 
				[M].[ExpirationDate] >= SYSDATETIME();

			IF (@MembershipId > 0)
			BEGIN

				-- Agregar Log de puntos 
				INSERT INTO [dbo].[PointsByServiceLog] 
				(
					[MembershipId],
					[GuideSerie],
					[GuideNumber],
					[GuidePrice],
					[PointsReceived],
					[PointsConsumed],
					[TypeTransaction],
					[CatPointPromoId],
					[RowStatus],
					[DateCreated],
					[TokenCreated]
				)
				SELECT									
					@MembershipId,
					GuideSerie,
					GuideNumber, 
					GuidePriceShipment,
					(CASE
						WHEN @ForzaPointsGenerationType = 'SERVICIO' THEN CAST(@ForzaPointsGenerationValue AS INT)
						WHEN @ForzaPointsGenerationType = 'MONTO' THEN CAST((GuidePriceShipment / @ForzaPointsGenerationValue) AS INT)
						ELSE 0
					END),	 -- POINTS RECEIVED
					0,		-- POINTS CONSUMED
					@ForzaPointsGenerationType,
					NULL,
					1,
					SYSDATETIME(),
					@Token
				FROM									
					@AcceptedPointGuides
				WHERE									
					(
						LogServiceNumber > @MaxServiceMembership 
						OR 
						LogServiceNumber = 0
					);

				-- Acumulación adicional por promoción
					
				IF 
				(
					(
						SELECT 
							COUNT(IdPointPromo) 
						FROM 
							@CatPointPromoTbl
					) > 0
				)
				BEGIN
					SET @DayName = (SELECT DATENAME(dw, SYSDATETIME()));
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

							UPDATE		
								[PSL]
							SET			
								[PSL].[CatPointPromoId] = (SELECT IdPointPromo FROM @CatPointPromoTbl),
								[PSL].[PointsReceived] = [PSL].[PointsReceived] +	CASE 
																						WHEN @ForzaPointsGenerationType = 'SERVICIO' THEN CAST((SELECT PointPromoFactor FROM @CatPointPromoTbl) AS INT)
																						WHEN @ForzaPointsGenerationType = 'MONTO' THEN CAST([PSL].[PointsReceived] / (SELECT PointPromoFactor FROM @CatPointPromoTbl) AS INT)
																						ELSE 0
																					END
							FROM		
								[DeliveryBackOffice].[dbo].[PointsByServiceLog] PSL
								INNER JOIN	
									@AcceptedPointGuides AG
									ON		
										[PSL].[GuideSerie] = [AG].[GuideSerie]
										AND		
										[PSL].[GuideNumber] = [AG].[GuideNumber]
										AND		
										(
											[AG].[LogServiceNumber] > @MaxServiceMembership 
											OR 
											[AG].[LogServiceNumber] = 0
										);
						END
				END

				-- Agregar puntos a membresía
				SET @PointsGenerated = ISNULL((SELECT	SUM([PSL].[PointsReceived])
										FROM	[dbo].[PointsByServiceLog] PSL
										WHERE	[PSL].[GuideSerie] IN (SELECT GuideSerie FROM @AcceptedPointGuides)
											AND [PSL].[GuideNumber] IN (SELECT GuideNumber FROM @AcceptedPointGuides)), 0);
					
				UPDATE	[DeliveryBackOffice].[dbo].[Membership] 
				SET		[AccumulatedPoints] = ISNULL([AccumulatedPoints], 0) + (@PointsGenerated),
						[AvailablePoints] = ISNULL([AvailablePoints], 0) + (@PointsGenerated)
				WHERE	[IdMembership] = @MembershipId;

			END

		    
		END

		-- Conteo de guías actualizadas
		SELECT
			@CountUpdated = COUNT(IdUpdated)
		FROM
			@UpdatedGuidesInCart

		-- Conteo de guías validas en carrito
		SELECT
			@CountValid = COUNT(GuideNumber)
		FROM
			@CartGuides

		-- Si se puede finalizar el carrito de compras
		IF( @CountUpdated = @CountValid )
		BEGIN
		
			UPDATE 
				DeliveryBackOffice.dbo.ExpressAccountServiceCart
			SET 
				IsPending = 0
				,DateUpdated = GETDATE()
				,TokenUpdated = @Token
			WHERE 
				AccountId = @IdAccount
				AND 
				IsPending = 1
				AND 
				RowStatus = 1

			-- Si actualizo el carrito exitosamente
			IF (@@ROWCOUNT > 0)
			BEGIN
				SELECT
					1 'StatusCode'
					,'Service Cart finished successfully' 'Description'
			END
			ELSE
				SELECT
				2 'StatusCode'
			   ,'Service Cart not found' 'Description'
			
		END
		ELSE
		BEGIN

			SELECT
				1 'StatusCode'
				,'Service Cart partially finished' 'Description'

		END

		COMMIT TRANSACTION;

    END TRY
	BEGIN CATCH
		
		SELECT
			0 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
		   ,ERROR_NUMBER() 'ErrorNumber'
		   ,ERROR_SEVERITY() 'ErrorSeverity'
		   ,ERROR_STATE() 'ErrorState'
		   ,ERROR_PROCEDURE() 'ErrorProcedure'
		   ,ERROR_LINE() 'ErrorLine';
				
		ROLLBACK TRANSACTION;
	END CATCH
END