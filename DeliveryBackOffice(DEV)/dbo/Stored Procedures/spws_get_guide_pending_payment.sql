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


	  SELECT ord20.[GuideSerie],
			 ord20.[GuideNumber],
			 ord20.[IsCollect],
			 ord20.[Price],
             ord20.[COD],
			 ord20.[AmountPaid],
			 ord20.[CODPaid],
             IIF(ord20.CODAmount IS NULL, 0, IIF(ord20.CODAmount = ord20.Collect_OnDelivery,  1,0)) [CODIsPaid],
             ISNULL(
                     pyt.TimePlaId,
                     IIF(ord20.IsCollect = 'true',
                         @CollectTime,
                         IIF(cdp.ConditionOfPaymenAbbreviation IS NULL, @MinTime, @MaxTime))
                 ) [PaymentTime],
            ISNULL(
                     tim.TimeSequence,
                     IIF(ord20.IsCollect = 'true',
                         @CollectSequence,
                         IIF(cdp.ConditionOfPaymenAbbreviation IS NULL, @MinSequenceTime, @MaxSequenceTime))
                 ) [TimeSequence],
            inh.inv_certificationFEL [FelNumber],
            IIF(inh.inv_certificationFEL IS NULL, IIF(ISNULL(ord20.TotalAmountPaid, 0) = 0, 0, 1), 1) [IsPaid],
            cus.IdCustomer [IsCustomer],
            cdp.ConditionOfPaymenDescription [ConditionPayment],
            IIF(cdp.ConditionOfPaymenAbbreviation IS NULL, 0, 1) [HaveCredit],
            ISNULL(@InCollectCOD, 0) [CollectCOD],
            ISNULL(ISNULL(rh.ReturnRate, rhd.ReturnRate), 100) [ReturnRate]
			, ord20.[CurrencyPrice_CODCodeISO]
			, ord20.[CurrencyPrice_CODSymbol]
			, ord20.[CurrencyPriceCodeISO]   
			, ord20.[CurrencyPriceSymbol]
    INTO #TempPrice
    FROM #listGuidesBrain lg WITH(NOLOCK)
		OUTER APPLY
		(   --GUIAS DENTRO DEL MISMO PAIS
			SELECT ord.Guide_Serie		 [GuideSerie]
				, ord.Guide_Number		 [GuideNumber]
				, ord.IdCustomer		 [IdCustomer]
				, ord.Sender_Id			 [Sender_Id]
				, ord.SenderCountryId    [SenderCountryId]
				, ord.IsCollect			 [IsCollect]
				, ord.PriceShippment	 [Price]
				, ord.Collect_OnDelivery [COD]
				, ord.Collect_OnDelivery [Collect_OnDelivery]
				, cst.TotalAmountPaid	 [AmountPaid]
				, cst.TotalAmountPaid	 [TotalAmountPaid]
				, cst.CODAmount			 [CODPaid]
				, cst.CODAmount			 [CODAmount]
				, ccc.CodeISO            [CurrencyPrice_CODCodeISO]
				, ccc.Symbol             [CurrencyPrice_CODSymbol]
				, ccc.CodeISO            [CurrencyPriceCodeISO]   
				, ccc.Symbol			 [CurrencyPriceSymbol]
			FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]				ord WITH (NOLOCK)
				LEFT JOIN [DeliveryBackOffice].[dbo].[Cost]				cst WITH (NOLOCK)
					ON  cst.GuideSerie  = ord.Guide_Serie
					AND cst.GuideNumber = ord.Guide_Number
					AND cst.RowStatus = 1
				LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryCurrency]      de	WITH (NOLOCK)
					ON  de.Currency_IdCountry = ISNULL(ord.SenderCountryId,'GT')
					AND de.DefaultPerCountry = 1
				LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]	ccc WITH (NOLOCK)
					ON ccc.IdCatCurrencyCOD = de.IdCurrencyCOD
			WHERE	ord.Guide_Serie  = lg.ItemSerie               
				AND ord.Guide_Number = lg.ItemNumber
				AND ISNULL(ord.GuideType,'DOM') = 'DOM'
			UNION --GUIAS MULTIPAIS
			SELECT ord.Guide_Serie		 [GuideSerie]
				, ord.Guide_Number		 [GuideNumber]
				, ord.IdCustomer		 [IdCustomer]
				, ord.Sender_Id			 [Sender_Id]
				, ord.SenderCountryId    [SenderCountryId]
				, ord.IsCollect			 [IsCollect]
				, ROUND(((ord.PriceShippment / cst.CODExchangeRate) * ce.ExchangeRate),2,1)		[Price]
				, ROUND(((ord.Collect_OnDelivery / cst.CODExchangeRate) * ce.ExchangeRate),2,1)	[COD]
				, ROUND(((ord.Collect_OnDelivery / cst.CODExchangeRate) * ce.ExchangeRate),2,1)	[Collect_OnDelivery]
				, ROUND(((cst.TotalAmountPaid / cst.CODExchangeRate) * ce.ExchangeRate),2,1)	[AmountPaid]
				, ROUND(((cst.TotalAmountPaid / cst.CODExchangeRate) * ce.ExchangeRate),2,1)	[TotalAmountPaid]
				, ROUND(((cst.CODAmount / cst.CODExchangeRate) * ce.ExchangeRate),2,1)			[CODPaid]
				, ROUND(((cst.CODAmount / cst.CODExchangeRate) * ce.ExchangeRate),2,1)			[CODAmount]
				, ccc.CodeISO            [CurrencyPrice_CODCodeISO]
				, ccc.Symbol             [CurrencyPrice_CODSymbol]
				, ccc.CodeISO            [CurrencyPriceCodeISO]   
				, ccc.Symbol			 [CurrencyPriceSymbol]
			FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]					 ord WITH (NOLOCK)
				LEFT JOIN [DeliveryBackOffice].[dbo].[Cost]					 cst WITH (NOLOCK)
					ON  cst.GuideSerie  = ord.Guide_Serie
					AND cst.GuideNumber = ord.Guide_Number
					AND cst.RowStatus = 1                                            
				LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryCurrency]      de	WITH (NOLOCK)
					ON  de.Currency_IdCountry = ISNULL(ord.ReceiverCountryId,'GT')
					AND de.DefaultPerCountry = 1
				LEFT JOIN [DeliveryBackOffice].[dbo].[CurrencyExchangeRates] ce WITH (NOLOCK)
					ON ce.TargetCurrency = de.IdCurrencyCOD
					and CONVERT(date,ce.ExchangeDate) = CONVERT(date,getdate())
				LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]		 ccc WITH (NOLOCK)
					ON ccc.IdCatCurrencyCOD = de.IdCurrencyCOD
			WHERE	ord.Guide_Serie  = lg.ItemSerie               
				AND ord.Guide_Number = lg.ItemNumber
				AND ISNULL(ord.GuideType,'DOM') = 'INT'
		)	ord20
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
                       ISNULL(ord20.IdCustomer, vpc.CustomerID)
                FROM dbo.VisitPointClient vpc WITH (NOLOCK)
                WHERE vpc.CodeOfReference = ord20.Sender_ID
            )
        LEFT JOIN dbo.CatConditionOfPayment cdp WITH (NOLOCK)
            ON cdp.IdConditionOfPayment = cus.ConditionOfPaymentID
               AND cdp.IdConditionOfPayment > 1
        LEFT JOIN dbo.RatebyCustomer rc WITH (NOLOCK)
            ON rc.RbcIdCustomer = cus.IdCustomer
               AND rc.RbcRowStatus = 'TRUE'
		LEFT JOIN dbo.RatebyCustomer rcv WITH (NOLOCK)
			ON rcv.RbcIdCustomer = cus.IdCustomer 
				AND rcv.RbcCodeOfReference = ord20.Sender_ID
				AND rcv.RbcRowStatus = 'true' 
        LEFT JOIN dbo.RateHeader rh WITH (NOLOCK)
            ON rh.RheId = ISNULL( rcv.RbcIdRate, rc.RbcIdRate)
        LEFT JOIN dbo.RateHeader rhd WITH (NOLOCK)
            ON rhd.RheDefault = 'true'
               AND cdp.RowStatus = 1
    WHERE --rc.RbcCodeOfReference IS NULL
         ISNULL(rcv.RbcRowStatus,rc.RbcRowStatus) = 1
         --AND IIF(ord20.SenderCountryId IS NULL, 'GT',ord20.SenderCountryId) = @IdCountry
    ORDER BY lg.ItemSerie,
             lg.ItemNumber;

	CREATE NONCLUSTERED INDEX IDX_TEMPPRICEBRAIN ON #TempPrice (IsCustomer, GuideNumber)

			 PRINT '************************************************************************************* SELECT DISTINCT'
	
    SELECT DISTINCT
           tp.[GuideSerie]
	     , tp.[GuideNumber]
	     , tp.[IsCollect]
		 , tp.[Price]
         , tp.[COD]
		 , tp.[AmountPaid]
		 , tp.[CODPaid]
		 , tp.[CODIsPaid]
		 , tp.[PaymentTime]
		 , tp.[TimeSequence]
		 , tp.[FelNumber]
		 , tp.[IsPaid]
		 , tp.[IsCustomer]
		 , tp.[ConditionPayment]
		 , tp.[HaveCredit]
		 , tp.[CollectCOD]
		 , tp.[ReturnRate]
		 , tp.[CurrencyPrice_CODCodeISO]
		 , tp.[CurrencyPrice_CODSymbol]
		 , tp.[CurrencyPriceCodeISO]   
		 , tp.[CurrencyPriceSymbol]
         , CASE tp.IsPaid
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