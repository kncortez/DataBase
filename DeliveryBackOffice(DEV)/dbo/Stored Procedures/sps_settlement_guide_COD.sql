-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-11-25>
-- Description:	<Registrar transacción de liquidación (cobro) de guías en área de COD>
-- =============================================
-- Author:		<Oscar, Rodriguez>
-- Create date: <2020-12-12>
-- Description:	<Se agrego actualizacion de estado COBRADO para guias COD Anticipado>
-- =============================================
-- Author:		<Walter, Orozco>
-- Create date: <2025-09-10>
-- Description:	<Se agrega información que relaciona depositos de Efectibox con los manifiestos>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_guide_COD]
    @GuideSerie NVARCHAR(2),
    @GuideNumbers NVARCHAR(MAX),
    @Token NVARCHAR(50),
    @IdDeliveryOrderBySettlement INT,
    @Money TblMoneyByDeliveryOrderBySettlement READONLY,
    @IsIncident BIT,
    @Type VARCHAR(10),
    @Value DECIMAL(10, 2),
    @Description NVARCHAR(500),
    @GuideQuantityCOD INT,
	@CountryId NVARCHAR(5) = 'GT',
	@RouteId INT = 0,
	@TotalNumberOfPieces INT = 0,
	@CatManifestSettlementIncidenceTypeId INT = 0,
	@Deposits TblDeposit READONLY
