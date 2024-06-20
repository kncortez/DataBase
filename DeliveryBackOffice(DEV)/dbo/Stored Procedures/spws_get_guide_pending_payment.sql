-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-05-21>
-- Description:	<Devuleve el monto a cobrar >
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_guide_pending_payment]
    @InGuides VARCHAR(MAX),
    @InTime INT,
    @IsReturn BIT,
    @CodeApp VARCHAR(100),
    @IdModule INT,
    @Token VARCHAR(100),
    @IdCountry VARCHAR(2) = 'GT'
--SET STATISTICS TIME ON; 
--DECLARE
--    @InGuides VARCHAR(MAX)	= 'FD1002000,FD1007542,FD1009118,FD1017485,FD1019336,FD1024099,FD1024118',
--    @InTime INT				= 2,
--    @IsReturn BIT			= 'FALSE',
--    @CodeApp VARCHAR(100)	= 'SIFDCECOM300720201459',
--    @IdModule INT			= 1,
--    @Token VARCHAR(100)		= 'SYSTEM'
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
    DECLARE @CollectTime INT;
    DECLARE @CollectSequence INT;

	DECLARE
    @_InGuides VARCHAR(MAX),
    @_InTime INT,
    @_IsReturn BIT,
    @_CodeApp VARCHAR(100),
    @_IdModule INT,
    @_Token VARCHAR(100)
	PRINT '************************************************************************************* SETS'
	SET @_InGuides= @InGuides
	SET @_InTime = @InTime 
	SET @_IsReturn= @IsReturn
	SET @_CodeApp = @CodeApp 
	SET @_IdModule= @IdModule
	SET @_Token = @Token 

	PRINT '************************************************************************************* SELECT 1'

	IF OBJECT_ID('tempdb.dbo.#listGuidesBrain', 'U') IS NOT NULL DROP TABLE #listGuidesBrain;
	IF OBJECT_ID('tempdb.dbo.#TempPrice', 'U') IS NOT NULL DROP TABLE #TempPrice;
	
    SELECT @InSequenceTime = ISNULL(cpt.TimeSequence, 0),
           @TimeShortName = ISNULL(cpt.TimePlaAbrev, ''),
           @InCollectCOD = ISNULL(cpt.CollectCOD, 0)
    FROM dbo.CatPaymentTime cpt WITH (NOLOCK)
    WHERE cpt.TimePlaId = @_InTime;

	PRINT '************************************************************************************* SELECT 2'
	
    SELECT @MaxTime = ISNULL(cpt.TimePlaId, 1),
           @MaxSequenceTime = ISNULL(cpt.TimeSequence, 0)
    FROM dbo.CatPaymentTime cpt WITH (NOLOCK)
    WHERE cpt.TimeSequence =
    (
        SELECT MAX(cpt.TimeSequence)FROM dbo.CatPaymentTime cpt WITH (NOLOCK)
    );

	PRINT '************************************************************************************* SELECT 3'
	
    SELECT @MinTime = ISNULL(cpt.TimePlaId, 1),
           @MinSequenceTime = ISNULL(cpt.TimeSequence, 0)
    FROM dbo.CatPaymentTime cpt WITH (NOLOCK)
    WHERE cpt.TimeSequence =
    (
        SELECT MIN(cpt.TimeSequence)FROM dbo.CatPaymentTime cpt WITH (NOLOCK)
    );

	PRINT '************************************************************************************* SELECT 4'
	
    SELECT @CollectTime = ISNULL(cpt.TimePlaId, 1),
           @CollectSequence = ISNULL(cpt.TimeSequence, 0)
    FROM dbo.CatPaymentTime cpt WITH (NOLOCK)
    WHERE cpt.TimePlaAbrev = 'DEST';

    DECLARE @listGuidesBrain AS TABLE
    (
        ItemSerie NVARCHAR(2),
        ItemNumber INT
    );

   /* IF OBJECT_ID('tempdb.dbo.#listGuidesBrain', 'U') IS NOT NULL
        DROP TABLE #listGuidesBrain;
    IF OBJECT_ID('tempdb.dbo.#TempPrice', 'U') IS NOT NULL
        DROP TABLE #TempPrice;
    IF OBJECT_ID('tempdb.dbo.#RevalueGuides', 'U') IS NOT NULL
        DROP TABLE #RevalueGuides; */

