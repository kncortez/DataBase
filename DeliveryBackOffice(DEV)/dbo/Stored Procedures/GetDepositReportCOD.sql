--EXEC GetDepositReportCOD_Generic -1,-1,'2021-10-01','2021-12-01',-1, 'ivan.mendoza@forzalatam.com'
-- =============================================
-- Author:		<Marco Jiménez>
-- Create date: <2021-10-19>
-- Description:	<Guias por pagar COD>
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

    PRINT '@IdCustomer';
    PRINT @IdCustomer;

    PRINT '@SenderEmail';
    PRINT @SenderEmail;



    --IF((ISNULL(@IdCustomer,0) != 0  OR @IdCustomer != -1) AND (ISNULL(@SenderEmail,'0') = '0' OR @SenderEmail = '-1' OR @SenderEmail = '1'))
    --IF (@IdCustomer != -1)
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
		FROM [dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
            INNER JOIN [dbo].[ProcessedGuideCOD] AS pg WITH (NOLOCK)
                ON btd.[GuideSerie] = pg.[GuideSerie]
                    AND btd.[GuideNumber] = pg.[GuideNumber]
            INNER JOIN [dbo].[DeliveryOrder] AS do WITH (NOLOCK)
                ON btd.[GuideSerie] = do.[Guide_Serie]
                    AND btd.[GuideNumber] = do.[Guide_Number]
            LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
                ON vpc.CodeOfReference = do.Sender_ID
            LEFT JOIN dbo.Customer cu WITH (NOLOCK)
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

        PRINT 'OPCION 1A';
		DECLARE @TypeCustomer  INT = 0;
	    SET @TypeCustomer = (SELECT IdCustomerType FROM Customer WITH (NOLOCK) WHERE IdCustomer = @IdCustomer)
			IF (@TypeCustomer != 2)
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
								   FROM dbo.DeliveryOrderPiece dp WITH (NOLOCK)
								   WHERE dp.GuideSerie = do.Guide_Serie
										 AND dp.GuideNumber = do.Guide_Number
							   ) Peso,
							   ISNULL(prv.ProvinceName, pr.ProvinceName) Departamento,
							   ISNULL(twn.TownshipName, tw.TownshipName) Municipio,
							   CONCAT(do.[Receiver_FirstName], do.[Receiver_LastName]) AS Receiver,
                   
							   (
								   SELECT TOP 1
										  dt.DateCreated
								   FROM dbo.DeliveryOrderDetail dt WITH (NOLOCK)
								   WHERE dt.Guide_Serie = do.Guide_Serie
										 AND dt.Guide_Number = do.Guide_Number
										 AND dt.StatusOrderId IN ( 11, 2 )
							   ) FechaArribo,
                   
							   (
								   SELECT TOP 1
										  dt.DateCreated
								   FROM dbo.DeliveryOrderDetail dt WITH (NOLOCK)
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
							   TBDC.[AuthorizationDate]
						FROM [dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
							LEFT JOIN #TempBatchDetailCOD TBDC
								ON btd.IdBatchDetailCOD = TBDC.IdBatchDetailCOD
							INNER JOIN [dbo].[ProcessedGuideCOD] AS pg WITH (NOLOCK)
								ON btd.[GuideSerie] = pg.[GuideSerie]
								   AND btd.[GuideNumber] = pg.[GuideNumber]
							INNER JOIN [dbo].[DeliveryOrder] AS do WITH (NOLOCK)
								ON btd.[GuideSerie] = do.[Guide_Serie]
								   AND btd.[GuideNumber] = do.[Guide_Number]
							LEFT JOIN dbo.Township twn WITH (NOLOCK)
								ON twn.IdTownship = do.ReceiverIdTownship
							LEFT JOIN dbo.Township tw WITH (NOLOCK)
								ON tw.TownshipName = do.Receiver_Town
							LEFT JOIN dbo.Province prv WITH (NOLOCK)
								ON prv.IdProvince = twn.IdProvince
							LEFT JOIN dbo.Province pr WITH (NOLOCK)
								ON pr.IdProvince = tw.IdProvince
							LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
								ON vpc.CodeOfReference = do.Sender_ID
							LEFT JOIN dbo.Customer cu WITH (NOLOCK)
								ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
							LEFT JOIN dbo.DeliveryCustomerBankAccount dc WITH (NOLOCK)
								ON dc.DCBA_Id = do.DCBA_ID
							LEFT JOIN dbo.DeliveryBank bk WITH (NOLOCK)
								ON bk.Id_bank = dc.DCBA_Bank_Id
						WHERE pg.[Notificated] = 0
							  AND btd.[AuthorizationNumber] IS NOT NULL
							  AND pg.BatchCODId IS NOT NULL
							  AND (cu.IdCustomer = @IdCustomer)
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
					OPTION (OPTIMIZE FOR UNKNOWN)
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
								   FROM dbo.DeliveryOrderPiece dp WITH (NOLOCK)
								   WHERE dp.GuideSerie = do.Guide_Serie
										 AND dp.GuideNumber = do.Guide_Number
							   ) Peso,
							   ISNULL(prv.ProvinceName, pr.ProvinceName) Departamento,
							   ISNULL(twn.TownshipName, tw.TownshipName) Municipio,
							   CONCAT(do.[Receiver_FirstName], do.[Receiver_LastName]) AS Receiver,
                   
							   (
								   SELECT TOP 1
										  dt.DateCreated
								   FROM dbo.DeliveryOrderDetail dt WITH (NOLOCK)
								   WHERE dt.Guide_Serie = do.Guide_Serie
										 AND dt.Guide_Number = do.Guide_Number
										 AND dt.StatusOrderId IN ( 11, 2 )
							   ) FechaArribo,
                   
							   (
								   SELECT TOP 1
										  dt.DateCreated
								   FROM dbo.DeliveryOrderDetail dt WITH (NOLOCK)
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
							   TBDC.[AuthorizationDate]
						FROM [dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
							LEFT JOIN #TempBatchDetailCOD TBDC
								ON btd.IdBatchDetailCOD = TBDC.IdBatchDetailCOD
							INNER JOIN [dbo].[ProcessedGuideCOD] AS pg WITH (NOLOCK)
								ON btd.[GuideSerie] = pg.[GuideSerie]
								   AND btd.[GuideNumber] = pg.[GuideNumber]
							INNER JOIN [dbo].[DeliveryOrder] AS do WITH (NOLOCK)
								ON btd.[GuideSerie] = do.[Guide_Serie]
								   AND btd.[GuideNumber] = do.[Guide_Number]
							LEFT JOIN dbo.Township twn WITH (NOLOCK)
								ON twn.IdTownship = do.ReceiverIdTownship
							LEFT JOIN dbo.Township tw WITH (NOLOCK)
								ON tw.TownshipName = do.Receiver_Town
							LEFT JOIN dbo.Province prv WITH (NOLOCK)
								ON prv.IdProvince = twn.IdProvince
							LEFT JOIN dbo.Province pr WITH (NOLOCK)
								ON pr.IdProvince = tw.IdProvince
							LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
								ON vpc.CodeOfReference = do.Sender_ID
							LEFT JOIN dbo.Customer cu WITH (NOLOCK)
								ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
							LEFT JOIN dbo.DeliveryCustomerBankAccount dc WITH (NOLOCK)
								ON dc.DCBA_Id = do.DCBA_ID
							LEFT JOIN dbo.DeliveryBank bk WITH (NOLOCK)
								ON bk.Id_bank = dc.DCBA_Bank_Id
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
					OPTION (OPTIMIZE FOR UNKNOWN)
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
		FROM [dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
            INNER JOIN [dbo].[ProcessedGuideCOD] AS pg WITH (NOLOCK)
                ON btd.[GuideSerie] = pg.[GuideSerie]
                    AND btd.[GuideNumber] = pg.[GuideNumber]
            INNER JOIN [dbo].[DeliveryOrder] AS do WITH (NOLOCK)
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

        PRINT 'OPCION 2';
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
				
				--,FORMAT(s1.FechaArribo, 'dd/MM/yyyy hh:mm:ss tt' ) 'FechaArribo'
				--,FORMAT(s1.FechaEntrega, 'dd/MM/yyyy hh:mm:ss tt' ) 'FechaEntrega'
				--,FORMAT(s1.FechaPago, 'dd/MM/yyyy hh:mm:ss tt' ) 'FechaPago'
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
               ,ISNULL(DATEDIFF(DAY, CONVERT(DATE, s1.FechaEntrega, 103), CONVERT(DATE, s1.FechaPago, 103)), 0) AS DiasPago
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
                       FROM dbo.DeliveryOrderPiece dp WITH (NOLOCK)
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
                       FROM dbo.DeliveryOrderDetail dt WITH (NOLOCK)
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
                       FROM dbo.DeliveryOrderDetail dt WITH (NOLOCK)
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
                   TBDC.[AuthorizationDate]
            FROM [dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
				LEFT JOIN #TempBatchDetailCOD_opt2 TBDC 
					ON btd.IdBatchDetailCOD = TBDC.IdBatchDetailCOD
                INNER JOIN [dbo].[ProcessedGuideCOD] AS pg WITH (NOLOCK)
                    ON btd.[GuideSerie] = pg.[GuideSerie]
                       AND btd.[GuideNumber] = pg.[GuideNumber]
                INNER JOIN [dbo].[DeliveryOrder] AS do WITH (NOLOCK)
                    ON btd.[GuideSerie] = do.[Guide_Serie]
                       AND btd.[GuideNumber] = do.[Guide_Number]
                LEFT JOIN dbo.Township twn WITH (NOLOCK)
                    ON twn.IdTownship = do.ReceiverIdTownship
                LEFT JOIN dbo.Township tw WITH (NOLOCK)
                    ON tw.TownshipName = do.Receiver_Town
                LEFT JOIN dbo.Province prv WITH (NOLOCK)
                    ON prv.IdProvince = twn.IdProvince
                LEFT JOIN dbo.Province pr WITH (NOLOCK)
                    ON pr.IdProvince = tw.IdProvince
                LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
                    ON vpc.CodeOfReference = do.Sender_ID
                LEFT JOIN dbo.Customer cu WITH (NOLOCK)
                    ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
                LEFT JOIN dbo.DeliveryCustomerBankAccount dc WITH (NOLOCK)
                    ON dc.DCBA_Id = do.DCBA_ID
                LEFT JOIN dbo.DeliveryBank bk WITH (NOLOCK)
                    ON bk.Id_bank = dc.DCBA_Bank_Id
            WHERE pg.[Notificated] = 0
                  AND btd.[AuthorizationNumber] IS NOT NULL
                  AND pg.BatchCODId IS NOT NULL
                  AND LTRIM(RTRIM(do.Sender_Mail)) = @SenderEmail
                  AND
                  (
                      btd.BankId = @IdBank
                      OR @IdBank = -1
                  )
        --AND do.SalePipeLineId  IN (3)
        -- AND CAST(BTD.AuthorizationDate AS DATE)
        -- BETWEEN CAST(@StarDate AS DATE) AND CAST(@EndDate AS DATE)
        ) s1
        ORDER BY s1.[AuthorizationDate] ASC;
		
		IF OBJECT_ID('tempdb.dbo.#TempBatchDetailCOD_opt2', 'U') IS NOT NULL
			DROP TABLE #TempBatchDetailCOD_opt2;

    END;
END;