AS
BEGIN
    -- control transacción
    DECLARE @ValidateOperation INT = 0;
    -- cantidad de veces que aparece el registro
    DECLARE @Times INT = 0;
    -- control de guías a manipular
    DECLARE @GuidesTable AS TABLE
    (
        Guide_Number INT
    );
    -- control de guía a iterar
    DECLARE @GuideNumber INT;
    -- CourierId de la guía a iterar
    DECLARE @CourierId INT;
    -- CatModuleId del modulo
    DECLARE @CatModuleId INT;
    -- Detecta si una guia tiene COD
    DECLARE @IsCOD BIT;

	
    BEGIN TRANSACTION;

    BEGIN TRY

        IF OBJECT_ID('tempdb.dbo.#GuidesTemp', 'U') IS NOT NULL
            DROP TABLE #GuidesTemp;

        IF OBJECT_ID('tempdb..#TempData') IS NOT NULL
            DROP TABLE #TempData;

        CREATE TABLE #TempData
        (
         IdProcessedGuideCOD INT,
         GuideSerie          NVARCHAR(4),
         GuideNumber         INT
        );
        CREATE NONCLUSTERED INDEX INDX_sps_settlement_guide_COD_Temp ON #TempData (GuideSerie, GuideNumber);

        -- Convertir la lista de guías separadas por coma en una tabla
        INSERT @GuidesTable
        SELECT CAST(Item AS INT)
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@GuideNumbers, ',');

        -- actualizar guía debido al proceso de liquidación
        UPDATE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]
        SET GuideDischarged_TokenCreated = @Token,
            GuideDischarged_DateCreated = GETDATE(),
            Guide_Discharged = 1 -- guía liquidada en COD
        WHERE Guide_Serie = @GuideSerie
              AND Guide_Number IN
                  (
                      SELECT Guide_Number FROM @GuidesTable
                  )
              AND Guide_Settlement = 1; -- guía liquidada previamente en bodega

        IF COALESCE(@@rowcount, 0) > 0
		BEGIN
            SET @ValidateOperation = @ValidateOperation + 1;
		END

        -- insertar guía en la tabla de guías procesadas COD
        -- Se insertar guías en tabla temporal
        SELECT *
        INTO #GuidesTemp
        FROM @GuidesTable;

        --Buscar ID modulo liquidación COD
        SET @CatModuleId = ISNULL(
                           (
                               SELECT ModIdModule FROM CatModule WHERE ModName = 'Liquidación COD'
                           ),
                           0
                                 );

        -- mientras la tabla no este vacía
        WHILE EXISTS (SELECT * FROM #GuidesTemp)
        BEGIN
            -- se obtiene la guía a iterar
            SELECT TOP 1
                   @GuideNumber = Guide_Number
            FROM #GuidesTemp;

            -- se verifica que no exita en las guías procesadas
            IF NOT EXISTS
            (
                SELECT 1
                FROM [dbo].[ProcessedGuideCOD] WITH (NOLOCK)
                WHERE GuideSerie = @GuideSerie AND  [GuideNumber] = @GuideNumber
            )
            BEGIN
                -- se obtiene el id del courierman
                SELECT TOP 1
                       @CourierId = ID_Courier
                FROM [dbo].[DeliveryAttempt] WITH (NOLOCK)
                WHERE [Guide_Serie] = @GuideSerie
                      AND [Guide_Number] = @GuideNumber
				ORDER BY Date_Created DESC;

                -- se inserta en las guías procesadas si contine COD 
                INSERT INTO [dbo].[ProcessedGuideCOD]
                (
                    [GuideSerie],
                    [GuideNumber],
                    [CourierManId],
                    [Date],
                    [BatchCODId],
                    [BatchCODIdCommission],
                    [DataOriginId],
                    [Notificated],
                    [Token],
                    CustomerId,
					IsAnticipatedCOD
                )
                OUTPUT inserted.IdProcessedGuideCOD,
                       inserted.GuideSerie,
                       inserted.GuideNumber
                  INTO #TempData
                SELECT do.[Guide_Serie],
                       do.[Guide_Number],
                       @CourierId,
                       GETDATE(),
                       NULL,
                       NULL,
                       @CatModuleId,
                       0,
                       @Token,
                       cus.IdCustomer,
					   0 AS 'IsAnticipatedCOD'
                FROM [dbo].[DeliveryOrder] do WITH (NOLOCK)
                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                        ON vp.CodeOfReference = do.Sender_ID
                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                        ON cus.IdCustomer = ISNULL(do.IdCustomer, vp.CustomerID)
                WHERE do.[Guide_Serie] = @GuideSerie
                      AND do.[Guide_Number] = @GuideNumber
                      AND do.[Collect_OnDelivery] > 0
					 AND do.IsLastMileReturn =0
                UNION
                SELECT do.[Guide_Serie],
                       do.[Guide_Number],
                       @CourierId,
                       GETDATE(),
                       NULL,
                       NULL,
                       @CatModuleId,
                       0,
                       @Token,
                       cus.IdCustomer,
					   0 AS 'IsAnticipatedCOD'
                FROM [dbo].[DeliveryOrder] do WITH (NOLOCK)
                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                        ON vp.CodeOfReference = do.Sender_ID
                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                        ON cus.IdCustomer = ISNULL(do.IdCustomer, vp.CustomerID)
                WHERE do.[Guide_Serie] = @GuideSerie
                      AND do.[Guide_Number] = @GuideNumber
                      AND do.[Collect_OnDelivery] = 0 
                      AND do.IsCollect = 1
                UNION
                SELECT do.[Guide_Serie],
                       do.[Guide_Number],
                       @CourierId,
                       GETDATE(),
                       NULL,
                       NULL,
                       @CatModuleId,
                       0,
                       @Token,
                       cus.IdCustomer,
					   0 AS 'IsAnticipatedCOD'
                FROM [dbo].[DeliveryOrder] do WITH (NOLOCK)
                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                        ON vp.CodeOfReference = do.Sender_ID
                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                        ON cus.IdCustomer = ISNULL(do.IdCustomer, vp.CustomerID)
                    INNER JOIN dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
                        ON do.Guide_Serie = DOP.GuideSerie
                           AND do.Guide_Number = DOP.GuideNumber
                WHERE do.[Guide_Serie] = @GuideSerie
                      AND do.[Guide_Number] = @GuideNumber
                      AND do.IsCollect = 0
                      AND DOP.TimePlaId = 2;
            END;

            --- Se agrega nuevo checkpoint

            SET @IsCOD = CASE
                             WHEN
                             (
                                 SELECT Collect_OnDelivery
                                 FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
                                 WHERE Guide_Serie = @GuideSerie 
                                   AND Guide_Number = @GuideNumber
                             ) > 0 THEN
                                 1
                             ELSE
                                 0
                         END;

            IF (@IsCOD = 1)
            BEGIN


			DECLARE @Isreturn bit  =0

			SELECT @Isreturn = ord.IsLastMileReturn FROM dbo.DeliveryOrder ord WITH(NOLOCK)
			WHERE ord.Guide_Serie = @GuideSerie AND ord.Guide_Number = @GuideNumber

			IF @Isreturn = 1

				BEGIN

                --Actualiza es stado a "COD liquidado" en tabla DeliveryOrder si la guia tuviera COD
                UPDATE DeliveryBackOffice.dbo.DeliveryOrder
                SET StatusOrderId = 24
                WHERE Guide_Serie = @GuideSerie 
                  AND Guide_Number = @GuideNumber;

                --Actualiza es stado a "COD liquidado" en tabla DeliveryOrderDetail si la guia tuviera COD

                INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                (
                    Guide_Serie,
                    Guide_Number,
                    StatusOrderId,
                    UserCreated,
                    DateCreated
                )
                VALUES
                (@GuideSerie, @GuideNumber, 24, @Token, GETDATE());

			END;

            END;

			-- Actualizamos guia liquidada cod anticipado a estado de balance COBRADO
				IF EXISTS
				(
					SELECT 1
					FROM DeliveryBackOffice.dbo.AnticipatedCODDetail acd WITH(NOLOCK)
					WHERE	GuideSerie = @GuideSerie AND acd.GuideNumber = @GuideNumber
				)
				BEGIN
					UPDATE DeliveryBackOffice.dbo.AnticipatedCODDetail
					SET BalanceStatus = 'COBRADO',
					DateUpdated = GETDATE(),
					TokenUpdated = @Token
					WHERE	GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber;
						
                    DECLARE @TempData TblAnticipatedCODCustomerBalance;

					INSERT INTO @TempData
					(
						CustomerId,
						PortfolioId
					)
					SELECT ach.CustomerId, ach.PortfolioId
					FROM DeliveryBackOffice.dbo.AnticipatedCODDetail acd WITH(NOLOCK)
					INNER JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH(NOLOCK) 
						ON ach.IdAnticipatedCODHeader = acd.AnticipatedCODHeaderId
					WHERE	ACD.GuideSerie = @GuideSerie AND acd.GuideNumber = @GuideNumber

					EXEC spUpdateBalanceByIdClient @TempData

                    DELETE 
                      FROM @TempData
				END

            -- se elimina la guía de la tabla temporal
            DELETE #GuidesTemp
            WHERE Guide_Number = @GuideNumber;
        END;

        --Se realiza el registro de las denominaciones
        INSERT INTO [dbo].[MoneyByDeliveryOrderBySettlement]
        SELECT IdCatMoney,
               @IdDeliveryOrderBySettlement,
               Quantity
        FROM @Money
        WHERE Quantity IS NOT NULL
              AND Quantity > 0;

		IF COALESCE(@@rowcount, 0) > 0
		BEGIN
            SET @ValidateOperation = @ValidateOperation + 1;
		END

		--=================================================================
		--======== Guardar depositos y relacion con su manifiesto =========
		--=================================================================

		IF EXISTS (SELECT 1 FROM @Deposits)
		BEGIN
			DECLARE @DepositSummary TABLE
			(
				TransactionNumber BIGINT PRIMARY KEY,
				ExistsDeposit     BIT         NOT NULL,
				Applied           DECIMAL(19,4) NOT NULL
			);

			INSERT INTO @DepositSummary (TransactionNumber, ExistsDeposit, Applied)
			SELECT
				p.TransactionNumber,
				CASE WHEN d.IdDeposit IS NULL THEN 0 ELSE 1 END AS ExistsDeposit,
				 CASE
					WHEN d.IdDeposit IS NOT NULL 
						THEN (d.Balance - p.Balance)	-- existe
						ELSE (p.Amount - p.Balance)		-- nuevo
				END AS Applied
			FROM @Deposits AS p
			LEFT JOIN DeliveryBackOffice.dbo.Deposit AS d WITH(NOLOCK)
				ON d.TransactionNumber = p.TransactionNumber;

			IF EXISTS (SELECT 1 FROM @DepositSummary WHERE Applied <= 0)
			BEGIN

				--Caso en que el monto a aplicar sea mayor al saldo actual
				SET @ValidateOperation = 1; 
			END
			ELSE
			BEGIN

				--Ingresar depositos existentes
				IF EXISTS (SELECT 1 FROM @DepositSummary WHERE ExistsDeposit = 1)
				BEGIN

					UPDATE d
					SET  d.Balance      = dp.Balance,
						 d.TokenUpdated = @Token,
						 d.DateUpdated  = GETDATE()
					FROM dbo.Deposit AS d WITH(NOLOCK)
					INNER JOIN @DepositSummary AS s
					  ON s.TransactionNumber = d.TransactionNumber
					INNER JOIN @Deposits AS dp
					  ON dp.TransactionNumber = d.TransactionNumber
					WHERE dp.Balance IS NOT NULL AND s.ExistsDeposit = 1;

				END
				--Ingresar depositos nuevos
				IF EXISTS (SELECT 1 FROM @DepositSummary WHERE ExistsDeposit = 0)
				BEGIN

					INSERT INTO dbo.Deposit
					(
						TransactionNumber, TransactionDate, TransactionCode, Reference,
						Amount, Balance,
						UserIdDeposit, UserNameDeposit, UserNickNameDeposit, UserDocumentNumber,
						CurrencyISO, CurrencyIdExternal, ClientIdExternal, ClientCardCode, ClientNameExternal,
						VisitPointIdExternal, VisitPointName,
						BankIdExternal, BankCardCode, BankNameExternal, BankAccountNumber,
						BankAccountIsMak, BankAccountIsIBAN, BankAccountIsSWIFT,
						TerminalId, TerminalSerie,
						RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated
					)
					SELECT
						dp.TransactionNumber, dp.TransactionDate, dp.TransactionCode, dp.Reference,
						dp.Amount, dp.Balance,
						dp.UserIdDeposit, dp.UserNameDeposit, dp.UserNickNameDeposit, dp.UserDocumentNumber,
						dp.CurrencyISO, dp.CurrencyIdExternal, dp.ClientIdExternal, dp.ClientCardCode, dp.ClientNameExternal,
						dp.VisitPointIdExternal, dp.VisitPointName,
						dp.BankIdExternal, dp.BankCardCode, dp.BankNameExternal, dp.BankAccountNumber,
						dp.BankAccountIsMak, dp.BankAccountIsIBAN, dp.BankAccountIsSWIFT,
						dp.TerminalId, dp.TerminalSerie,
						1, @Token, GETDATE(), NULL, NULL
					FROM @Deposits AS dp
					INNER JOIN @DepositSummary AS s
						ON s.TransactionNumber = dp.TransactionNumber
					WHERE s.ExistsDeposit = 0 AND dp.Balance IS NOT NULL;

				END

				--Relacion entre manifiesto y deposito
				INSERT INTO dbo.RelDepositManifest
				(
					IdDeposit,
					DeliveryOrderBySettlementId,
					AmountApplied,
					RowStatus,
					TokenCreated,
					DateCreated,
					TokenUpdated,
					DateUpdated
				)
				SELECT
					D.IdDeposit,
					@IdDeliveryOrderBySettlement,
					S.Applied,
					1,
					@Token,
					GETDATE(),
					NULL,
					NULL
				FROM @DepositSummary AS S
				INNER JOIN @Deposits AS DP
					ON DP.TransactionNumber = S.TransactionNumber
				INNER JOIN DeliveryBackOffice.dbo.Deposit AS D WITH(NOLOCK)
					ON S.TransactionNumber = D.TransactionNumber
				WHERE S.Applied > 0;

				--Aplicar valor para continuar flujo del sp
				IF COALESCE(@@rowcount, 0) > 0
				BEGIN
					IF @ValidateOperation < 2
					BEGIN
						SET @ValidateOperation = @ValidateOperation + 1;
					END
				END;
			END;
		END;

		--=================================================================
		--===== Fin de Guardar depositos y relacion con su manifiesto =====
		--=================================================================

        --Si se presenta una contingencia se registra
        IF @IsIncident = 1
        BEGIN

			SELECT @CourierId = ID_Courier FROM DeliveryOrderBySettlement WHERE ID = @IdDeliveryOrderBySettlement

            INSERT INTO [dbo].[Contingency]
            (
                [DeliveryOrderBySettlementId],
                [Type],
                [Value],
                [Description],
                [TokenCreated],
                [DateCreated]
            )
            VALUES
            (@IdDeliveryOrderBySettlement, @Type, @Value, @Description, @Token, GETDATE());

			INSERT INTO [dbo].[ManifestSettlementIncidence]
			   ([CatRouteId]
			   ,[CourierId]
			   ,[ManifestNumber]
			   ,[TotalAmount]
			   ,[GuidesQuantity]
			   ,[TotalNumberOfPieces]
			   ,[IncidenceApproved]
			   ,[IdValidator]
			   ,[CatManifestSettlementIncidenceTypeId]
			   ,[IncidenceComment]
			   ,[ResolutionComment]
			   ,[CountryId]
			   ,[RowStatus]
			   ,[DateCreated]
			   ,[TokenCreated]
			   ,[isCOD])
		 VALUES
			   (@RouteId
			   ,@CourierId
			   ,@IdDeliveryOrderBySettlement
			   ,@Value
			   ,@GuideQuantityCOD
			   ,@TotalNumberOfPieces
			   ,0
			   ,NULL
			   ,@CatManifestSettlementIncidenceTypeId
			   ,@Description
			   ,NULL
			   ,@CountryId
			   ,1
			   ,GETDATE()
			   ,@Token
			   ,1)

            IF COALESCE(@@rowcount, 0) > 0
			BEGIN
                SET @ValidateOperation = @ValidateOperation + 1;
			END

        END;
        ELSE
        BEGIN
            SET @ValidateOperation = @ValidateOperation + 1;
        END;
		
        -- Actualizar registro en control de manifiestos de despacho
        UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]
        SET User_Received_COD = @Token,
            Date_Received_COD = GETDATE(),
            Guides_Received_COD = @GuideQuantityCOD,
            Route_Received_COD = GETDATE()
        WHERE ID = @IdDeliveryOrderBySettlement;
		
        IF COALESCE(@@rowcount, 0) > 0
		BEGIN
            SET @ValidateOperation = @ValidateOperation + 1;
	    END
    END TRY
    BEGIN CATCH
		SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID';
        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@trancount > 0
    BEGIN
        IF (@ValidateOperation = 4)
        BEGIN
            SELECT 1 AS 'StatusCode',
                   'Registro guardado correctamente' AS 'Description',
                   @@trancount AS 'NumTransferID';
            COMMIT TRANSACTION;

        UPDATE pgd 
           SET pgd.IsCompleted = 1
          FROM ProcessedGuideCOD pgd WITH(NOLOCK)
               INNER JOIN #TempData tmp
                  ON pgd.GuideSerie   = tmp.GuideSerie
                 AND pgd.GuideNumber = tmp.GuideNumber
                 AND pgd.IdProcessedGuideCOD = tmp.IdProcessedGuideCOD;

        IF OBJECT_ID('tempdb..#TempData') IS NOT NULL
            DROP TABLE #TempData;
        END;
        ELSE
        BEGIN
            SELECT 0 AS 'StatusCode',
                   'Registro no guardado' AS 'Description',
                   0 AS 'NumTransferID';
            ROLLBACK TRANSACTION;
        END;
    END;
    ELSE
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               CONVERT(BIGINT, 0) AS 'NumTransferID';
END;