PRINT '************************************************************************************* INSERT SPLIT'
	
    --INSERT INTO @listGuidesBrain
    --(
    --    ItemSerie,
    --    ItemNumber
    --)
    --SELECT DISTINCT
    --       SUBSTRING(Item, 1, 2) ItemSerie,
    --       SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber
    --FROM DeliveryBackOffice.dbo.SplitUnlimited(@_InGuides, ',');
	
    SELECT DISTINCT
           CAST(SUBSTRING(Item, 1, 2)AS NVARCHAR(50)) ItemSerie,
           CAST(SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) AS INT) ItemNumber,
		   CAST(SUBSTRING(Item, 1, 2)AS VARCHAR(50)) +           
		   CAST(SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) AS VARCHAR(50)) GuideNumber
		   INTO #listGuidesBrain
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@_InGuides, ',');

	CREATE NONCLUSTERED INDEX IDX_TEMPBRAIN ON #listGuidesBrain (ItemNumber, ItemSerie)
	--CREATE NONCLUSTERED INDEX IDX_TEMPBRAIN2 ON #listGuidesBrain (ItemNumber)
	--SELECT --l.ItemSerie,
 --         --l.ItemNumber 
	--	  *
	--FROM #listGuidesBrain l


	  SELECT ord.Guide_Serie [GuideSerie],
           ord.Guide_Number [GuideNumber],
           ord.IsCollect [IsCollect],
           ord.PriceShippment [Price],
           ord.Collect_OnDelivery [COD],
           cst.TotalAmountPaid [AmountPaid],
           cst.CODAmount [CODPaid],
           IIF(cst.CODAmount IS NULL, 0, IIF(CST.CODAmount = ORD.Collect_OnDelivery,  1,0)) [CODIsPaid],
           ISNULL(
                     pyt.TimePlaId,
                     IIF(ord.IsCollect = 'true',
                         @CollectTime,
                         IIF(cdp.ConditionOfPaymenAbbreviation IS NULL, @MinTime, @MaxTime))
                 ) [PaymentTime],
           ISNULL(
                     tim.TimeSequence,
                     IIF(ord.IsCollect = 'true',
                         @CollectSequence,
                         IIF(cdp.ConditionOfPaymenAbbreviation IS NULL, @MinSequenceTime, @MaxSequenceTime))
                 ) [TimeSequence],
           inh.inv_certificationFEL [FelNumber],
           IIF(inh.inv_certificationFEL IS NULL, IIF(ISNULL(cst.TotalAmountPaid, 0) = 0, 0, 1), 1) [IsPaid],
           cus.IdCustomer [IsCustomer],
           cdp.ConditionOfPaymenDescription [ConditionPayment],
           IIF(cdp.ConditionOfPaymenAbbreviation IS NULL, 0, 1) [HaveCredit],
           ISNULL(@InCollectCOD, 0) [CollectCOD],
           ISNULL(ISNULL(rh.ReturnRate, rhd.ReturnRate), 100) [ReturnRate]
    INTO #TempPrice
    FROM #listGuidesBrain lg WITH(NOLOCK)
        inner JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
            ON  ord.Guide_Serie = lg.ItemSerie               
			AND ord.Guide_Number = lg.ItemNumber
        LEFT JOIN dbo.Cost cst WITH (NOLOCK)
            ON cst.GuideSerie = lg.ItemSerie AND cst.GuideNumber = lg.ItemNumber
               AND cst.RowStatus = 1
        LEFT JOIN dbo.DeliveryOrderPaymentDetail pyt WITH (NOLOCK)
            ON pyt.GuideSerie = lg.ItemSerie
               AND pyt.GuideNumber = lg.ItemNumber
        LEFT JOIN dbo.invoiceDetail ind WITH (NOLOCK)
            ON ind.dti_fk_orderSerie = lg.ItemSerie
               AND ind.dti_fk_orderNumber = lg.ItemNumber
        LEFT JOIN dbo.CatPaymentTime tim WITH (NOLOCK)
            ON tim.TimePlaId = pyt.TimePlaId
        LEFT JOIN dbo.invoiceHeader inh WITH (NOLOCK)
            ON inh.inv_pk_id = ind.dti_fk_header
               AND inh.inv_invoiceOfCreditNote = NULL
        LEFT JOIN dbo.Customer cus WITH (NOLOCK)
            ON cus.IdCustomer =
            (
                SELECT TOP 1
                       ISNULL(ord.IdCustomer, vpc.CustomerID)
                FROM dbo.VisitPointClient vpc WITH (NOLOCK)
                WHERE vpc.CodeOfReference = ord.Sender_ID
            )
        LEFT JOIN dbo.CatConditionOfPayment cdp WITH (NOLOCK)
            ON cdp.IdConditionOfPayment = cus.ConditionOfPaymentID
               AND cdp.IdConditionOfPayment > 1
        LEFT JOIN dbo.RatebyCustomer rc WITH (NOLOCK)
            ON rc.RbcIdCustomer = cus.IdCustomer
               AND rc.RbcRowStatus = 'TRUE'
		LEFT JOIN dbo.RatebyCustomer rcv WITH (NOLOCK)
			ON rcv.RbcIdCustomer = cus.IdCustomer AND rcv.RbcRowStatus = 'true' AND rcv.RbcCodeOfReference = ord.Sender_ID
        LEFT JOIN dbo.RateHeader rh WITH (NOLOCK)
            ON rh.RheId = ISNULL( rcv.RbcIdRate, rc.RbcIdRate)
        LEFT JOIN dbo.RateHeader rhd WITH (NOLOCK)
            ON rhd.RheDefault = 'true'
               AND cdp.RowStatus = 1
    WHERE --rc.RbcCodeOfReference IS NULL
         ISNULL(rcv.RbcRowStatus,rc.RbcRowStatus) = 1
         AND IIF(ord.SenderCountryId IS NULL, 'GT',ord.SenderCountryId) = @IdCountry
    ORDER BY lg.ItemSerie,
             lg.ItemNumber;

	CREATE NONCLUSTERED INDEX IDX_TEMPPRICEBRAIN ON #TempPrice (IsCustomer, GuideNumber)

			 PRINT '************************************************************************************* SELECT DISTINCT'
	
    SELECT DISTINCT
           tp.*,
           CASE tp.IsPaid
               WHEN 1 THEN
                   0 -- esta pagado
               ELSE -- no esta pagado
                   CASE
                       WHEN @_IsReturn = 'false' THEN
                           CASE tp.HaveCredit
                               WHEN 1 THEN --- cliente tiene credito
                                   CASE @TimeShortName
                                       WHEN 'POST' THEN
                                           tp.Price
                                       WHEN 'DEST' THEN
                                           IIF(tp.IsCollect = 1, tp.Price, 0)
                                       ELSE
                                           0
                                   END
                               ELSE -- cliente no tiene credito
                                   CASE
                                       WHEN tp.TimeSequence <= @InSequenceTime THEN
                                           /*CASE @_InTime
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
           IIF(tp.CollectCOD = 'true', IIF(@_IsReturn = 'true', 0, IIF(tp.CODIsPaid = 1, 0, tp.COD)), 0) [CODAmount],
           CASE tp.IsPaid
               WHEN 1 THEN
                   0 -- esta pagado
               ELSE -- no esta pagado
                   CASE
                       WHEN @_IsReturn = 'true' THEN
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
             tp.GuideNumber
			 OPTION(OPTIMIZE FOR UNKNOWN);

	DROP TABLE #TempPrice
	DROP TABLE #listGuidesBrain
END;