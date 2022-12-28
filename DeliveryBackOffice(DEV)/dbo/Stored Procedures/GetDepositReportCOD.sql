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
    IF (@IdCustomer != -1)
    BEGIN
        PRINT 'OPCION 1A';
        SELECT s1.*,
               ISNULL(DATEDIFF(DAY, CONVERT(DATE, s1.FechaArribo, 103), CONVERT(DATE, s1.FechaEntrega, 103)), 0) AS DiasEntrega,
               ISNULL(DATEDIFF(DAY, CONVERT(DATE, s1.FechaEntrega, 103), CONVERT(DATE, s1.FechaPago, 103)), 0) AS DiasPago
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
                   FORMAT(
                   (
                       SELECT TOP 1
                              dt.DateCreated
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
                              dt.DateCreated
                       FROM dbo.DeliveryOrderDetail dt WITH (NOLOCK)
                       WHERE dt.Guide_Serie = do.Guide_Serie
                             AND dt.Guide_Number = do.Guide_Number
                             AND dt.StatusOrderId = 5
                   ),
                   'dd/MM/yyyy hh:mm:ss tt'
                         ) FechaEntrega,
                   FORMAT(btd.[AuthorizationDate], 'dd/MM/yyyy hh:mm:ss tt') FechaPago,
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
                   btd.[AuthorizationDate]
            FROM [dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
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

    END;
    ELSE IF (@SenderEmail != '-1')
    BEGIN
        PRINT 'OPCION 2';
        SELECT s1.*,
               ISNULL(DATEDIFF(DAY, CONVERT(DATE, s1.FechaArribo, 103), CONVERT(DATE, s1.FechaEntrega, 103)), 0) AS DiasEntrega,
               ISNULL(DATEDIFF(DAY, CONVERT(DATE, s1.FechaEntrega, 103), CONVERT(DATE, s1.FechaPago, 103)), 0) AS DiasPago
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
                              dt.DateCreated
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
                              dt.DateCreated
                       FROM dbo.DeliveryOrderDetail dt WITH (NOLOCK)
                       WHERE dt.Guide_Serie = do.Guide_Serie
                             AND dt.Guide_Number = do.Guide_Number
                             AND dt.StatusOrderId = 5
                   ),
                   'dd/MM/yyyy hh:mm:ss tt'
                         ) FechaEntrega,
                   FORMAT(btd.[AuthorizationDate], 'dd/MM/yyyy hh:mm:ss tt') FechaPago,
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
                   btd.[AuthorizationDate]
            FROM [dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
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
    END;
END;