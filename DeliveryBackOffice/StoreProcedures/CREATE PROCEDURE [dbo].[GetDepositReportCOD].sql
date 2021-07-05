USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetDepositReportCOD]    Script Date: 5/07/2021 17:03:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-29>
-- Description:	<Guias por pagar COD>
-- =============================================
ALTER PROCEDURE [dbo].[GetDepositReportCOD]
    -- Add the parameters for the stored procedure here
    @IdCustomer INT,
    @IdBank INT
AS
BEGIN

    SELECT s1.*,
           ISNULL(DATEDIFF(DAY, s1.FechaArribo, s1.FechaEntrega),0) AS DiasEntrega
		   , ISNULL(DATEDIFF(DAY, s1.FechaEntrega, s1.FechaPago),0) AS DiasPago
    FROM
    (
        SELECT cu.[IdCustomer] IdCliente,
               cu.[Name] Cliente,
               cu.[RegexEmail] Correo,
               bk.Name Banco,
               dc.DCBA_Num_account Cuenta,
               CONCAT(btd.[GuideSerie], btd.[GuideNumber]) GuideNumber,
               (do.Pieces_Dry + do.Pieces_Cold) Piezas,
               (
                   SELECT SUM(ISNULL(dp.MassWeight, dp.PieceWeight))
                   FROM dbo.DeliveryOrderPiece dp
                   WHERE dp.GuideSerie = do.Guide_Serie 
                         AND dp.GuideNumber = do.Guide_Number
               ) Peso,
               ISNULL(prv.ProvinceName, pr.ProvinceName) Departamento,
               ISNULL(twn.TownshipName, tw.TownshipName) Municipio,
               CONCAT(do.[Receiver_FirstName], do.[Receiver_LastName]) AS Receiver,
               (
                   SELECT TOP 1
                          dt.DateCreated
                   FROM dbo.DeliveryOrderDetail dt
                   WHERE dt.Guide_Serie = do.Guide_Serie
                         AND dt.Guide_Number = do.Guide_Number
                         AND dt.StatusOrderId IN ( 11, 2 )
               ) FechaArribo,
               (
                   SELECT TOP 1
                          dt.DateCreated
                   FROM dbo.DeliveryOrderDetail dt
                   WHERE dt.Guide_Serie = do.Guide_Serie
                         AND dt.Guide_Number = do.Guide_Number
                         AND dt.StatusOrderId = 5
               ) FechaEntrega,
               btd.[AuthorizationDate] FechaPago,
               btd.[AuthorizationNumber] NoDeposito,
               do.[Collect_OnDelivery] AS CODAmount,
               do.[TypeService],
               IIF(do.IsCollect = 'true',
                   'Collect',
                   (IIF(ISNULL(cu.ConditionOfPaymentID, 0) > 1, 'Crédito', 'Prepago'))) TipodePago,
               do.[PriceShippment] AS ShippmentAmount,
               btd.[Commission] AS CommissionAmount,
               CONVERT(DECIMAL(12, 2), btd.[Commission] / do.[Collect_OnDelivery] * 100) AS PorcentajeComision,
               btd.[Amount] + btd.[Commission] AS ChargedAmount,
               btd.[Amount] AS TotalAmount
        FROM [dbo].[BatchDetailCOD] AS btd
            INNER JOIN [dbo].[ProcessedGuideCOD] AS pg
                ON btd.[GuideSerie] = pg.[GuideSerie]
                   AND btd.[GuideNumber] = pg.[GuideNumber]
            INNER JOIN [dbo].[DeliveryOrder] AS do
                ON btd.[GuideSerie] = do.[Guide_Serie]
                   AND btd.[GuideNumber] = do.[Guide_Number]
            LEFT JOIN dbo.Township twn
                ON twn.IdTownship = do.ReceiverIdTownship
            LEFT JOIN dbo.Township tw
                ON tw.TownshipName = do.Receiver_Town
            LEFT JOIN dbo.Province prv
                ON prv.IdProvince = twn.IdProvince
            LEFT JOIN dbo.Province pr
                ON pr.IdProvince = tw.IdProvince
            LEFT JOIN dbo.VisitPointClient vpc
                ON vpc.CodeOfReference = do.Sender_ID
            LEFT JOIN dbo.Customer cu
                ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
            LEFT JOIN dbo.DeliveryCustomerBankAccount dc
                ON dc.DCBA_Id = do.DCBA_ID
            LEFT JOIN dbo.DeliveryBank bk
                ON bk.Id_bank = dc.DCBA_Bank_Id
        WHERE pg.[Notificated] = 0
              AND btd.[AuthorizationNumber] IS NOT NULL
              AND cu.IdCustomer = @IdCustomer
              AND btd.BankId = @IdBank
    ) s1
    ORDER BY s1.GuideNumber;
	
END;
