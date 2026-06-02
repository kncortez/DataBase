​-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2026-02-13>
-- Description:	<Guias por pagar COD>
-- =============================================​
CREATE PROCEDURE [dbo].[GetGuidesToPayCODInternational]
    @Date DATE
  , @IdCountry NVARCHAR(2)= 'GT'
AS
BEGIN
	SET ARITHABORT ON;
    SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.#TempBatchDetail', 'U') IS NOT NULL
            DROP TABLE #TempBatchDetail;



  CREATE TABLE #TempBatchDetail
            (
              GuideSerie NVARCHAR(2)
     , GuideNumber INT
     , Amount DECIMAL(12,4)
     , Commission DECIMAL(12,4)
     , CommissionDate DATETIME
	 , CommissionId INT
     , RowStatus INT
     , CatConceptCODId INT
            );
            CREATE NONCLUSTERED INDEX tempbtdetail
            ON #TempBatchDetail (
                               GuideSerie
                             , GuideNumber
                           );
          

INSERT INTO #TempBatchDetail
(
    GuideSerie
  , GuideNumber
  , Amount
  , Commission
   , CommissionId
  , CommissionDate
  , RowStatus
  , CatConceptCODId
)
SELECT 
       BTD.GuideSerie
     , BTD.GuideNumber
     , BTD.Amount
     , BTD.Commission
	 , btd.CommissionId
     , BTD.CommissionDate
     , BTd.RowStatus
     , BTD.CatConceptCODId
FROM dbo.BatchCOD                 BT WITH(NOLOCK)
    INNER JOIN dbo.BatchDetailCOD BTD WITH(NOLOCK)
        ON BTD.BatchCODId = BT.IdBatchCOD
WHERE CONVERT(DATE, BT.Date) = @Date
      AND BTD.CatConceptCODId = 1
      AND BTd.RowStatus = 1
      AND BTD.IdCountry = @IdCountry 
