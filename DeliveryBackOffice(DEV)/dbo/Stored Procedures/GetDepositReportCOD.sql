--EXEC GetDepositReportCOD_Generic -1,-1,'2021-10-01','2021-12-01',-1, 'ivan.mendoza@forzalatam.com'
-- =============================================
-- Author:		<Marco Jiménez>
-- Create date: <2021-10-19>
-- Description:	<Guias por pagar COD>
-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-07-09>
-- Description: <Se agrego campo de moneda para mostrar en reporte de depositos>
-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-07-12>
-- Description: <Se realizo un ajuste para optimizar el tiempo del query para opción 1>
-- =============================================
-- Author:      <Oscar Rodriguez>
-- Create date: <2025-08-14>
-- Description: <Se agrego optimizacion realizada por DBA>
-- =============================================
CREATE PROCEDURE [dbo].[GetDepositReportCOD]
    -- Add the parameters for the stored procedure here
    @IdCustomer INT = -1,
    @IdBank INT = -1,
    @SenderEmail VARCHAR(MAX) = '0'
AS
BEGIN
    --DECLARE @IdCustomer INT = -1;
    --DECLARE @IdBank INT = -1;
    --DECLARE @SenderEmail VARCHAR(MAX) = '0;
    IF (@IdCustomer > 0)    
	BEGIN

		IF OBJECT_ID('tempdb.dbo.#TempBatchDetailCOD', 'U') IS NOT NULL
			DROP TABLE #TempBatchDetailCOD;

		CREATE TABLE #TempBatchDetailCOD (
			IdBatchDetailCOD INT,
			AuthorizationDate DATETIME
		);

		CREATE NONCLUSTERED INDEX TMP_IDX_TempBatchDetailCOD_IdBatch ON #TempBatchDetailCOD (IdBatchDetailCOD)

		INSERT INTO #TempBatchDetailCOD
			(IdBatchDetailCOD, AuthorizationDate)
		SELECT
			btd.IdBatchDetailCOD,
			btd.AuthorizationDate
		FROM [DeliveryBackOffice].[dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[ProcessedGuideCOD] AS pg WITH (NOLOCK)
                ON btd.[GuideSerie] = pg.[GuideSerie]
                    AND btd.[GuideNumber] = pg.[GuideNumber]
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] AS do WITH (NOLOCK)
                ON btd.[GuideSerie] = do.[Guide_Serie]
                    AND btd.[GuideNumber] = do.[Guide_Number]
            LEFT JOIN [DeliveryBackOffice].dbo.VisitPointClient vpc WITH (NOLOCK)
                ON vpc.CodeOfReference = do.Sender_ID
            LEFT JOIN [DeliveryBackOffice].dbo.Customer cu WITH (NOLOCK)
                ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
        WHERE pg.[Notificated] = 0
                AND btd.[AuthorizationNumber] IS NOT NULL
                AND pg.BatchCODId IS NOT NULL
                AND (cu.IdCustomer = @IdCustomer)
                AND
                (
                    btd.BankId = @IdBank
                    OR @IdBank = -1
                )

		DECLARE @TypeCustomer INT = 0;
        SELECT @TypeCustomer = IdCustomerType 
        FROM Customer WITH (NOLOCK) 
        WHERE IdCustomer = @IdCustomer;

        IF (@TypeCustomer != 2)
        BEGIN
            -- Create a temp table to store intermediate results
            CREATE TABLE #FilteredBatches (
                IdBatchDetailCOD INT,
                GuideSerie VARCHAR(50),
                GuideNumber VARCHAR(50),
                BankName VARCHAR(100),
                AccountNumber VARCHAR(100),
                AuthorizationNumber VARCHAR(100),
                Commission DECIMAL(18,2),
                CODCommissionPercentage DECIMAL(18,2),
                Amount DECIMAL(18,2),
                BankId INT,
                AuthorizationDate DATETIME,
				CatCurrencyCODId INT
            );

            -- First filter the BatchDetailCOD table with the most restrictive conditions
            INSERT INTO #FilteredBatches
            SELECT 
                btd.IdBatchDetailCOD,
                btd.GuideSerie,
                btd.GuideNumber,
                btd.BankName,
                btd.AccountNumber,
                btd.AuthorizationNumber,
                btd.Commission,
                btd.CODCommissionPercentage,
                btd.Amount,
                btd.BankId,
                TBDC.AuthorizationDate,
				btd.CatCurrencyCODId
            FROM [DeliveryBackOffice].[dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
            LEFT JOIN #TempBatchDetailCOD TBDC ON btd.IdBatchDetailCOD = TBDC.IdBatchDetailCOD
            INNER JOIN [DeliveryBackOffice].[dbo].[ProcessedGuideCOD] AS pg WITH (NOLOCK)
                ON btd.GuideSerie = pg.GuideSerie
                AND btd.GuideNumber = pg.GuideNumber
            WHERE pg.Notificated = 0
                AND btd.AuthorizationNumber IS NOT NULL
                AND pg.BatchCODId IS NOT NULL
                AND (btd.BankId = @IdBank OR @IdBank = -1);

            -- Create indexes on the temp table
            CREATE CLUSTERED INDEX IX_FB_Guides ON #FilteredBatches (GuideSerie, GuideNumber);
            CREATE NONCLUSTERED INDEX IX_FB_ID ON #FilteredBatches (IdBatchDetailCOD);

            -- Now join with the remaining tables
            SELECT 
                cu.IdCustomer AS IdCliente,
                cu.Name AS Cliente,
                COALESCE(cu.CODContactEmail, REPLACE(REPLACE(cu.RegexEmail, '^', ''), '$', '')) AS Correo,
                fb.BankName AS Banco,
                fb.AccountNumber AS Cuenta,
                CONCAT(fb.GuideSerie, fb.GuideNumber) AS GuideNumber,
                (do.Pieces_Dry + do.Pieces_Cold) AS Piezas,
                ISNULL((peso.peso), 0) AS Peso,
                ISNULL(prv.ProvinceName, pr.ProvinceName) AS Departamento,
                ISNULL(twn.TownshipName, tw.TownshipName) AS Municipio,
                CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) AS Receiver,
                FORMAT(arrival.DateCreated, 'dd/MM/yyyy hh:mm:ss tt') AS FechaArribo,
                FORMAT(delivery.DateCreated, 'dd/MM/yyyy hh:mm:ss tt') AS FechaEntrega,
                FORMAT(fb.AuthorizationDate, 'dd/MM/yyyy hh:mm:ss tt') AS FechaPago,
                fb.AuthorizationNumber AS NoDeposito,
                do.Collect_OnDelivery AS CODAmount,
                IIF(do.TypeService = 'EXP', 'NDD', ISNULL(do.TypeService, 'NDD')) AS TypeService,
                IIF(do.IsCollect = 'true', 'Collect',
                    IIF(ISNULL(cu.ConditionOfPaymentID, 0) > 1, 'Crédito', 'Prepago')) AS TipodePago,
                do.PriceShippment AS ShippmentAmount,
                fb.Commission AS CommissionAmount,
                fb.CODCommissionPercentage AS PorcentajeComision,
                fb.Amount + fb.Commission AS ChargedAmount,
                fb.Amount AS TotalAmount,
                IIF(fb.BankId IN (3, 5, 31, 33, 1), 1, 0) AS FlagImmediateOrAch,
                fb.AuthorizationDate,
                ISNULL(DATEDIFF(DAY, arrival.DateCreated, delivery.DateCreated), 0) AS DiasEntrega,
                ISNULL(DATEDIFF(DAY, delivery.DateCreated, fb.AuthorizationDate), 0) AS DiasPago,
                ccc.Symbol AS CurrencyOrder
            FROM #FilteredBatches fb
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] AS do WITH (NOLOCK)
                ON fb.GuideSerie = do.Guide_Serie
                AND fb.GuideNumber = do.Guide_Number
            LEFT JOIN [DeliveryBackOffice].dbo.Township twn WITH (NOLOCK)
                ON twn.IdTownship = do.ReceiverIdTownship
            OUTER APPLY (
                SELECT TOP 1 TW.IdProvince, TW.TownshipName  
                FROM [DeliveryBackOffice].dbo.Township tw WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].dbo.Province PR WITH(NOLOCK) ON PR.IdProvince = tw.IdProvince
                WHERE TW.TownshipName = DO.Receiver_Town 
                AND PR.IdCountry = DO.ReceiverCountryId
            ) tw
            LEFT JOIN [DeliveryBackOffice].dbo.Province prv WITH (NOLOCK)
                ON prv.IdProvince = twn.IdProvince
            LEFT JOIN [DeliveryBackOffice].dbo.Province pr WITH (NOLOCK)
                ON pr.IdProvince = tw.IdProvince
            LEFT JOIN [DeliveryBackOffice].dbo.VisitPointClient vpc WITH (NOLOCK)
                ON vpc.CodeOfReference = do.Sender_ID
            LEFT JOIN [DeliveryBackOffice].dbo.Customer cu WITH (NOLOCK)
                ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
            OUTER APPLY (
                SELECT TOP 1 DateCreated
                FROM [DeliveryBackOffice].dbo.DeliveryOrderDetail WITH (NOLOCK)
                WHERE Guide_Serie = do.Guide_Serie
                AND Guide_Number = do.Guide_Number
                AND StatusOrderId IN (11, 2)
            ) arrival
            OUTER APPLY (
                SELECT SUM(ISNULL(dp.MassWeight, dp.PieceWeight)) AS peso
                FROM [DeliveryBackOffice].dbo.DeliveryOrderPiece dp WITH (NOLOCK)
                WHERE dp.GuideSerie = do.Guide_Serie
                AND dp.GuideNumber = do.Guide_Number
            ) peso
            OUTER APPLY (
                SELECT TOP 1 DateCreated
                FROM [DeliveryBackOffice].dbo.DeliveryOrderDetail WITH (NOLOCK)
                WHERE Guide_Serie = do.Guide_Serie
                AND Guide_Number = do.Guide_Number
                AND StatusOrderId IN (5, 22)
            ) delivery
            LEFT JOIN [DeliveryBackOffice].dbo.CatCurrencyCOD ccc WITH (NOLOCK)
                ON fb.CatCurrencyCODId = ccc.IdCatCurrencyCOD
            WHERE cu.IdCustomer = @IdCustomer
            ORDER BY fb.AuthorizationDate ASC;

            DROP TABLE #FilteredBatches;
        END
			 ELSE
			    BEGIN
					SELECT 
							s1.IdCliente
							,s1.Cliente
							,s1.Correo
							,s1.Banco
							,s1.Cuenta
							,s1.GuideNumber
							,s1.Piezas
							,s1.Peso
							,s1.Departamento
							,s1.Municipio
							,s1.Receiver
							,FORMAT(s1.FechaArribo, 'dd/MM/yyyy hh:mm:ss tt' ) 'FechaArribo'
							,FORMAT(s1.FechaEntrega, 'dd/MM/yyyy hh:mm:ss tt' ) 'FechaEntrega'
							,FORMAT(s1.FechaPago, 'dd/MM/yyyy hh:mm:ss tt' ) 'FechaPago'
							,s1.NoDeposito
							,s1.CODAmount
							,s1.TypeService
							,s1.TipodePago
							,s1.ShippmentAmount
							,s1.CommissionAmount
							,s1.PorcentajeComision
							,s1.ChargedAmount
							,s1.TotalAmount
							,s1.FlagImmediateOrAch
							,s1.AuthorizationDate
						   ,ISNULL(DATEDIFF(DAY, CONVERT(DATE, s1.FechaArribo, 103), CONVERT(DATE, s1.FechaEntrega, 103)), 0) AS DiasEntrega
						   ,ISNULL(DATEDIFF(DAY, CONVERT(DATE, s1.FechaEntrega, 103), CONVERT(DATE, s1.FechaPago, 103)), 0) AS DiasPago
                           ,CurrencyOrder
					FROM
					(
						SELECT cu.[IdCustomer] IdCliente,
							   cu.[Name] Cliente,
							   COALESCE(cu.CODContactEmail, REPLACE(REPLACE(cu.[RegexEmail], '^', ''), '$', '')) Correo,
							   btd.BankName Banco,
							   btd.AccountNumber Cuenta,
							   CONCAT(btd.[GuideSerie], btd.[GuideNumber]) GuideNumber,
							   (do.Pieces_Dry + do.Pieces_Cold) Piezas,
							   (
								   SELECT SUM(ISNULL(dp.MassWeight, dp.PieceWeight))
								   FROM [DeliveryBackOffice].dbo.DeliveryOrderPiece dp WITH (NOLOCK)
								   WHERE dp.GuideSerie = do.Guide_Serie
										 AND dp.GuideNumber = do.Guide_Number
							   ) Peso,
							   ISNULL(prv.ProvinceName, pr.ProvinceName) Departamento,
							   ISNULL(twn.TownshipName, tw.TownshipName) Municipio,
							   CONCAT(do.[Receiver_FirstName], do.[Receiver_LastName]) AS Receiver,
                   
							   (
								   SELECT TOP 1
										  dt.DateCreated
								   FROM [DeliveryBackOffice].dbo.DeliveryOrderDetail dt WITH (NOLOCK)
								   WHERE dt.Guide_Serie = do.Guide_Serie
										 AND dt.Guide_Number = do.Guide_Number
										 AND dt.StatusOrderId IN ( 11, 2 )
							   ) FechaArribo,
                   
							   (
								   SELECT TOP 1
										  dt.DateCreated
								   FROM [DeliveryBackOffice].dbo.DeliveryOrderDetail dt WITH (NOLOCK)
								   WHERE dt.Guide_Serie = do.Guide_Serie
										 AND dt.Guide_Number = do.Guide_Number
										 AND dt.StatusOrderId IN (5,22)
							   ) FechaEntrega,
							   TBDC.[AuthorizationDate] FechaPago,
							   btd.[AuthorizationNumber] NoDeposito,
							   do.[Collect_OnDelivery] AS CODAmount,
							   IIF(do.[TypeService] = 'EXP', 'NDD', ISNULL(do.[TypeService], 'NDD')) TypeService,
							   IIF(do.IsCollect = 'true',
								   'Collect',
								   (IIF(ISNULL(cu.ConditionOfPaymentID, 0) > 1, 'Crédito', 'Prepago'))) TipodePago,
							   do.[PriceShippment] AS ShippmentAmount,
							   btd.[Commission] AS CommissionAmount,
							   btd.CODCommissionPercentage AS PorcentajeComision,
							   btd.[Amount] + btd.[Commission] AS ChargedAmount,
							   btd.[Amount] AS TotalAmount,
							   IIF(btd.BankId IN ( 3, 5, 31, 33, 1), 1, 0) FlagImmediateOrAch,
							   TBDC.[AuthorizationDate],
                               ccc.Symbol AS CurrencyOrder
						FROM [DeliveryBackOffice].[dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
							LEFT JOIN #TempBatchDetailCOD TBDC
								ON btd.IdBatchDetailCOD = TBDC.IdBatchDetailCOD
							INNER JOIN [DeliveryBackOffice].[dbo].[ProcessedGuideCOD] AS pg WITH (NOLOCK)
								ON btd.[GuideSerie] = pg.[GuideSerie]
								   AND btd.[GuideNumber] = pg.[GuideNumber]
							INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] AS do WITH (NOLOCK)
								ON btd.[GuideSerie] = do.[Guide_Serie]
								   AND btd.[GuideNumber] = do.[Guide_Number]
							LEFT JOIN [DeliveryBackOffice].dbo.Township twn WITH (NOLOCK)
								ON twn.IdTownship = do.ReceiverIdTownship
							OUTER APPLY
							( SELECT TOP 1 TW.IdProvince, TW.TownshipName  FROM  [DeliveryBackOffice].dbo.Township tw WITH (NOLOCK)
							INNER JOIN [DeliveryBackOffice].dbo.Province PR WITH(NOLOCK) ON PR.IdProvince = tw.IdProvince
							WHERE TW.TownshipName = DO.Receiver_Town AND PR.IdCountry = DO.ReceiverCountryId
							)tw
							LEFT JOIN [DeliveryBackOffice].dbo.Province prv WITH (NOLOCK)
								ON prv.IdProvince = twn.IdProvince
							LEFT JOIN [DeliveryBackOffice].dbo.Province pr WITH (NOLOCK)
								ON pr.IdProvince = tw.IdProvince
							LEFT JOIN [DeliveryBackOffice].dbo.VisitPointClient vpc WITH (NOLOCK)
								ON vpc.CodeOfReference = do.Sender_ID
							LEFT JOIN [DeliveryBackOffice].dbo.Customer cu WITH (NOLOCK)
								ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
							LEFT JOIN [DeliveryBackOffice].dbo.DeliveryCustomerBankAccount dc WITH (NOLOCK)
								ON dc.DCBA_Id = do.DCBA_ID
							LEFT JOIN [DeliveryBackOffice].dbo.DeliveryBank bk WITH (NOLOCK)
								ON bk.Id_bank = dc.DCBA_Bank_Id
                            LEFT JOIN [DeliveryBackOffice].dbo.CatCurrencyCOD ccc WITH (NOLOCK)
                                ON btd.CatCurrencyCODId = ccc.IdCatCurrencyCOD
						WHERE pg.[Notificated] = 0
							  AND btd.[AuthorizationNumber] IS NOT NULL
							  AND pg.BatchCODId IS NOT NULL
							  AND (cu.IdCustomer = @IdCustomer)
							  AND do.Sender_Mail = @SenderEmail
							  AND
							  (
								  btd.BankId = @IdBank
								  OR @IdBank = -1
							  )
					-- AND ISNULL(do.SalePipeLineId,4) NOT IN (3) Se comenta para poder retornar las guías de corporativos que sean realizadas en ExpressCenter
					--AND CAST(BTD.AuthorizationDate AS DATE)
					--BETWEEN CAST(@StarDate AS DATE) AND CAST(@EndDate AS DATE)
					) s1
					ORDER BY s1.[AuthorizationDate] ASC
					--OPTION (OPTIMIZE FOR UNKNOWN)
				END
		
		IF OBJECT_ID('tempdb.dbo.#TempBatchDetailCOD', 'U') IS NOT NULL
			DROP TABLE #TempBatchDetailCOD;

    END;
    ELSE IF (@SenderEmail != '-1')
    BEGIN

		IF OBJECT_ID('tempdb.dbo.#TempBatchDetailCOD_opt2', 'U') IS NOT NULL
			DROP TABLE #TempBatchDetailCOD_opt2;

		CREATE TABLE #TempBatchDetailCOD_opt2 (
			IdBatchDetailCOD INT,
			AuthorizationDate DATETIME
		);

		CREATE NONCLUSTERED INDEX TMP_IDX_TempBatchDetailCODopt2_IdBatch ON #TempBatchDetailCOD_opt2 (IdBatchDetailCOD)

		INSERT INTO #TempBatchDetailCOD_opt2
			(IdBatchDetailCOD, AuthorizationDate)
		SELECT
			btd.IdBatchDetailCOD,
			btd.AuthorizationDate
		FROM [DeliveryBackOffice].[dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[ProcessedGuideCOD] AS pg WITH (NOLOCK)
                ON btd.[GuideSerie] = pg.[GuideSerie]
                    AND btd.[GuideNumber] = pg.[GuideNumber]
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] AS do WITH (NOLOCK)
                ON btd.[GuideSerie] = do.[Guide_Serie]
                    AND btd.[GuideNumber] = do.[Guide_Number]
        WHERE pg.[Notificated] = 0
                AND btd.[AuthorizationNumber] IS NOT NULL
                AND pg.BatchCODId IS NOT NULL
                AND LTRIM(RTRIM(do.Sender_Mail)) = @SenderEmail
                AND
                (
                    btd.BankId = @IdBank
                    OR @IdBank = -1
                )
                
        SELECT 
				s1.IdCliente
				,s1.Cliente
				,s1.Correo
				,s1.Banco
				,s1.Cuenta
				,s1.GuideNumber
				,s1.Piezas
				,s1.Peso
				,s1.Departamento
				,s1.Municipio
				,s1.Receiver
				,s1.FechaArribo 'FechaArribo'
				,s1.FechaEntrega 'FechaEntrega'
				,s1.FechaPago 'FechaPago'
				
				,s1.NoDeposito
				,s1.CODAmount
				,s1.TypeService
				,s1.TipodePago
				,s1.ShippmentAmount
				,s1.CommissionAmount
				,s1.PorcentajeComision
				,s1.ChargedAmount
				,s1.TotalAmount
				,s1.FlagImmediateOrAch
				,s1.AuthorizationDate
               ,ISNULL(DATEDIFF(DAY, CONVERT(DATE, s1.FechaArribo, 103), CONVERT(DATE, s1.FechaEntrega, 103)), 0) AS DiasEntrega
               ,ISNULL(DATEDIFF(DAY, CONVERT(DATE, s1.FechaEntrega, 103), CONVERT(DATE, s1.FechaPago, 103)), 0) AS DiasPago,
                CurrencyOrder
        FROM
        (
            SELECT cu.[IdCustomer] IdCliente,
                   do.Sender_FirstName Cliente,
                   @SenderEmail Correo,
                   btd.BankName Banco,
                   btd.AccountNumber Cuenta,
                   CONCAT(btd.[GuideSerie], btd.[GuideNumber]) GuideNumber,
                   (do.Pieces_Dry + do.Pieces_Cold) Piezas,
                   (
                       SELECT SUM(ISNULL(dp.MassWeight, dp.PieceWeight))
                       FROM [DeliveryBackOffice].dbo.DeliveryOrderPiece dp WITH (NOLOCK)
                       WHERE dp.GuideSerie = do.Guide_Serie
                             AND dp.GuideNumber = do.Guide_Number
                   ) Peso,
                   ISNULL(prv.ProvinceName, pr.ProvinceName) Departamento,
                   ISNULL(twn.TownshipName, tw.TownshipName) Municipio,
                   CONCAT(do.[Receiver_FirstName], do.[Receiver_LastName]) AS Receiver,
                   FORMAT(
                   (
                       SELECT TOP 1
                              CONVERT(DATETIME,dt.DateCreated)
                       FROM [DeliveryBackOffice].dbo.DeliveryOrderDetail dt WITH (NOLOCK)
                       WHERE dt.Guide_Serie = do.Guide_Serie
                             AND dt.Guide_Number = do.Guide_Number
                             AND dt.StatusOrderId IN ( 11, 2 )
                   ),
                   'dd/MM/yyyy hh:mm:ss tt'
                         ) FechaArribo,
                   FORMAT(
                   (
                       SELECT TOP 1
                              CONVERT(DATETIME,dt.DateCreated)
                       FROM [DeliveryBackOffice].dbo.DeliveryOrderDetail dt WITH (NOLOCK)
                       WHERE dt.Guide_Serie = do.Guide_Serie
                             AND dt.Guide_Number = do.Guide_Number
                             AND dt.StatusOrderId IN (5,22)
                   ),
                   'dd/MM/yyyy hh:mm:ss tt'
                         ) FechaEntrega,
                   FORMAT(CONVERT(DATETIME,TBDC.[AuthorizationDate]), 'dd/MM/yyyy hh:mm:ss tt') FechaPago,
                   btd.[AuthorizationNumber] NoDeposito,
                   do.[Collect_OnDelivery] AS CODAmount,
                   IIF(do.[TypeService] = 'EXP', 'NDD', ISNULL(do.[TypeService], 'NDD')) TypeService,
                   IIF(do.IsCollect = 'true',
                       'Collect',
                       (IIF(ISNULL(cu.ConditionOfPaymentID, 0) > 1, 'Crédito', 'Prepago'))) TipodePago,
                   do.[PriceShippment] AS ShippmentAmount,
                   btd.[Commission] AS CommissionAmount,
                   btd.CODCommissionPercentage AS PorcentajeComision,
                   btd.[Amount] + btd.[Commission] AS ChargedAmount,
                   btd.[Amount] AS TotalAmount,
                   IIF(btd.BankId IN ( 3, 5, 31, 33, 1), 1, 0) FlagImmediateOrAch,
                   TBDC.[AuthorizationDate],
                   ccc.Symbol AS CurrencyOrder
            FROM [DeliveryBackOffice].[dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
				LEFT JOIN #TempBatchDetailCOD_opt2 TBDC 
					ON btd.IdBatchDetailCOD = TBDC.IdBatchDetailCOD
                INNER JOIN [DeliveryBackOffice].[dbo].[ProcessedGuideCOD] AS pg WITH (NOLOCK)
                    ON btd.[GuideSerie] = pg.[GuideSerie]
                       AND btd.[GuideNumber] = pg.[GuideNumber]
                INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] AS do WITH (NOLOCK)
                    ON btd.[GuideSerie] = do.[Guide_Serie]
                       AND btd.[GuideNumber] = do.[Guide_Number]
                LEFT JOIN [DeliveryBackOffice].dbo.Township twn WITH (NOLOCK)
                    ON twn.IdTownship = do.ReceiverIdTownship
				OUTER APPLY
							( SELECT TOP 1 TW.IdProvince, TW.TownshipName  FROM  [DeliveryBackOffice].dbo.Township tw WITH (NOLOCK)
							INNER JOIN [DeliveryBackOffice].dbo.Province PR WITH(NOLOCK) ON PR.IdProvince = tw.IdProvince
							WHERE TW.TownshipName = DO.Receiver_Town AND PR.IdCountry = DO.ReceiverCountryId
							)tw
                LEFT JOIN [DeliveryBackOffice].dbo.Province prv WITH (NOLOCK)
                    ON prv.IdProvince = twn.IdProvince
                LEFT JOIN [DeliveryBackOffice].dbo.Province pr WITH (NOLOCK)
                    ON pr.IdProvince = tw.IdProvince
                LEFT JOIN [DeliveryBackOffice].dbo.VisitPointClient vpc WITH (NOLOCK)
                    ON vpc.CodeOfReference = do.Sender_ID
                LEFT JOIN [DeliveryBackOffice].dbo.Customer cu WITH (NOLOCK)
                    ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
                LEFT JOIN [DeliveryBackOffice].dbo.DeliveryCustomerBankAccount dc WITH (NOLOCK)
                    ON dc.DCBA_Id = do.DCBA_ID
                LEFT JOIN [DeliveryBackOffice].dbo.DeliveryBank bk WITH (NOLOCK)
                    ON bk.Id_bank = dc.DCBA_Bank_Id
                LEFT JOIN [DeliveryBackOffice].dbo.CatCurrencyCOD ccc WITH (NOLOCK)
                    ON btd.CatCurrencyCODId = ccc.IdCatCurrencyCOD
            WHERE pg.[Notificated] = 0
                  AND btd.[AuthorizationNumber] IS NOT NULL
                  AND pg.BatchCODId IS NOT NULL
                  AND LTRIM(RTRIM(do.Sender_Mail)) = @SenderEmail
                  AND
                  (
                      btd.BankId = @IdBank
                      OR @IdBank = -1
                  )
        ) s1
        ORDER BY s1.[AuthorizationDate] ASC;
		
		IF OBJECT_ID('tempdb.dbo.#TempBatchDetailCOD_opt2', 'U') IS NOT NULL
			DROP TABLE #TempBatchDetailCOD_opt2;

    END;
END;