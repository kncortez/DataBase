-- =============================================
-- Author:		<Andres,Ruiz>
-- Updated date:<2022-05-26>
-- Description:	< Se adiciona generación y manejo de cupones posterior a la transaccion de una tarjeta de credito/debito >
-- =============================================
-- Author: <Jerson Ochoa>
-- Updated date: <2023-01-26>
-- Description: <Acumulación de puntos forza>
-- =============================================

CREATE PROCEDURE [dbo].[spws_set_facapidelcreditcardtransaction]
    @Type AS INT = -1,
    @System AS INT,
    @CardNumber AS NVARCHAR(50),
    @TypeCardNumber AS NVARCHAR(5),
    @Currency AS INT,
    @Ammount AS DECIMAL(18, 2) = NULL,
    @OrderNumber AS NVARCHAR(38) = '',
    @Signature AS NVARCHAR(100) = NULL,
    @CustomerReference AS INT,
    @ReferenceNumber AS VARCHAR(50) = '',
    @ECIIndicator AS VARCHAR(2) = '',
    @Authenticationresult AS VARCHAR(1) = '',
    @TransactionStain AS VARCHAR(50) = '',
    @CAVV AS NVARCHAR(50) = '',
    @ReasonCode AS NVARCHAR(50) = NULL,
    @ReasonDescription AS NVARCHAR(100) = NULL,
    @StatusSend AS INT = NULL,
    @RowStatus AS BIT = 1,
    @TokenCreated AS NVARCHAR(50) = '',
    @DateCreated AS DATETIME,
    @TokenUpdated AS NVARCHAR(50) = NULL,
    @DateUpdated AS DATETIME = NULL,
    --,@Token			 				as nvarchar(50)	  		= ''
    @AccountId INT = 0,
    @VisitPointClientId INT = NULL,
    @VisitPointClientPortfolioId INT = NULL,
    @CouponSerie NVARCHAR(20) = NULL,
    @TblDeliveryOrdersList [TblDeliveryOrdersList2] READONLY
