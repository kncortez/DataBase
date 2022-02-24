USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_guide_pending_payment]    Script Date: 24/02/2022 09:26:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-05-21>
-- Description:	<Devuleve el monto a cobrar >
-- =============================================
ALTER PROCEDURE [dbo].[spws_get_guide_pending_payment]
    @InGuides VARCHAR(MAX),
    @InTime INT,
    @IsReturn BIT,
    @CodeApp VARCHAR(100),
    @IdModule INT,
    @Token VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InSequenceTime INT;
    DECLARE @TimeShortName VARCHAR(10);
    DECLARE @InCollectCOD BIT;
    DECLARE @MaxTime INT;
    DECLARE @MaxSequenceTime INT;
    DECLARE @MinTime INT;
    DECLARE @MinSequenceTime INT;
    SELECT @InSequenceTime = ISNULL(cpt.TimeSequence, 0),
           @TimeShortName = ISNULL(cpt.TimePlaAbrev, ''),
           @InCollectCOD = ISNULL(cpt.CollectCOD, 0)
    FROM dbo.CatPaymentTime cpt
    WHERE cpt.TimePlaId = @InTime;

    SELECT @MaxTime = ISNULL(cpt.TimePlaId, 1),
           @MaxSequenceTime = ISNULL(cpt.TimeSequence, 0)
    FROM dbo.CatPaymentTime cpt
    WHERE cpt.TimeSequence =
    (
        SELECT MAX(cpt.TimeSequence)FROM dbo.CatPaymentTime cpt
    );
    SELECT @MinTime = ISNULL(cpt.TimePlaId, 1),
           @MinSequenceTime = ISNULL(cpt.TimeSequence, 0)
    FROM dbo.CatPaymentTime cpt
    WHERE cpt.TimeSequence =
    (
        SELECT MIN(cpt.TimeSequence)FROM dbo.CatPaymentTime cpt
    );
    IF OBJECT_ID('tempdb.dbo.#listGuidesBrain', 'U') IS NOT NULL
        DROP TABLE #listGuidesBrain;
    IF OBJECT_ID('tempdb.dbo.#TempPrice', 'U') IS NOT NULL
        DROP TABLE #TempPrice;
    IF OBJECT_ID('tempdb.dbo.#RevalueGuides', 'U') IS NOT NULL
        DROP TABLE #RevalueGuides;
    SELECT DISTINCT
           SUBSTRING(Item, 1, 2) ItemSerie,
           SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 3))) ItemNumber
    INTO #listGuidesBrain
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',');

    -----------------------------------------------------------------------------------------------------
    SELECT ord.Guide_Serie [GuideSerie],
           ord.Guide_Number [GuideNumber],
           ord.IsCollect [IsCollect],
           ord.PriceShippment [Price],
           ord.Collect_OnDelivery [COD],
           cst.TotalAmountPaid [AmountPaid],
           cst.CODAmount [CODPaid],
           IIF(cst.CODAmount IS NULL, 0, 1) [CODIsPaid],
           ISNULL(pyt.TimePlaId, IIF(cdp.ConditionOfPaymenAbbreviation IS NULL, @MinTime, @MaxTime)) [PaymentTime],
           ISNULL(tim.TimeSequence, IIF(cdp.ConditionOfPaymenAbbreviation IS NULL, @MinSequenceTime, @MaxSequenceTime)) [TimeSequence],
           inh.inv_certificationFEL [FelNumber],
           IIF(inh.inv_certificationFEL IS NULL, IIF(ISNULL(cst.TotalAmountPaid, 0) = 0, 0, 1), 1) [IsPaid],
           cus.IdCustomer [IsCustomer],
           cdp.ConditionOfPaymenDescription [ConditionPayment],
           IIF(cdp.ConditionOfPaymenAbbreviation IS NULL, 0, 1) [HaveCredit],
           ISNULL(@InCollectCOD, 0) [CollectCOD],
           ISNULL(ISNULL(rh.ReturnRate, rhd.ReturnRate), 100) [ReturnRate]

    INTO #TempPrice
    FROM #listGuidesBrain lg
        JOIN dbo.DeliveryOrder ord
            ON ord.Guide_Serie = lg.ItemSerie
               AND ord.Guide_Number = lg.ItemNumber
        LEFT JOIN dbo.Cost cst
            ON cst.ProductNumber = CONCAT(lg.ItemSerie, lg.ItemNumber)
        LEFT JOIN dbo.DeliveryOrderPaymentDetail pyt
            ON pyt.GuideSerie = lg.ItemSerie
               AND pyt.GuideNumber = lg.ItemNumber
        LEFT JOIN dbo.InvoiceDetail ind
            ON ind.dti_fk_orderSerie = lg.ItemSerie
               AND ind.dti_fk_orderNumber = lg.ItemNumber
        LEFT JOIN dbo.CatPaymentTime tim
            ON tim.TimePlaId = pyt.TimePlaId
        LEFT JOIN dbo.invoiceHeader inh
            ON inh.inv_pk_id = ind.dti_fk_header
			AND inh.inv_invoiceOfCreditNote = NULL
        LEFT JOIN dbo.Customer cus
            ON cus.IdCustomer =
            (
                SELECT TOP 1
                       ISNULL(ord.IdCustomer, vpc.CustomerID)
                FROM dbo.VisitPointClient vpc
                WHERE vpc.CodeOfReference = ord.Sender_ID
            )
        LEFT JOIN dbo.CatConditionOfPayment cdp
            ON cdp.IdConditionOfPayment = cus.ConditionOfPaymentID
               AND cdp.IdConditionOfPayment > 1
        LEFT JOIN dbo.RatebyCustomer rc
            ON rc.RbcIdCustomer = cus.IdCustomer
        LEFT JOIN dbo.RateHeader rh
            ON rh.RheId = rc.RbcIdRate
        LEFT JOIN dbo.RateHeader rhd
            ON rhd.RheDefault = 'true'
               AND cdp.RowStatus = 1
    WHERE rc.RbcCodeOfReference IS NULL
    AND rc.RbcRowStatus = 1
    ORDER BY lg.ItemSerie,
             lg.ItemNumber;

    SELECT tp.*,
           CASE tp.IsPaid
               WHEN 1 THEN
                   0 -- esta pagado
               ELSE -- no esta pagado
                   CASE
                       WHEN @IsReturn = 'false' THEN
                           CASE tp.HaveCredit
                               WHEN 1 THEN --- cliente tiene credito
                                   CASE @TimeShortName
                                       WHEN 'POST' THEN
                                           tp.Price
									    WHEN 'DEST' THEN
                                           IIF(tp.IsCollect=1, tp.Price,0)
                                       ELSE
                                           0
                                   END
                               ELSE -- cliente no tiene credito
                                   CASE
                                       WHEN tp.TimeSequence <= @InSequenceTime THEN
                                           /*CASE @InTime
												WHEN 2 THEN
													IIF(tp.IsCollect = 1, 0, tp.Price)
												ELSE
													IIF(tp.IsCollect = 1, tp.Price, 0)
											END*/
										   tp.Price
                                       ELSE
                                           0
                                   END
                           END
                       ELSE
                           CASE tp.HaveCredit
                               WHEN 1 THEN --- cliente tiene credito
                                   CASE @TimeShortName
                                       WHEN 'POST' THEN
                                           tp.Price
                                       ELSE
                                           0
                                   END
                               ELSE -- cliente no tiene credito
                                   tp.Price
                           END
                   END
           END [AmountToPay],
           IIF(tp.CollectCOD = 'true', IIF(@IsReturn = 'true', 0, IIF(tp.CODIsPaid = 1, 0, tp.COD)), 0) [CODAmount],
           CASE tp.IsPaid
               WHEN 1 THEN
                   0 -- esta pagado
               ELSE -- no esta pagado
                   CASE
                       WHEN @IsReturn = 'true' THEN
                           CASE tp.HaveCredit
                               WHEN 1 THEN --- cliente tiene credito
                                   CASE @TimeShortName
                                       WHEN 'POST' THEN
                                           CONVERT(DECIMAL(12, 2), (tp.Price * (tp.ReturnRate / 100)))
                                       ELSE
                                           0
                                   END
                               ELSE -- cliente no tiene credito
                                   CASE
                                       WHEN tp.TimeSequence <= @InSequenceTime THEN
                                           CONVERT(DECIMAL(12, 2), (tp.Price * (tp.ReturnRate / 100)))
                                       ELSE
                                           0
                                   END
                           END
                       ELSE
                           0
                   END
           END [ReturnRate]
    FROM #TempPrice tp
    ORDER BY tp.IsCustomer,
             tp.GuideNumber;
END;