OPTION (MAXDOP 1);

    SELECT bt.IdBatchCOD,
           bt.Name,
           bt.BatchNumber,
           bt.BankId,
           db.[Acronym] AS Bank,
           bt.TotalAmountIncluded,
           bt.BatchTimeRange,
           bt.Date,
           btd.AuthorizationNumber,
           btd.AuthorizationDate,
           btd.IdBatchDetailCOD,
           btd.GuideSerie,
           btd.GuideNumber,
		   CONCAT(btd.GuideSerie, btd.GuideNumber) Guide,
           CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) AS Receiver,
           IIF(cu.Name = 'FD EXPRESS CENTER' OR kovpc.KindOfVPName = 'Express Center', CONCAT(do.Sender_FirstName,' ', do.Sender_LastName), cu.Name) AS Client,
           CASE WHEN btd.CatConceptCODId = 4 THEN
		   (
               SELECT TOP 1
                      dsc.[Hub]
               FROM [dbo].[DumpServiceCoverage] AS dsc WITH(NOLOCK)
               WHERE twnSender.[HeaderCode] = dsc.[HeaderCode]
           )
		   ELSE
		   (
               SELECT TOP 1
                      dsc.[Hub]
               FROM [dbo].[DumpServiceCoverage] AS dsc WITH(NOLOCK)
               WHERE twn.[HeaderCode] = dsc.[HeaderCode]
           ) END AS Hub,
           btd.[Commission],
           (
				CASE
					WHEN ISNULL([do].[IsLastMileReturn],0) = 1 THEN 0
					ELSE do.[Collect_OnDelivery]
				END
		   ) [Collect_OnDelivery],
           btd.[Amount],
           btd.AccountNumber AS NumAccount,
           btd.AccountName AS AccountName,
           btd.TypeAccountName AS TypeAccount,
           ISNULL(vp.DescriptionOfClient, '') AS Source,
           CONCAT(do.Sender_FirstName,' ', do.Sender_LastName) AS Sender,
           CONCAT(sr.First_Name, ' ', sr.Last_Name) AS Courier,
           ISNULL(do.PriceShippment, 0) AS Price,
           ISNULL(btd.DiscountPrice, 0) AS DiscountPrice,
           (
               SELECT COUNT(1)
               FROM DeliveryOrderPiece WITH(NOLOCK)
               WHERE GuideSerie = btd.GuideSerie
                     AND GuideNumber = btd.GuideNumber
           ) AS Pieces,
           btd.[Excluded],
           btd.CatConceptCODId,
           btd.Comments
		   ,btc.Amount Profit
		   ,(CASE WHEN vp.IdKindOfVPClient IN (2,6,8) THEN ''
			ELSE vp.DescriptionOfClient 
			END) VisitPoint,
			btd.CatConceptCODId Concept,
			COALESCE(btd.CollectId,0) CollectId,
			COALESCE(btd.RecolectionId,0) RecolectionId
			,ISNULL(btc.CommissionId,0) CommissionId
            ,btc.CommissionDate CommissionDate,
			vpcr.DescriptionOfClient VisitPointReceiver,
			CONCAT(p.PerFirstName, ' ', p.PerLastName) UserReceiver,
		(CASE WHEN do.IsCollect = 1 THEN 'Destino'
			WHEN cpt.TimePlaName = 'Ahora' THEN 'Contado'
			WHEN cpt.TimePlaName = 'Post-Venta' THEN 'Crédito'
			ELSE cpt.TimePlaName
			END) PaymentType,
			(IIF(ctiom.tio_pk_name = 'pago con tarjeta' OR ctiom.tio_pk_name = 'Datafono', 'Si','No')) CardPayment,
			(IIF(MAX(ISNULL(bt.IsAnticipatedCOD,0)) = 1, 'C.O.D. Anticipado','C.O.D. Inmediato')) BatchTypeCOD,
			(MAX(ISNULL(btd.ComisionCODAnticipated,0))) AnticipatedCommission
    FROM [dbo].[BatchDetailCOD] btd WITH(NOLOCK)
        LEFT JOIN [dbo].[BatchCOD] bt WITH(NOLOCK)
            ON btd.[BatchCODId] = bt.[IdBatchCOD]
        LEFT JOIN [dbo].[DeliveryBank] db WITH(NOLOCK)
            ON db.Id_bank = bt.BankId
        LEFT JOIN [dbo].[DeliveryOrder] do WITH(NOLOCK)
            ON btd.[GuideSerie] = do.[Guide_Serie]
               AND btd.[GuideNumber] = do.[Guide_Number]
        LEFT JOIN [dbo].VisitPointClient vp WITH(NOLOCK)
            ON vp.CodeOfReference = do.Sender_ID
        LEFT JOIN [dbo].[Customer] cu WITH(NOLOCK)
            ON ISNULL(do.[IdCustomer], vp.CustomerID) = cu.[IdCustomer]
        LEFT JOIN [dbo].[Township] twn WITH(NOLOCK)
            ON CASE
                   WHEN do.[ReceiverIdTownship] IS NULL THEN
                   (
                       SELECT TOP 1
                              [IdTownship]
                       FROM [dbo].[Township] WITH(NOLOCK)
                       WHERE UPPER(do.[Receiver_Town]) = UPPER([TownshipName])
                   )
                   ELSE
                       do.[ReceiverIdTownship]
               END = twn.[IdTownship]
			   	  LEFT JOIN [dbo].[Township] twnSender WITH(NOLOCK)
            ON CASE
                   WHEN do.[SenderIdTownship] IS NULL THEN
                   (
                       SELECT TOP 1
                              [IdTownship]
                       FROM [dbo].[Township] WITH(NOLOCK)
                       WHERE UPPER(do.[Sender_Town]) = UPPER([TownshipName])
                   )
                   ELSE
                       do.[SenderIdTownship]
               END = twnSender.[IdTownship]
        LEFT JOIN [dbo].[ProcessedGuideCOD] pg WITH(NOLOCK)
            ON btd.[GuideSerie] = pg.[GuideSerie]
               AND btd.[GuideNumber] = pg.[GuideNumber]
        LEFT JOIN [dbo].[SenderReceiver] sr WITH(NOLOCK)
            ON pg.CourierManId = sr.ID
        LEFT JOIN #TempBatchDetail btc WITH(NOLOCK)
            ON btc.GuideSerie = btd.GuideSerie
               AND btc.GuideNumber = btd.GuideNumber
		LEFT JOIN [dbo].[KindOfVPClient] kovpc WITH(NOLOCK)
			ON kovpc.IdKindOfVPClient = vp.IdKindOfVPClient
		LEFT JOIN [dbo].[DeliveryOrderPaymentTransaction] dopt WITH(NOLOCK)
	        ON btd.GuideSerie = dopt.GuideSerie
			   AND btd.GuideNumber = dopt.GuideNumber
			   AND dopt.CODAmountProcess > 0 
			   AND dopt.ShipmentCompleted = 1
		LEFT JOIN [dbo].[VisitPointClient] vpcr WITH(NOLOCK)
			ON vpcr.CodeOfReference = dopt.VisitPoint
		LEFT JOIN [dbo].[TokenLog] tl WITH(NOLOCK)
			ON tl.TknIdToken = dopt.TokenCreated
		LEFT JOIN RegisterUser ru WITH(NOLOCK)
			ON ru.UsrIdUser = tl.TknIdUser
		LEFT JOIN Person p WITH(NOLOCK)
			ON p.PerIdPerson = ru.UsrIdPerson
		OUTER APPLY
		(
			SELECT 
				TOP (1) 
					[DOPDaux].[TimePlaId]
					,[DOPDaux].[TypeofInOutMoneyId]
					,[DOPDaux].[PayTypeId]
			FROM 
				[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPDaux  WITH(NOLOCK) 
			WHERE
				[DOPDaux].[GuideSerie] = [btd].[GuideSerie]
				AND
				[DOPDaux].[GuideNumber] = [btd].[GuideNumber]
				AND
				[DOPDaux].[ShipmentCompleted] = 1
				AND
				[DOPDaux].[TimePlaId] > 0
			ORDER BY
				[DOPDaux].[DateCreated] DESC
		) dopd
		LEFT JOIN [dbo].[CatPaymentTime] cpt WITH(NOLOCK)
			ON cpt.TimePlaId = dopd.TimePlaId
		LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctiom WITH(NOLOCK)
			ON ctiom.tio_pk_id = dopd.TypeofInOutMoneyId
    WHERE
        CONVERT(DATE, bt.[Date]) = @Date
		AND btd.CatConceptCODId IN (2,3,4)
		AND bt.RowStatus = 'TRUE'
		AND BTD.RowStatus = 1 
		AND do.SenderCountryId = @IdCountry
        AND BTD.isCompleted = 1
		AND cu.IsInternationalCustomer =1​
		GROUP BY  btd.GuideSerie,
           btd.GuideNumber,
		   do.[IsLastMileReturn],
		   bt.IdBatchCOD,
           bt.Name,
           bt.BatchNumber,
           bt.BankId,
           db.Acronym ,
           bt.TotalAmountIncluded,
           bt.BatchTimeRange,
           bt.Date,
           btd.AuthorizationNumber,
           btd.AuthorizationDate,
           btd.IdBatchDetailCOD,
           btd.GuideSerie,
           btd.GuideNumber,
		   do.Receiver_FirstName,
		   do.Receiver_LastName,
		   cu.Name,
		   do.Sender_FirstName,
		   do.Sender_LastName,
		   btd.Commission,
           do.Collect_OnDelivery,
           btd.Amount,
           btd.AccountNumber,
           btd.AccountName,
           btd.TypeAccountName,
          vp.DescriptionOfClient,       
          do.PriceShippment, 
          btd.DiscountPrice,
		  twnSender.HeaderCode,
		  twn.HeaderCode,
		  btd.CatConceptCODId,
		  sr.First_Name,
		  sr.Last_Name,
		  btd.Excluded,
           btd.CatConceptCODId,
           btd.Comments,
		   btc.Amount ,
		   vp.IdKindOfVPClient,
			vp.DescriptionOfClient, 			
			btd.CollectId,
			btd.RecolectionId,
			kovpc.KindOfVPName,
			btc.CommissionId,
            btc.CommissionDate,
			vpcr.DescriptionOfClient,
			p.PerFirstName,
			p.PerLastName,
			cpt.TimePlaName,
			ctiom.tio_pk_name,
			do.IsCollect
    ORDER BY bt.IdBatchCOD,
             bt.Date, btd.AuthorizationNumber DESC
			 OPTION (MAXDOP 1);
			 
			 IF OBJECT_ID('tempdb.dbo.#TempBatchDetail', 'U') IS NOT NULL
                 DROP TABLE #TempBatchDetail;

END;