AS
BEGIN

    -- Manejo cuando dato viene vacio o es 0
    IF (@VisitPointClientId = 0)
        SET @VisitPointClientId = NULL;

    IF (@VisitPointClientPortfolioId = 0)
        SET @VisitPointClientPortfolioId = NULL;

    -- Variables de respuesta
    DECLARE @jsonResult NVARCHAR(MAX);

    -- Nuevas variables de respuesta
    DECLARE @CouponDataReponse AS TABLE
    (
        CouponSerie NVARCHAR(20),
        CouponFinalDate DATETIME,
        CouponPromo NVARCHAR(200),
        PromoId INT
    );

    -- Variables adicionales de control de flujo
    DECLARE @CouponCreated BIT = 0;
    DECLARE @CouponIsValid BIT = 0;
    DECLARE @CouponIsReal BIT = 0;
    DECLARE @CouponUpdated BIT = 0;
    DECLARE @DOAlreadyUpdated BIT = 0;
    DECLARE @DOPDAlreadyUpdated BIT = 0;
    DECLARE @CoUpdated BIT = 0;

    -- Variables adicionales de datos
    DECLARE @CustomerId INT = 0;
    DECLARE @CustomerType INT = 0;
    DECLARE @VisitPointClientIdByUser INT = 0;

    DECLARE @GuideSerie NVARCHAR(2) = N'';
    DECLARE @GuideNumber INT = 0;
    DECLARE @OldPriceshipment DECIMAL(14, 2) = 0;
    DECLARE @UpdatedValue DECIMAL(14, 2) = 0;

    -- Datos del cliente para promo
    SELECT @CustomerId = Cu.IdCustomer,
           @CustomerType = ISNULL(Cu.IdCustomerType, 0)
    FROM [DeliveryBackOffice].[dbo].[Account] Acc WITH (NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[Customer] Cu WITH (NOLOCK)
            ON Acc.IdCustomer = Cu.IdCustomer
               AND Acc.AccIdAccount = @AccountId
    WHERE Acc.AccIdAccount = @AccountId;

    -- Punto de visita por cuenta ingresada
    SET @VisitPointClientIdByUser =
    (
        SELECT TOP 1
               CodeOfReference
        FROM DeliveryBackOffice.dbo.VisitPointClient VPC
            INNER JOIN VisitPointByUser VPU
                ON VPC.IdVisitPointClient = VPU.IdVisitPointClient
                   AND VPU.RowStatus = 1
            INNER JOIN RegisterUser ru
                ON VPU.RegisterUserID = ru.UsrIdUser
                   AND ru.UsrRowStatus = 1
            INNER JOIN [dbo].[RolByUserByAccount] rua
                ON rua.RuaIdUser = ru.UsrIdUser
        WHERE rua.RuaIdAccount = @AccountId
    );

    DECLARE @IdTransaction BIGINT = 0;

    -- Puntos FORZA
    DECLARE @MembershipId INT = 0;
    DECLARE @PointsGenerated INT = 0;
    DECLARE @ForzaPointsGenerationValue DECIMAL = 0;
    DECLARE @ForzaPointsGenerationType NVARCHAR(50) = N'';
    DECLARE @DayName NVARCHAR(20) = N'';
    DECLARE @IsValidDay BIT = 0;
    DECLARE @ServiceAmmount DECIMAL = 0;
    DECLARE @CatSalesPackageStatusId INT = 0;
    DECLARE @MaxServiceMembership INT = 0;
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

    SET @ForzaPointsGenerationType =
    (
        SELECT [CP].[Value]
        FROM [dbo].[ConfigParams] CP
        WHERE [CP].[Name] = 'ForzaPointsGenerationType'
              AND [CP].[Status] = 1
    );

    SET @ForzaPointsGenerationValue =
    (
        SELECT [CP].[Value]
        FROM [dbo].[ConfigParams] CP
        WHERE [CP].[Name] = 'ForzaPointsGenerationValue'
              AND [CP].[Status] = 1
    );

    SET @CatSalesPackageStatusId =
    (
        SELECT [CSPS].[IdCatSalesPackageStatus]
        FROM [dbo].[CatSalesPackageStatus] CSPS
        WHERE [CSPS].[SalesPackageStatusName] = 'Activa'
              AND [CSPS].[RowStatus] = 1
    );

    INSERT INTO @CatPointPromoTbl
    SELECT TOP 1
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
    FROM [dbo].[CatPointPromo] CPP
    WHERE [CPP].[RowStatus] = 1
          AND [CPP].[InPointGeneration] = 1
          AND SYSDATETIME()
          BETWEEN [CPP].[StartPromoDate] AND [CPP].[FinishPromoDate]
    ORDER BY [CPP].[PointPromoWeight] DESC;

    IF (@Type = 1)
    BEGIN

		-- Transacción para ingreso de proceso con tarjeta
		BEGIN TRANSACTION LogTransactionTypeOne
		BEGIN TRY
			    
			-- Flujo normal de spws_set_facapidelcreditcardtransaction
			SELECT 
				@IdTransaction = ISNULL([IdTransaction], 0)
			FROM 
				DeliveryBackOffice.dbo.CreditCardTransactionByCustomer CCTBC WITH (NOLOCK)
			WHERE 
				[CCTBC].OrderNumber = @OrderNumber
				AND 
				CAST(@DateCreated AS DATE) = CAST(DateCreated AS DATE);

			IF (@IdTransaction = 0)
			BEGIN

				INSERT INTO DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
				(
					[System],
					CardNumber,
					TypeCardNumber,
					Currency,
					Ammount,
					OrderNumber,
					[Signature],
					CustomerReference,
					ReferenceNumber,
					ECIIndicator,
					Authenticationresult,
					TransactionStain,
					CAVV,
					ReasonCode,
					ReasonDescription,
					StatusSend,
					RowStatus,
					TokenCreated,
					DateCreated,
					TokenUpdated,
					DateUpdated
				)
				VALUES
				(
					@System, 
					@CardNumber, 
					@TypeCardNumber, 
					@Currency, 
					@Ammount, 
					@OrderNumber, 
					@Signature,
					CASE WHEN @CustomerReference ='' THEN '1' ELSE @CustomerReference END, 
					@ReferenceNumber, 
					@ECIIndicator, 
					@Authenticationresult, 
					@TransactionStain, 
					@CAVV,
					@ReasonCode, 
					@ReasonDescription, 
					@StatusSend, 
					@RowStatus, 
					@TokenCreated, 
					@DateCreated, 
					@TokenUpdated,
					@DateUpdated
				);

				SET @IdTransaction = ISNULL(@@Identity, 0);

			END
			ELSE IF (@IdTransaction > 0)
			BEGIN
				UPDATE 
					DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
				SET 
					[System] = @System,
					CardNumber = @CardNumber,
					TypeCardNumber = @TypeCardNumber,
					Currency = @Currency,
					Ammount = @Ammount,
					OrderNumber = @OrderNumber,
					[Signature] = @Signature,
					CustomerReference = @CustomerReference,
					ReferenceNumber = CASE WHEN @CustomerReference ='' THEN '1' ELSE @CustomerReference END,
					ECIIndicator = @ECIIndicator,
					Authenticationresult = @Authenticationresult,
					TransactionStain = @TransactionStain,
					CAVV = @CAVV,
					ReasonCode = @ReasonCode,
					ReasonDescription = @ReasonDescription,
					StatusSend = @StatusSend,
					RowStatus = @RowStatus,
					TokenCreated = @TokenCreated,
					DateCreated = @DateCreated,
					TokenUpdated = @TokenUpdated,
					DateUpdated = @DateUpdated
				WHERE 
					IdTransaction = @IdTransaction
					AND 
					OrderNumber = @OrderNumber
					AND 
					StatusSend <> 1
					AND 
					CAST(@DateCreated AS DATE) = CAST(DateCreated AS DATE);

			END;

			COMMIT TRANSACTION LogTransactionTypeOne
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION LogTransactionTypeOne
			    
		END CATCH

		-- "Registro" de llamada en bitácora
        BEGIN TRY

            INSERT INTO DenariusLog_Dev.dbo.LOG_Http_Interceptor
            (
                [TypeOfUse],
                [IdSystem],
                [EntityObjectName],
                [TransactionID],
                [RQ_Method],
                [RQ_Uri],
                [RQ_Service],
                [RQ_Header],
                [RQ_Body],
                [RQ_Object],
                [RQ_Datetime],
                [RQ_LauValue],
                [RQ_Token],
                [RQ_IdOrder],
                [RS_Service],
                [RS_StatusCode],
                [RS_ReasonPhrase],
                [RS_ReasonCode],
                [RS_ReasonCodeMessage],
                [RS_Header],
                [RS_Body],
                [RS_Object],
                [RS_Datetime],
                [RS_IdOrder],
                [RS_LauValue],
                [RS_Token]
            )
            VALUES
            (
				'Push', 
				15, 
				'DeliveryBackOffice.dbo.CreditCardTransaction', 
				@IdTransaction, 
				'SOAP',
				'https://ecm.firstatlanticcommerce.com/PGService/Services.svc', 
				1, 
				NULL, 
				NULL, 
				NULL, 
				@DateCreated,
				NULL, 
				NULL, 
				1, 
				2, 
				0, 
				NULL, 
				@ReasonCode, 
				@ReasonDescription, 
				NULL, 
				NULL, 
				NULL, 
				@DateCreated,
				@OrderNumber, 
				NULL, 
				@TokenUpdated
			);

        END TRY
        BEGIN CATCH

            INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
            (
                DateCreated,
                TokenCreated,
                ErrorLine,
                ErrorDescription,
                ErrorProcedure
            )
            VALUES
            (GETDATE(), 'ERROR HTTP LOG', ERROR_LINE(), ERROR_MESSAGE(), ERROR_PROCEDURE());

        END CATCH;

    END;
    ELSE IF (@Type = 2)
    BEGIN
		
		-- Transacción para actualización de proceso con tarjeta
		BEGIN TRANSACTION LogTransactionTypeTwo
		BEGIN TRY
			
			SELECT 
				@IdTransaction = [IdTransaction],
				@ServiceAmmount = [Ammount]
			FROM 
				DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH (NOLOCK)
			WHERE 
				OrderNumber = @OrderNumber;

			UPDATE 
				DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
			SET 
				ReasonCode = @ReasonCode,
				ReasonDescription = @ReasonDescription,
				DateUpdated = @DateUpdated,
				TokenUpdated = @TokenUpdated,
				ECIIndicator = @ECIIndicator,
				Authenticationresult = @Authenticationresult,
				TransactionStain = @TransactionStain,
				CAVV = @CAVV,
				StatusSend = @StatusSend
			WHERE 
				IdTransaction = @IdTransaction
				AND 
				OrderNumber = @OrderNumber
				AND 
				StatusSend <> 1
				AND 
				CAST(@DateUpdated AS DATE) = CAST(DateCreated AS DATE);

			COMMIT TRANSACTION LogTransactionTypeTwo

		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION LogTransactionTypeTwo

		END CATCH

		-- "Registro" de llamada en bitácora
        BEGIN TRY

            INSERT INTO DenariusLog_Dev.dbo.LOG_Http_Interceptor
            (
                [TypeOfUse],
                [IdSystem],
                [EntityObjectName],
                [TransactionID],
                [RQ_Method],
                [RQ_Uri],
                [RQ_Service],
                [RQ_Header],
                [RQ_Body],
                [RQ_Object],
                [RQ_Datetime],
                [RQ_LauValue],
                [RQ_Token],
                [RQ_IdOrder],
                [RS_Service],
                [RS_StatusCode],
                [RS_ReasonPhrase],
                [RS_ReasonCode],
                [RS_ReasonCodeMessage],
                [RS_Header],
                [RS_Body],
                [RS_Object],
                [RS_Datetime],
                [RS_IdOrder],
                [RS_LauValue],
                [RS_Token]
            )
            VALUES
            ('Push', 15, 'DeliveryBackOffice.dbo.CreditCardTransaction', @IdTransaction, 'SOAP',
                'https://ecm.firstatlanticcommerce.com/PGService/Services.svc', 1, NULL, NULL, NULL, @DateUpdated,
                NULL, NULL, 1, 2, 0, NULL, @ReasonCode, @ReasonDescription, NULL, NULL, NULL, @DateUpdated,
                @OrderNumber, NULL, @TokenUpdated);

        END TRY
        BEGIN CATCH


            INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
            (
                DateCreated,
                TokenCreated,
                ErrorLine,
                ErrorDescription,
                ErrorProcedure
            )
            VALUES
            (GETDATE(), 'ERROR HTTP LOG', ERROR_LINE(), ERROR_MESSAGE(), ERROR_PROCEDURE());


        END CATCH;

    END
    ELSE IF (@Type = 3)
    BEGIN

        -- Pago de renovación de membresía o suscripción
		BEGIN TRANSACTION LogTransactionTypeThree
		BEGIN TRY
				
			SELECT 
				@IdTransaction = ISNULL([IdTransaction], 0)
			FROM 
				DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH (NOLOCK)
			WHERE 
				OrderNumber = @OrderNumber
				AND 
				CAST(@DateCreated AS DATE) = CAST(DateCreated AS DATE);
				
			IF (@IdTransaction = 0)
			BEGIN

				INSERT INTO DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
				(
					[System],
					CardNumber,
					TypeCardNumber,
					Currency,
					Ammount,
					OrderNumber,
					[Signature],
					CustomerReference,
					ReferenceNumber,
					ECIIndicator,
					Authenticationresult,
					TransactionStain,
					CAVV,
					ReasonCode,
					ReasonDescription,
					StatusSend,
					RowStatus,
					TokenCreated,
					DateCreated,
					TokenUpdated,
					DateUpdated
				)
				VALUES
				(
					@System, 
					@CardNumber, 
					@TypeCardNumber, 
					@Currency, 
					@Ammount, 
					@OrderNumber, 
					@Signature,
					@CustomerReference, 
					@ReferenceNumber, 
					@ECIIndicator, 
					@Authenticationresult, 
					@TransactionStain, 
					@CAVV,
					@ReasonCode, 
					@ReasonDescription, 
					@StatusSend, 
					@RowStatus, 
					@TokenCreated, 
					@DateCreated, 
					@TokenUpdated,
					@DateUpdated
				);

				SET @IdTransaction = ISNULL(@@Identity, 0);
			END;
			ELSE IF (@IdTransaction > 0)
			BEGIN
				UPDATE 
					DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
				SET 
					ECIIndicator = @ECIIndicator,
					Authenticationresult = @Authenticationresult,
					ReasonCode = @ReasonCode,
					ReasonDescription = @ReasonDescription,
					StatusSend = @StatusSend,
					TokenUpdated = @TokenCreated,
					DateUpdated = @DateCreated
				WHERE 
					IdTransaction = @IdTransaction
					AND 
					OrderNumber = @OrderNumber
					AND 
					StatusSend <> 1
					AND 
					CAST(@DateCreated AS DATE) = CAST(DateCreated AS DATE);

			END;

			COMMIT TRANSACTION [LogTransactionTypeThree]
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION [LogTransactionTypeThree]

		END CATCH

    END;

	-- Variables para procesos de pago y puntos
	DECLARE @AcceptedGuides AS TABLE
	(
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		GuidePriceShipment DECIMAL(14, 2),
		CustomerID INT,
		LogServiceNumber INT
	);

	DECLARE @CostUpdated AS TABLE
	(
		IdCost INT,
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		GuidePriceShipment DECIMAL(14, 2)
	);

	INSERT INTO @AcceptedGuides
	(
		GuideSerie,
		GuideNumber,
		GuidePriceShipment,
		CustomerID,
		LogServiceNumber
	)
	SELECT DISTINCT
			CCTBCD.SerieNumber,
			CCTBCD.ProductNumber,
			DO.PriceShippment,
			DO.IdCustomer,
			ISNULL([MSL].[LogServiceNumber], 0)
	FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomerDetail CCTBCD WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
			ON CCTBCD.ProductNumber = DO.Guide_Number
				AND CCTBCD.SerieNumber = DO.Guide_Serie
		LEFT JOIN [dbo].[MembershipSubscriptionLog] MSL
			ON [CCTBCD].[ProductNumber] = [MSL].[LogGuideNumber]
				AND [CCTBCD].[SerieNumber] = [MSL].[LogGuideSerie]
				AND [MSL].[RowStatus] = 1
				AND [MSL].[SalesPackageStatusId] = @CatSalesPackageStatusId
		LEFT JOIN [dbo].[Membership] M
			ON [MSL].[MembershipId] = [M].[IdMembership]
	WHERE CCTBCD.OrderNumber = @OrderNumber;

	IF (SUBSTRING(@OrderNumber, 1, 2) != 'HR')
	BEGIN

		IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
			DROP TABLE #listGuides;

		SELECT LTRIM(RTRIM(SUBSTRING(Item, 1, 2))) ItemSerie,
				LTRIM(RTRIM(SUBSTRING(
										Item,
										3,
										IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))
									)
							)
					) ItemNumber
		INTO #listGuides
		FROM DeliveryBackOffice.dbo.SplitUnlimited(RTRIM(LTRIM(@OrderNumber)), ',');

		INSERT INTO @AcceptedGuides
		(
			GuideSerie,
			GuideNumber,
			GuidePriceShipment,
			CustomerID,
			LogServiceNumber
		)
		SELECT TOP 1
				LG.ItemSerie,
				LG.ItemNumber,
				DO.PriceShippment,
				DO.IdCustomer,
				ISNULL([MSL].[LogServiceNumber], 0)
		FROM #listGuides LG
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
				ON LG.ItemSerie = DO.Guide_Serie
					AND LG.ItemNumber = DO.Guide_Number
			LEFT JOIN [dbo].[MembershipSubscriptionLog] MSL
				ON [LG].[ItemNumber] = [MSL].[LogGuideNumber]
					AND [LG].[ItemSerie] = [MSL].[LogGuideSerie]
					AND [MSL].[RowStatus] = 1
					AND [MSL].[SalesPackageStatusId] = @CatSalesPackageStatusId
			LEFT JOIN [dbo].[Membership] M
				ON [MSL].[MembershipId] = [M].[IdMembership];

		IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
			DROP TABLE #listGuides;

	END;

	BEGIN TRANSACTION RegisterSuccessfulPayment
	BEGIN TRY
			-- Proceso para registro de pago
		IF (@ReasonCode IN ( '1', '40', '00' ) AND EXISTS ( SELECT TOP 1 1 FROM @AcceptedGuides ))
		BEGIN

			INSERT INTO DeliveryBackOffice.dbo.Cost
			(
				IdProduct,
				IdTypeCharge,
				IdModule,
				ProductNumber,
				TotalAmount,
				RowStatus,
				TokenCreated,
				DateCreated,
				GuideSerie,
				GuideNumber
			)
			SELECT 1,
					1,
					NULL,
					CONCAT(AG.GuideSerie, AG.GuideNumber),
					AG.GuidePriceShipment,
					1,
					@TokenUpdated,
					GETDATE(),
					AG.GuideSerie,
					AG.GuideNumber
			FROM @AcceptedGuides AG
				OUTER APPLY
			(
				SELECT TOP 1
						Co.IdCost
				FROM [DeliveryBackOffice].[dbo].[Cost] Co WITH (NOLOCK)
				WHERE (
							(
								Co.GuideSerie = ISNULL(AG.GuideSerie, 'FD')
								AND Co.GuideNumber = AG.GuideNumber
							)
							OR
							(
								Co.ProductNumber = CONCAT(ISNULL(AG.GuideSerie, 'FD'), AG.GuideNumber)
								AND Co.GuideSerie IS NULL
								AND Co.GuideNumber IS NULL
							)
						)
						AND Co.RowStatus = 1
				ORDER BY Co.DateCreated DESC
			) CoAux
			WHERE CoAux.IdCost IS NULL;

			UPDATE Co
			SET Co.TotalAmountPaid = Co.TotalAmount,
				Co.PaymentDate = GETDATE(),
				Co.TokenUpdated = @TokenUpdated,
				Co.DateUpdated = GETDATE(),
				Co.GuideSerie = AG.GuideSerie,
				Co.GuideNumber = AG.GuideNumber
			OUTPUT inserted.IdCost,
					inserted.TotalAmount,
					inserted.GuideSerie,
					inserted.GuideNumber
			INTO @CostUpdated
			(
				IdCost,
				GuidePriceShipment,
				GuideSerie,
				GuideNumber
			)
			FROM @AcceptedGuides AG
				OUTER APPLY
			(
				SELECT TOP 1
						Co.IdCost
				FROM [DeliveryBackOffice].[dbo].[Cost] Co WITH (NOLOCK)
				WHERE (
							(
								Co.GuideSerie = ISNULL(AG.GuideSerie, 'FD')
								AND Co.GuideNumber = AG.GuideNumber
							)
							OR
							(
								Co.ProductNumber = CONCAT(ISNULL(AG.GuideSerie, 'FD'), AG.GuideNumber)
								AND Co.GuideSerie IS NULL
								AND Co.GuideNumber IS NULL
							)
						)
						AND Co.RowStatus = 1
				ORDER BY Co.DateCreated DESC
			) CoAux
				INNER JOIN DeliveryBackOffice.dbo.Cost Co WITH (NOLOCK)
					ON Co.IdCost = CoAux.IdCost;

			-- Generar CostDetail inexistentes
			INSERT INTO [DeliveryBackOffice].[dbo].[CostDetail]
			(
				IdCost,
				IdTypeOfMoney,
				Amount,
				Voucher,
				RowStatus,
				TokenCreated,
				DateCreated,
				TokenUpdated,
				DateUpdated
			)
			SELECT CU.IdCost,
					2,
					CU.GuidePriceShipment,
					@OrderNumber,
					1,
					@TokenUpdated,
					GETDATE(),
					NULL,
					NULL
			FROM @CostUpdated CU
				LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
					ON CD.IdCost = CU.IdCost
			WHERE CD.IdCostDetail IS NULL;

			-- Actualizar CostDetails
			UPDATE [DeliveryBackOffice].[dbo].[CostDetail]
			SET Amount = CU.GuidePriceShipment,
				Voucher = @OrderNumber,
				TokenUpdated = @TokenUpdated,
				DateUpdated = GETDATE()
			FROM [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
				INNER JOIN @CostUpdated CU
					ON CD.IdCost = CU.IdCost;

		END;
		
		COMMIT TRANSACTION [RegisterSuccessfulPayment]
	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION [RegisterSuccessfulPayment]
	    
	END CATCH
	
	-- Proceso de puntos forza
	BEGIN TRANSACTION RegisterForzaPointsGeneration
	BEGIN TRY
	
		IF ( @ReasonCode IN ( '1', '40', '00' ) AND EXISTS ( SELECT TOP 1 1 FROM @AcceptedGuides ) )
		BEGIN
		
				-- Acumulación de puntos FORZA POR LOTE
				-- Author: Jerson Ochoa - 27-01-2023

				SET @CustomerId =
				(
					SELECT TOP 1 CustomerID FROM @AcceptedGuides
				);

				SET @AccountId =
				(
					SELECT [A].[AccIdAccount]
					FROM [dbo].[Account] A
					WHERE [A].[IdCustomer] = @CustomerId
				);

				SELECT @MembershipId = [M].[IdMembership],
						@MaxServiceMembership = [M].[MembershipMaxServiceFixedValue]
				FROM [dbo].[Membership] M
				WHERE [M].[AccountId] = @AccountId
						AND [M].[RowStatus] = 1
						AND [M].[ExpirationDate] >= SYSDATETIME();

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
					SELECT @MembershipId,
							GuideSerie,
							GuideNumber,
							GuidePriceShipment,
							(CASE
								WHEN @ForzaPointsGenerationType = 'SERVICIO' THEN
									CAST(@ForzaPointsGenerationValue AS INT)
								WHEN @ForzaPointsGenerationType = 'MONTO' THEN
									CAST((GuidePriceShipment / @ForzaPointsGenerationValue) AS INT)
								ELSE
									0
							END
							), -- POINTS RECEIVED
							0, -- POINTS CONSUMED
							@ForzaPointsGenerationType,
							NULL,
							1,
							SYSDATETIME(),
							@TokenCreated
					FROM @AcceptedGuides
					WHERE (
								LogServiceNumber > @MaxServiceMembership
								OR LogServiceNumber = 0
							);

					-- Acumulación adicional por promoción

					IF ((SELECT COUNT(IdPointPromo)FROM @CatPointPromoTbl) > 0)
					BEGIN
						SET @DayName =
						(
							SELECT DATENAME(dw, SYSDATETIME())
						);
						SET @IsValidDay = CASE
												WHEN @DayName = 'Monday' THEN
												(
													SELECT TOP 1 Monday FROM @CatPointPromoTbl
												)
												WHEN @DayName = 'Tuesday' THEN
												(
													SELECT TOP 1 Tuesday FROM @CatPointPromoTbl
												)
												WHEN @DayName = 'Wednesday' THEN
												(
													SELECT TOP 1 Wednesday FROM @CatPointPromoTbl
												)
												WHEN @DayName = 'Thursday' THEN
												(
													SELECT TOP 1 Thursday FROM @CatPointPromoTbl
												)
												WHEN @DayName = 'Friday' THEN
												(
													SELECT TOP 1 Friday FROM @CatPointPromoTbl
												)
												WHEN @DayName = 'Saturday' THEN
												(
													SELECT TOP 1 Saturday FROM @CatPointPromoTbl
												)
												WHEN @DayName = 'Sunday' THEN
												(
													SELECT TOP 1 Sunday FROM @CatPointPromoTbl
												)
												ELSE
													0
											END;
						IF (@IsValidDay = 1)
						BEGIN

							UPDATE PSL
							SET [PSL].[CatPointPromoId] =
								(
									SELECT IdPointPromo FROM @CatPointPromoTbl
								),
								[PSL].[PointsReceived] = [PSL].[PointsReceived]
															+ CASE
																WHEN @ForzaPointsGenerationType = 'SERVICIO' THEN
																	CAST(
																	(
																		SELECT PointPromoFactor FROM @CatPointPromoTbl
																	) AS INT)
																WHEN @ForzaPointsGenerationType = 'MONTO' THEN
																	CAST([PSL].[PointsReceived] /
																		(
																			SELECT PointPromoFactor FROM @CatPointPromoTbl
																		) AS INT)
																ELSE
																	0
															END
							FROM [dbo].[PointsByServiceLog] PSL
								INNER JOIN @AcceptedGuides AG
									ON [PSL].[GuideSerie] = [AG].[GuideSerie]
										AND [PSL].[GuideNumber] = [AG].[GuideNumber]
										AND
										(
											[AG].[LogServiceNumber] > @MaxServiceMembership
											OR [AG].[LogServiceNumber] = 0
										);
						END;
					END;

					-- Agregar puntos a membresía
					SET @PointsGenerated = ISNULL(
											(
												SELECT SUM([PSL].[PointsReceived])
												FROM [dbo].[PointsByServiceLog] PSL
												WHERE [PSL].[GuideSerie] IN
														(
															SELECT GuideSerie FROM @AcceptedGuides
														)
														AND [PSL].[GuideNumber] IN
															(
																SELECT GuideNumber FROM @AcceptedGuides
															)
											),
											0
													);

					UPDATE [dbo].[Membership]
					SET [AccumulatedPoints] = ISNULL([AccumulatedPoints], 0) + (@PointsGenerated),
						[AvailablePoints] = ISNULL([AvailablePoints], 0) + (@PointsGenerated)
					WHERE [IdMembership] = @MembershipId;

				END;

			-- FIN Acumulación de puntos FORZA

		END
	    
		COMMIT TRANSACTION [RegisterForzaPointsGeneration]
	END TRY
	BEGIN CATCH
	    
		ROLLBACK TRANSACTION [RegisterForzaPointsGeneration]
	END CATCH

	BEGIN TRANSACTION
	BEGIN TRY

		-- Proceso de cupones
		IF ( @Type = 1 )
		BEGIN
		    
            BEGIN TRY
                -- Si es posible generar o redimir un cupon
                IF (EXISTS (SELECT TOP 1 1 FROM @TblDeliveryOrdersList))
                BEGIN

                    -- Obtener serie y numero de guía
                    SELECT TOP 1
                           @GuideSerie = TDOL.Guide_Serie,
                           @GuideNumber = TDOL.Guide_Number
                    FROM @TblDeliveryOrdersList TDOL;

                    -- Obtener valor anterior y valor con descuento aplicado
                    SET @OldPriceshipment =
                    (
                        SELECT TOP 1
                               DO.PriceShippment
                        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                        WHERE DO.Guide_Serie = @GuideSerie
                              AND DO.Guide_Number = @GuideNumber
                    );

                    SET @UpdatedValue =
                    (
                        SELECT TOP 1
                               TDOL.PriceShippment
                        FROM @TblDeliveryOrdersList TDOL
                        WHERE TDOL.Guide_Serie = @GuideSerie
                              AND TDOL.Guide_Number = @GuideNumber
                    );

                END;

                IF (
                       LTRIM(RTRIM(ISNULL(@CouponSerie, ''))) = ''
                       AND EXISTS
                (
                    SELECT TOP 1
                           1
                    FROM @TblDeliveryOrdersList
                )
                   )
                BEGIN

                    -- SE debe generar un cupon
                    DECLARE @NewCouponData AS TABLE
                    (
                        PromoId INT,
                        CouponFinalDate DATETIME,
                        CouponDiscountType INT,
                        CouponValueType INT,
                        CouponValue DECIMAL(5, 2),
                        PromoName NVARCHAR(200)
                    );

                    IF (EXISTS
                    (
                        SELECT TOP 1
                               1
                        FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH (NOLOCK)
                        WHERE PC.GuideSerieOrigin = @GuideSerie
                              AND PC.GuideNumberOrigin = @GuideNumber
                              AND PC.RowStatus = 1
                    )
                       )
                    BEGIN

                        INSERT INTO @CouponDataReponse
                        (
                            CouponSerie,
                            CouponFinalDate,
                            CouponPromo,
                            PromoId
                        )
                        SELECT
                        -- Top 1 para generar cupon de promo con mayor peso
                            TOP 1
                            PromoC.PromoCouponSerie,
                            PromoC.FinalActiveDate,
                            CPromo.PromoDescription,
                            PromoC.CatPromoId
                        FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH (NOLOCK)
                            INNER JOIN [DeliveryBackOffice].[dbo].[CatPromo] CPromo WITH (NOLOCK)
                                ON PromoC.CatPromoId = CPromo.IdPromo
                        WHERE PromoC.GuideSerieOrigin = @GuideSerie
                              AND PromoC.GuideNumberOrigin = @GuideNumber
                              AND PromoC.RowStatus = 1;

                    END;
                    ELSE
                    BEGIN

                        -- Insertar datos de promo valida
                        INSERT INTO @NewCouponData
                        (
                            PromoId,
                            CouponFinalDate,
                            CouponDiscountType,
                            CouponValueType,
                            CouponValue,
                            PromoName
                        )
                        SELECT
                        -- Top 1 para generar cupon de promo con mayor peso
                            TOP 1
                            CPromo.IdPromo,
                            (CASE
                                 WHEN CPromo.LimitPromoTime = 24.00 THEN
                                     DATEADD(SECOND, -1, CAST(DATEADD(DAY, 1, CAST(GETDATE() AS DATE)) AS DATETIME))
                                 ELSE
                                     DATEADD(MINUTE, (ISNULL(CPromo.LimitPromoTime, 1) * 60), GETDATE())
                             END
                            ),
                            CPromo.CatDiscountTypeId,
                            CPromo.CatValueTypeId,
                            CPromo.PromoValue,
                            CPromo.PromoDescription
                        FROM [DeliveryBackOffice].[dbo].[CatPromo] CPromo WITH (NOLOCK)
                            INNER JOIN [DeliveryBackOffice].[dbo].[PromoCoverage] PCov WITH (NOLOCK)
                                ON CPromo.IdPromo = PCov.CatPromoId
                        WHERE
                            -- Validación de día de la semana correcta
                            (
                                (
                                    CPromo.Monday = 1
                                    AND DATEPART(WEEKDAY, GETDATE()) = 2
                                )
                                OR
                                (
                                    CPromo.Tuesday = 1
                                    AND DATEPART(WEEKDAY, GETDATE()) = 3
                                )
                                OR
                                (
                                    CPromo.Wednesday = 1
                                    AND DATEPART(WEEKDAY, GETDATE()) = 4
                                )
                                OR
                                (
                                    CPromo.Thursday = 1
                                    AND DATEPART(WEEKDAY, GETDATE()) = 5
                                )
                                OR
                                (
                                    CPromo.Friday = 1
                                    AND DATEPART(WEEKDAY, GETDATE()) = 6
                                )
                                OR
                                (
                                    CPromo.Saturday = 1
                                    AND DATEPART(WEEKDAY, GETDATE()) = 7
                                )
                                OR
                                (
                                    CPromo.Sunday = 1
                                    AND DATEPART(WEEKDAY, GETDATE()) = 1
                                )
                            )
                            -- Validación de rango de fechas correcto para la promo
                            AND (GETDATE()
                            BETWEEN CPromo.StartPromoDate AND CPromo.FinishPromoDate
                                )
                            -- Validación de cobertura de promo
                            AND
                            (
                                PCov.CustomerId = @CustomerId
                                OR PCov.CustomerTypeId = @CustomerType
                                OR PCov.VisitPointClientId = ISNULL(@VisitPointClientId, @VisitPointClientIdByUser)
                            )
                            --- Promo esta activa
                            AND CPromo.RowStatus = 1
                        ORDER BY
                            -- Aplicar promoción de mayor peso
                            CPromo.PromoWeight DESC;

                        IF (EXISTS (SELECT TOP 1 1 FROM @NewCouponData))
                        BEGIN

                            -- Insertar nuevo cupon
                            INSERT INTO [DeliveryBackOffice].[dbo].[PromoCoupon]
                            (
                                CatPromoId,
                                PromoCouponSerie,
                                GuideSerieOrigin,
                                GuideNumberOrigin,
                                CustomerOrigin,
                                VisitPointClientOrigin,
                                SystemOrigin,
                                CatDiscountTypeId,
                                CatValueTypeId,
                                CouponValue,
                                StartActiveDate,
                                FinalActiveDate,
                                RowStatus,
                                DateCreated,
                                TokenCreated
                            )
                            OUTPUT inserted.PromoCouponSerie,
                                   inserted.FinalActiveDate,
                                   inserted.CatPromoId
                            INTO @CouponDataReponse
                            (
                                CouponSerie,
                                CouponFinalDate,
                                PromoId
                            )
                            SELECT NCD.PromoId,
                                   CONCAT(@GuideSerie, @GuideNumber)
                                   + RIGHT('000' + CAST(CEILING(RAND() * 100) AS NVARCHAR), 2),
                                   @GuideSerie,
                                   @GuideNumber,
                                   @CustomerId,
                                   ISNULL(@VisitPointClientId, @VisitPointClientIdByUser),
                                   @System,
                                   NCD.CouponDiscountType,
                                   NCD.CouponValueType,
                                   NCD.CouponValue,
                                   GETDATE(),
                                   NCD.CouponFinalDate,
                                   1,
                                   GETDATE(),
                                   @TokenCreated
                            FROM @NewCouponData NCD;

                            SET @CouponCreated = (CASE
                                                      WHEN
                                                      (
                                                          SELECT TOP 1 1 FROM @CouponDataReponse
                                                      ) > 0 THEN
                                                          1
                                                      ELSE
                                                          0
                                                  END
                                                 );

                            -- Actualizar nombre de promo en cupon a devolver
                            UPDATE @CouponDataReponse
                            SET CouponPromo = NCD.PromoName
                            FROM @NewCouponData NCD
                                INNER JOIN @CouponDataReponse CD
                                    ON NCD.PromoId = CD.PromoId;

                        END;

                    END;

                END;
                -- Redención de cupon
                ELSE IF (
                            LTRIM(RTRIM(ISNULL(@CouponSerie, ''))) != ''
                            AND EXISTS
                     (
                         SELECT TOP 1
                                1
                         FROM @TblDeliveryOrdersList
                     )
                        )
                BEGIN

                    SET @CouponIsValid = ISNULL(
                                         (
                                             SELECT TOP 1
                                                    1
                                             FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH (NOLOCK)
                                             WHERE PC.RedeemedDate IS NULL
                                                   AND PC.PromoCouponSerie = @CouponSerie
                                                   AND PC.FinalActiveDate >= GETDATE()
                                                   AND PC.RowStatus = 1
                                         ),
                                         0
                                               );

                    IF (@CouponIsValid = 1)
                    BEGIN


                        -- Registrar consumo de cupon y valores originales
                        UPDATE [DeliveryBackOffice].[dbo].[PromoCoupon]
                        SET SystemDestination = @System,
                            GuideSerieDestination = @GuideSerie,
                            GuideNumberDestination = @GuideNumber,
                            CustomerDestination = @CustomerId,
                            VisitPointClientDestination = ISNULL(@VisitPointClientId, @VisitPointClientIdByUser),
                            VisitPointClientPortfolioDestination = @VisitPointClientPortfolioId,
                            OriginalAmount = @OldPriceshipment,
                            DiscountAmount = IIF(@UpdatedValue <= 0,
                                                 @OldPriceshipment,
                                                 (@OldPriceshipment - @UpdatedValue)),
                            FinalAmount = IIF(@UpdatedValue <= 0, 0, @UpdatedValue),
                            RedeemedDate = GETDATE(),
                            DateUpdated = GETDATE(),
                            TokenUpdated = @TokenCreated
                        WHERE PromoCouponSerie = @CouponSerie
                              AND RowStatus = 1;

                        IF (@@ROWCOUNT > 0)
                        BEGIN
                            SET @CouponUpdated = 1;
                        END;

                        UPDATE dbo.DeliveryOrder
                        SET PriceShippment = IIF(t.PriceShippment <= 0, 0, t.PriceShippment),
                            StatusOrderId = 15,
                            IsCollect = t.IsCollect
                        FROM dbo.DeliveryOrder ord
                            INNER JOIN @TblDeliveryOrdersList t
                                ON t.Guide_Number = ord.Guide_Number
                                   AND t.Guide_Serie = ord.Guide_Serie;


                        IF (@@ROWCOUNT > 0)
                        BEGIN
                            SET @DOAlreadyUpdated = 1;
                        END;


                        UPDATE dbo.DeliveryOrderPaymentDetail
                        SET ShipmentCompleted = t.ShipmentCompleted,
                            PayTypeId = t.IdTypePayment,
                            TypeofInOutMoneyId = t.IdWayToPayment,
                            TimePlaId = t.IdTimePayment
                        FROM dbo.DeliveryOrderPaymentDetail pay
                            INNER JOIN @TblDeliveryOrdersList t
                                ON (
                                       t.Guide_Number = pay.GuideNumber
                                       AND t.Guide_Serie = pay.GuideSerie
                                   );

                        IF (@@ROWCOUNT > 0)
                        BEGIN
                            SET @DOPDAlreadyUpdated = 1;
                        END;

                        DECLARE @PromoName NVARCHAR(50) = N'';
                        DECLARE @CostId INT = 0;

                        SET @CostId
                            = ISNULL(
                              (
                                  SELECT TOP 1
                                         Co.IdCost
                                  FROM [DeliveryBackOffice].[dbo].[Cost] Co WITH (NOLOCK)
                                  WHERE (
                                            (
                                                Co.GuideSerie = ISNULL(@GuideSerie, 'FD')
                                                AND Co.GuideNumber = @GuideNumber
                                            )
                                            OR
                                            (
                                                Co.ProductNumber = CONCAT(ISNULL(@GuideSerie, 'FD'), @GuideNumber)
                                                AND Co.GuideSerie IS NULL
                                                AND Co.GuideNumber IS NULL
                                            )
                                        )
                                        AND Co.RowStatus = 1
                                  ORDER BY Co.DateCreated DESC
                              ),
                              0
                                    );

                        SET @PromoName
                            = ISNULL(
                              (
                                  SELECT TOP 1
                                         IIF(LEN(CP.PromoDescription) > 100,
                                          SUBSTRING(CP.PromoDescription, 1, 99),
                                          CP.PromoDescription)
                                  FROM [DeliveryBackOffice].[dbo].[CatPromo] CP WITH (NOLOCK)
                                      INNER JOIN [DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH (NOLOCK)
                                          ON CP.IdPromo = PC.CatPromoId
                                  WHERE PC.PromoCouponSerie = @CouponSerie
                              ),
                              0
                                    );

                        IF (ISNULL(@CostId, 0) > 0)
                        BEGIN
                            -- Actuaizar nuevo valor a Cost
                            UPDATE [DeliveryBackOffice].[dbo].[Cost]
                            SET TotalAmount = @UpdatedValue,
                                TotalAmountPaid = @UpdatedValue
                            WHERE IdCost = @CostId;

                            -- Actuaizar nuevo valor a Cost
                            UPDATE [DeliveryBackOffice].[dbo].[CostDetail]
                            SET Amount = @UpdatedValue
                            WHERE IdCost = @CostId;
                        END;

                        IF (EXISTS
                        (
                            SELECT TOP 1
                                   1
                            FROM [DeliveryBackOffice].[dbo].[BreakdownOfPayment] BOP
                            WHERE BOP.IdCost = @CostId
                                  AND BOP.Description = @PromoName COLLATE Latin1_General_CI_AI
                                  AND BOP.RowStatus = 1
                        )
                           )
                        BEGIN

                            UPDATE [DeliveryBackOffice].[dbo].[BreakdownOfPayment]
                            SET RowStatus = 1,
                                Amount = IIF(@UpdatedValue <= 0,
                                             -@OldPriceshipment,
                                             - (@OldPriceshipment - @UpdatedValue)),
                                DateUpdated = GETDATE(),
                                TokenUpdated = @TokenCreated,
                                PromoCouponId =
                                (
                                    SELECT TOP 1
                                           PC.IdPromoCoupon
                                    FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PC
                                    WHERE PC.PromoCouponSerie = @CouponSerie
                                )
                            WHERE IdCost = @CostId
                                  AND Description = @PromoName COLLATE Latin1_General_CI_AI;

                            IF (SCOPE_IDENTITY() > 0)
                                SET @CoUpdated = 1;

                        END;
                        ELSE
                        BEGIN

                            INSERT INTO [DeliveryBackOffice].[dbo].[BreakdownOfPayment]
                            (
                                IdCost,
                                Description,
                                Amount,
                                RowStatus,
                                DateCreated,
                                TokenCreated,
                                PromoCouponId
                            )
                            VALUES
                            (   @CostId, @PromoName,
                                IIF(@UpdatedValue <= 0, -@OldPriceshipment, - (@OldPriceshipment - @UpdatedValue)), 1,
                                GETDATE(), @TokenCreated,
                                (
                                    SELECT TOP 1
                                           PC.IdPromoCoupon
                                    FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PC
                                    WHERE PC.PromoCouponSerie = @CouponSerie
                                ));

                            IF (@@ROWCOUNT > 0)
                                SET @CoUpdated = 1;

                        END;
                    END;

                END;
            END TRY
            BEGIN CATCH

                INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
                (
                    DateCreated,
                    TokenCreated,
                    ErrorLine,
                    ErrorDescription,
                    ErrorProcedure
                )
                VALUES
                (GETDATE(), 'ERROR COUPON', ERROR_LINE(), ERROR_MESSAGE(), ERROR_PROCEDURE());


            END CATCH;

            BEGIN TRY

                IF (EXISTS (SELECT TOP 1 1 FROM @TblDeliveryOrdersList))
                BEGIN
                    -- Flujo de SetServiceRecoelct de filtro 2
                    DECLARE @ValidateTransaction INT =
                            (
                                SELECT DopId
                                FROM [DeliveryBackOffice].[dbo].DeliveryOrderPaymentTransaction do
                                    INNER JOIN @TblDeliveryOrdersList tpo
                                        ON do.GuideNumber = tpo.Guide_Number
                                           AND do.GuideSerie = tpo.Guide_Serie
                                           AND do.TypeServiceId = tpo.IdTypeService
                            );

                    IF (@ValidateTransaction IS NULL)
                    BEGIN

                        IF (@DOAlreadyUpdated = 0)
                        BEGIN

                            UPDATE dbo.DeliveryOrder
                            SET PriceShippment = IIF(t.PriceShippment <= 0, 0, t.PriceShippment),
                                StatusOrderId = 15,
                                IsCollect = t.IsCollect
                            FROM dbo.DeliveryOrder ord
                                INNER JOIN @TblDeliveryOrdersList t
                                    ON t.Guide_Number = ord.Guide_Number
                                       AND t.Guide_Serie = ord.Guide_Serie;

                        END;

                        IF (@DOPDAlreadyUpdated = 0)
                        BEGIN

                            UPDATE dbo.DeliveryOrderPaymentDetail
                            SET ShipmentCompleted = t.ShipmentCompleted,
                                PayTypeId = t.IdTypePayment,
                                TypeofInOutMoneyId = t.IdWayToPayment,
                                TimePlaId = t.IdTimePayment
                            FROM dbo.DeliveryOrderPaymentDetail pay
                                INNER JOIN @TblDeliveryOrdersList t
                                    ON (
                                           t.Guide_Number = pay.GuideNumber
                                           AND t.Guide_Serie = pay.GuideSerie
                                       );

                        END;

                        IF (@AccountId != 0)
                        BEGIN

                            IF (@UpdatedValue > 0)
                            BEGIN

                                INSERT INTO dbo.DeliveryOrderPaymentTransaction
                                (
                                    [GuideNumber],
                                    [GuideSerie],
                                    [PayTypeId],
                                    [TypeofInOutMoneyId],
                                    [TimePlaId],
                                    [amount],
                                    [PaymentRecollections],
                                    [PaymentNow],
                                    [PaymentDelivery],
                                    [StartDate],
                                    [EndDate],
                                    [ShipmentCompleted],
                                    [RecollectionCompleted],
                                    [PaidGuide],
                                    [TokenCreated],
                                    [DateCreated],
                                    [TokenUpdated],
                                    [DateUpdated],
                                    [TransaccionFAC],
                                    [IdHeaderRecolection],
                                    [TypeServiceId],
                                    [AccountId],
                                    [CODAmountProcess],
                                    [Fel],
                                    [VisitPoint]
                                )
                                SELECT Guide_Number,
                                       Guide_Serie,
                                       IdTypePayment,
                                       IdWayToPayment,
                                       IdTimePayment,
                                       tdop.PriceShippment,
                                       tdop.PaymentRecollections,
                                       tdop.PaymentNow,
                                       tdop.PaymentDelivery,
                                       NULL,
                                       NULL,
                                       tdop.ShipmentCompleted,
                                       tdop.RecollectionCompleted,
                                       tdop.PaidGuide,
                                       @TokenCreated,
                                       GETDATE(),
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       tdop.IdTypeService,
                                       IIF(@AccountId = 0, NULL, @AccountId),
                                       tdop.CODAmountProccess,
                                       NULL,
                                       IIF(@VisitPointClientIdByUser = 0, NULL, @VisitPointClientIdByUser)
                                FROM @TblDeliveryOrdersList tdop
                                WHERE tdop.PriceShippment != 0
                                      OR tdop.CODAmountProccess != 0;

                            END;
                        END;

                    END;
                END;
            END TRY
            BEGIN CATCH

                INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
                (
                    DateCreated,
                    TokenCreated,
                    ErrorLine,
                    ErrorDescription,
                    ErrorProcedure
                )
                VALUES
                (GETDATE(), 'ERROR FILTER 2', ERROR_LINE(), ERROR_MESSAGE(), ERROR_PROCEDURE());

            END CATCH;

		END

		COMMIT TRANSACTION;

        SELECT 200 Code,
               'Success' Description,
               (
                   SELECT TOP 1 CouponSerie FROM @CouponDataReponse
               ) coupSerie,
               (
                   SELECT TOP 1
                          CONVERT(NVARCHAR, CouponFinalDate, 103)
                   FROM @CouponDataReponse
               ) coupDate,
               (
                   SELECT TOP 1 CouponPromo FROM @CouponDataReponse
               ) coupPromo;

    END TRY
    BEGIN CATCH

		ROLLBACK TRANSACTION;

        INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
        (
            DateCreated,
            TokenCreated,
            ErrorLine,
            ErrorDescription,
            ErrorProcedure
        )
        VALUES
        (GETDATE(), 'ERROR TC', ERROR_LINE(), ERROR_MESSAGE(), ERROR_PROCEDURE());

        SELECT 'Error al procesar transacción' AS message,
               'FALSE' blnResult,
               CAST(-1 AS VARCHAR(5)) IdResult,
               CAST(500 AS VARCHAR(5)) StatusResult,
               CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber,
               CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity,
               CAST(ERROR_STATE() AS VARCHAR) AS ErrorState,
               CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure,
               CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine,
               CAST(ERROR_MESSAGE() AS VARCHAR(MAX)) AS ResultMessage;

    END CATCH;

END;
