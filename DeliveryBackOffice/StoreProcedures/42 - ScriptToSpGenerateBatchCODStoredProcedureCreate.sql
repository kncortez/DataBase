USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_generate_batch_cod]    Script Date: 25/06/2021 08:21:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_generate_batch_cod]
AS
BEGIN
	DECLARE @Token VARCHAR(50) = 'SYS.SERVICECOD';
	DECLARE @ModuleName NVARCHAR(50) = 'Courier App';
	DECLARE @ProductNumber NVARCHAR(MAX) = (SELECT STUFF((SELECT ',' + CONCAT(pg.GuideSerie, pg.GuideNumber) 
														  FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pg
														  WHERE pg.BatchCODId IS NULL
														  AND pg.BatchCODIdCommission IS NULL
														  FOR XML PATH ('')), 1, 1, ''));
	DECLARE @IdModule INT = (SELECT cm.ModIdModule
							 FROM DeliveryBackOffice.dbo.CatModule cm
							 WHERE cm.ModName = @ModuleName);
	DECLARE @CountGuides INT = (SELECT COUNT(1) 
								FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pg
								WHERE pg.BatchCODId IS NULL
								AND pg.BatchCODIdCommission IS NULL);

	IF @CountGuides > 0
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
		SET NOCOUNT ON;

		-- Insert statements for procedure here
		IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
		IF OBJECT_ID('tempdb.dbo.#TempData', 'U') IS NOT NULL DROP TABLE #TempData;
		IF OBJECT_ID('tempdb.dbo.#CODData', 'U') IS NOT NULL DROP TABLE #CODData;
		IF OBJECT_ID('tempdb.dbo.#RevalueGuides', 'U') IS NOT NULL DROP TABLE #RevalueGuides;
		IF OBJECT_ID('tempdb.dbo.#TableAmountCODTemp', 'U') IS NOT NULL DROP TABLE #TableAmountCODTemp;
		IF OBJECT_ID('tempdb.dbo.#TableCustomerPaymentTemp', 'U') IS NOT NULL DROP TABLE #TableCustomerPaymentTemp;
		IF OBJECT_ID('tempdb.dbo.#TableForzaPaymentTemp', 'U') IS NOT NULL DROP TABLE #TableForzaPaymentTemp;
		IF OBJECT_ID('tempdb.dbo.#TableBACFormatTemp', 'U') IS NOT NULL DROP TABLE #TableBACFormatTemp;
		IF OBJECT_ID('tempdb.dbo.#TableFullFormatTemp', 'U') IS NOT NULL DROP TABLE #TableFullFormatTemp;
		IF OBJECT_ID('tempdb.dbo.#TableDistinctBankTemp', 'U') IS NOT NULL DROP TABLE #TableDistinctBankTemp;
		IF OBJECT_ID('tempdb.dbo.#TableDistinctBankIndexTemp', 'U') IS NOT NULL DROP TABLE #TableDistinctBankIndexTemp;
		IF OBJECT_ID('tempdb.dbo.#TableDistinctBankFinalIndexTemp', 'U') IS NOT NULL DROP TABLE #TableDistinctBankFinalIndexTemp;

		SELECT DISTINCT SUBSTRING(Item, 1, 2) ItemSerie,
						SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 3))) ItemNumber 
		INTO #listGuides
		FROM DeliveryBackOffice.dbo.SplitUnlimited(@ProductNumber, ',');

		DECLARE @IdRateDefault INT = (SELECT TOP 1 rh.RheId 
									  FROM DeliveryBackOffice.dbo.RateHeader rh
									  WHERE rh.RheRowStatus = 1 
									  AND rh.RheDefault = 1);
		DECLARE @IdRate INT;
		DECLARE @CODRateDefault DECIMAL(12, 2) = (SELECT CONVERT(DECIMAL(12, 2), ISNULL(cf.Value, '0')) val 
												  FROM DeliveryBackOffice.dbo.ConfigParams cf 
												  WHERE cf.Name = 'CODRateDef' 
												  AND Status = 1);
		DECLARE @CODExemptDefault DECIMAL(12, 2) = (SELECT CONVERT(DECIMAL(12, 2), ISNULL(cf.Value, '0')) val 
													FROM DeliveryBackOffice.dbo.ConfigParams cf 
													WHERE cf.Name = 'CODExemptDef' 
													AND Status = 1);

		---- Revalorizar guias que no tengan un precio asociado ---------------------------------------------
		SELECT ord.Guide_Serie, ord.Guide_Number
		INTO #RevalueGuides
		FROM #listGuides lst
		JOIN DeliveryBackOffice.dbo.DeliveryOrder ord 
			ON ord.Guide_Number = lst.ItemNumber 
			AND ord.Guide_Serie = lst.ItemSerie
		WHERE ord.PriceShippment IS NULL -- precion nulo
		OR ord.PriceShippment <= 0 -- precio 0
		OR ord.StatusOrderId = 14; -- guias devuletas

		DECLARE @count INT = 1;
		DECLARE @RevalueSerie VARCHAR(10);
		DECLARE @RevalueGuide INT;
		DECLARE @IdMax INT = (SELECT COUNT(1) 
							  FROM #RevalueGuides);
		DECLARE @RC INT;

		WHILE @count <= @IdMax
		BEGIN
			SELECT TOP 1 
				@RevalueSerie = rv.Guide_Serie,
				@RevalueGuide = rv.Guide_Number
			FROM #RevalueGuides rv;

			EXECUTE @RC = DeliveryBackOffice.dbo.spws_revalue_guide
				@GuideSerie = @RevalueSerie,
				@GuideNumber = @RevalueGuide,
				@CodeApp = '',
				@Format = 'Non',
				@CalculateTaxes = 'true',
				@IdModule = @IdModule,
				@SetUpdate = 'true',
				@Token = @Token,
				@IsReturn = 'false'
			SET @count = @count + 1;
			DELETE TOP (1) FROM #RevalueGuides;
		END
		-----------------------------------------------------------------------------------------------------

		SELECT lst.*, 
			ord.Sender_ID, 
			ord.Collect_OnDelivery, 
			ISNULL(ord.IdCustomer, vpc.CustomerID) IDCUSTOMER, 
			ISNULL(rc.RbcIdRate, @idRateDefault) IdRate, 
			IIF(ord.TypeService = 'EXP' , 'NDD', ISNULL(ord.TypeService, 'NDD')) Serv, 
			twn.HeaderCode, 
			(SELECT TOP 1 hb.IdHubLogistic 
			 FROM DeliveryBackOffice.dbo.DumpServiceCoverage cv 
			 JOIN DeliveryBackOffice.dbo.HubLogistics hb 
				ON hb.HubAbbreviation = cv.Hub	
			 WHERE cv.HeaderCode = twn.HeaderCode) Hub, 
			 csv.CtsId IdService, 
			 ord.DCBA_ID 
		INTO #TempData
		FROM #listGuides lst
		JOIN DeliveryBackOffice.dbo.DeliveryOrder ord 
			ON ord.Guide_Serie = lst.ItemSerie 
			AND ord.Guide_Number = lst.ItemNumber
		LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc 
			ON vpc.CodeOfReference = ord.Sender_ID
		LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer rc 
			ON rc.RbcIdCustomer = ISNULL(ord.IdCustomer, vpc.CustomerID) 
			AND rc.RbcRowStatus = 'true'
		LEFT JOIN DeliveryBackOffice.dbo.Township twn 
			ON twn.IdTownship = ISNULL(ISNULL(ISNULL(ord.ReceiverIdTownship, vpc.IdTownship), 
											  (SELECT TOP 1 st.IdTownship 
											   FROM DeliveryBackOffice.dbo.Settlement st 
											   WHERE st.IdSettlement = vpc.IdSettlement)), 
									   (SELECT TOP 1 IdTownship 
										FROM DeliveryBackOffice.dbo.Township twn 
										WHERE twn.TownshipName = ord.Receiver_Town 
										AND twn.TownshipStatus = 'true'))
		LEFT JOIN DeliveryBackOffice.dbo.CatTypeService csv 
			ON csv.CtsShortName = IIF(ord.TypeService = 'EXP', 'NDD', isnull(ord.TypeService, 'NDD')) 
			AND csv.CtsRowStatus = 'true';

		DECLARE @IdSegmentDefault INT = (SELECT TOP 1 CrsId 
										 FROM DeliveryBackOffice.dbo.CatRateSegment 
										 WHERE CrsShortName = 'FOR' 
										 AND CrsRowStatus = 'true');

		SELECT td.*, 
			ISNULL(cv.SegmentId, @IdSegmentDefault) IdSegment,
			ISNULL(rc.CODRate, @CODRateDefault) CODRate,
			ISNULL(rc.CODExempt, @CODExemptDefault) CODExempt, 
			CONVERT(DECIMAL(12, 2), ((ISNULL(td.Collect_OnDelivery, 0) - ISNULL(rc.CODExempt, @CODExemptDefault)) * 
									ISNULL(rc.CODRate, @CODRateDefault) / 100)) Commission
		INTO #CODData
		FROM #TempData td
		LEFT JOIN DeliveryBackOffice.dbo.VisitPointCoverage cv 
			ON cv.VisitPointId = td.Sender_ID 
			AND cv.HubLogisticId = td.Hub 
			AND cv.RowStatus = 'true'
		LEFT JOIN DeliveryBackOffice.dbo.RateCOD rc 
			ON rc.RateId = td.IdRate 
			AND rc.TypeServiceId = td.IdService 
			AND rc.TypeSegmentId = ISNULL(cv.SegmentId, @IdSegmentDefault) 
			AND rc.RowStatus = 1
		ORDER BY td.IDCUSTOMER, td.ItemSerie, td.ItemNumber, td.Collect_OnDelivery;

		DECLARE @MaxPaymentTIme INT = (SELECT TOP 1 pt.TimePlaId 
									   FROM DeliveryBackOffice.dbo.CatPaymentTime pt 
									   WHERE pt.TimePlaStatus = 1 
									   AND pt.TimeSequence = (SELECT MAX(ps.TimeSequence) 
															  FROM DeliveryBackOffice.dbo.CatPaymentTime ps 
															  WHERE ps.TimePlaStatus = 1));
		DECLARE @PendingPaymentTemp TABLE (	
											GuideSerie NVARCHAR(25) NULL,
											GuideNumber INT,
											IsCollect BIT,
											Price DECIMAL(14, 2) NULL,
											COD DECIMAL(14, 2) NULL,
											AmountPaid DECIMAL(14, 2) NULL,
											CODPaid DECIMAL(14, 2) NULL,
											CODIsPaid BIT,
											PaymentTime INT NULL,
											TimeSequence INT NULL,
											FelNumber NVARCHAR(50) NULL,
											IsPaid BIT,
											IsCustomer INT NULL,
											ConditionPayment VARCHAR(200),
											HaveCredit BIT,
											CollectCOD BIT,
											ReturnRate DECIMAL(14, 2) NULL,
											AmountToPay DECIMAL(14, 2) NULL,
											CODAmount DECIMAL(14, 2) NULL,
											ReturnRates DECIMAL(14, 2) NULL
										  );

		INSERT INTO @PendingPaymentTemp (GuideSerie, GuideNumber, IsCollect, Price, COD, 
										 AmountPaid, CODPaid, CODIsPaid, PaymentTime, TimeSequence,
										 FelNumber, IsPaid, IsCustomer, ConditionPayment, HaveCredit,
										 CollectCOD, ReturnRate, AmountToPay, CODAmount, ReturnRates)
		EXEC  DeliveryBackOffice.dbo.spws_get_guide_pending_payment
			@InGuides = @ProductNumber,
			@InTime = @MaxPaymentTIme,
			@IsReturn = 'false',
			@CodeApp = 'SIFDCECOM300720201459',
			@IdModule = @IdModule,
			@Token = @Token;

		DECLARE @TableAmountCOD TABLE (
										ItemSerie NVARCHAR(2),
										ItemNumber INT,
										Collect_OnDelivery DECIMAL(18, 2),
										IDCUSTOMER INT,
										CODRate DECIMAL(18, 2),
										CODExempt DECIMAL(18, 2),
										Commission DECIMAL(18, 2),
										DeliveryPrice DECIMAL(18, 2),
										CODPaid DECIMAL(18, 2),
										ReturnRates DECIMAL(18, 2),
										CODIsPaid BIT,
										Id_bank INT,
										[Name] NVARCHAR(50),
										DCBA_Id INT,
										DCBA_Num_account NVARCHAR(50),
										DCBA_Nom_account NVARCHAR(50),
										DCBA_BankAccountType NVARCHAR(50),
										DCBA_Identification NVARCHAR(50),
										Deposit_Number INT,
										CODtoPay DECIMAL(18, 2),
										Price DECIMAL(18, 2)
									  );

		INSERT INTO @TableAmountCOD (ItemSerie, ItemNumber, Collect_OnDelivery, IDCUSTOMER, CODRate,
									 CODExempt, Commission, DeliveryPrice, CODPaid, ReturnRates,
									 CODIsPaid, Id_bank, [Name], DCBA_Id, DCBA_Num_account,
									 DCBA_Nom_account, DCBA_BankAccountType, DCBA_Identification, Deposit_Number, CODtoPay,
									 Price)
		SELECT tp.ItemSerie, 
			tp.ItemNumber, 
			tp.Collect_OnDelivery, 
			tp.IDCUSTOMER, 
			tp.CODRate, 
			tp.CODExempt, 
			tp.Commission, 
			pp.AmountToPay DeliveryPrice, 
			pp.CODPaid, 
			pp.ReturnRates, 
			pp.CODIsPaid, 
			bk.Id_bank, 
			bk.Name, 
			dc.DCBA_Id, 
			dc.DCBA_Num_account, 
			dc.DCBA_Nom_account, 
			dc.DCBA_BankAccountType, 
			dc.DCBA_Identification, 
			op.Deposit_Number, 
			IIF(op.Deposit_Number IS NULL, (tp.Collect_OnDelivery - tp.Commission - pp.AmountToPay - pp.ReturnRates), 0) CODtoPay,
			pp.Price
		FROM #CODData tp
		LEFT JOIN @PendingPaymentTemp pp 
			ON pp.GuideSerie = tp.ItemSerie 
			AND pp.GuideNumber = tp.ItemNumber
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaid op 
			ON op.Guide_Serie = tp.ItemSerie 
			AND op.Guide_Number = tp.ItemNumber
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dc 
			ON dc.DCBA_Id = tp.DCBA_ID
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank bk 
			ON bk.Id_bank = dc.DCBA_Bank_Id
		WHERE tp.Collect_OnDelivery > 0
		ORDER BY tp.IDCUSTOMER, tp.ItemSerie, tp.ItemNumber;

		SELECT ItemSerie, ItemNumber, Collect_OnDelivery, IDCUSTOMER, CODRate,
			   CODExempt, Commission, SUM(DeliveryPrice) DeliveryPrice, SUM(ISNULL(CODPaid, 0)) CODPaid, ReturnRates,
			   Id_bank, [Name], DCBA_Id, DCBA_Num_account, DCBA_Nom_account, 
			   DCBA_BankAccountType, MIN(CODtoPay) CODtoPay, MAX(Price) Price
		INTO #TableAmountCODTemp
		FROM @TableAmountCOD
		GROUP BY ItemSerie, ItemNumber, Collect_OnDelivery, IDCUSTOMER, CODRate,
			   CODExempt, Commission, ReturnRates, Id_bank, [Name], 
			   DCBA_Id, DCBA_Num_account, DCBA_Nom_account, DCBA_BankAccountType
		ORDER BY ItemNumber;

		DECLARE @UpdateLast INT;
		DECLARE @BankName NVARCHAR(50) = 'BANCO DE AMERICA CENTRAL';
		DECLARE @IdCountry NVARCHAR(50) = 'GT';
		DECLARE @InAccount NVARCHAR(50) = 'CUENTAS INTERNAS BAC O BANCOR';
		DECLARE @OutAccount NVARCHAR(50) = 'CREDITOS ENVIAR FONDOS A OTROS BANCOS';
		DECLARE @AccountType NVARCHAR(50) = 'MONETARIA';
		DECLARE @ConceptCustomer NVARCHAR(50) = 'ENTREGAS';
		DECLARE @CreditAccount NVARCHAR(50) = '903666261';
		DECLARE @ConceptForza NVARCHAR(50) = 'COMISION';
		DECLARE @BankBAC INT = (SELECT db.Id_bank
								FROM DeliveryBackOffice.dbo.DeliveryBank db
								WHERE db.Name = @BankName
								AND db.Id_status = 1
								AND db.Id_country = @IdCountry);
		DECLARE @CreditAccountId INT = (SELECT DCBA_Id
										FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount
										WHERE DCBA_Bank_Id = @BankBAC
										AND DCBA_Num_account = @CreditAccount
										AND DCBA_Id_estado = 1);
		DECLARE @Reference INT = (SELECT Last
								  FROM DeliveryBackOffice.dbo.CatCorrelativeCOD
								  WHERE BankId = @BankBAC
								  AND RowStatus = 1)

		SELECT tact.ItemSerie GuideSerie, 
			   tact.ItemNumber GuideNumber, 
			   (SELECT IdCatDebitAccountCOD 
				FROM DeliveryBackOffice.dbo.CatDebitAccountCOD 
				WHERE BankId = tact.Id_bank 
				AND RowStatus = 1) CatDebitAccountCODId,
			   tact.DCBA_Id CreditAccountId,
			   tact.CODtoPay Amount,
			   tact.Commission,
			   IIF(tact.Id_bank NOT IN (SELECT DISTINCT PayingBank
										FROM DeliveryBackOffice.dbo.DeliveryBank
										WHERE Id_country = @IdCountry
										AND Id_status = 1
										AND PayingBank <> @BankBAC), 
				   IIF(tact.Id_bank = @BankBAC, (SELECT IdCatTransactionTypeCOD
												 FROM DeliveryBackOffice.dbo.CatTransactionTypeCOD 
												 WHERE BankId = tact.Id_bank 
												 AND RowStatus = 1
												 AND Description = @InAccount), 
												(SELECT IdCatTransactionTypeCOD
												 FROM DeliveryBackOffice.dbo.CatTransactionTypeCOD 
												 WHERE BankId = @BankBAC 
												 AND RowStatus = 1
												 AND Description = @OutAccount)), 
				   NULL) CatTransactionTypeCODId,
			   tact.Id_bank BankId,
			   (SELECT IdCatAccountTypeCOD
				FROM DeliveryBackOffice.dbo.CatAccountTypeCOD
				WHERE RowStatus = 1
				AND AccountType = IIF(tact.DCBA_BankAccountType = '', 
									  @AccountType, 
									  ISNULL(UPPER(tact.DCBA_BankAccountType), 
											 @AccountType))) CatAccountTypeCODId,
			   (SELECT IdCatConceptCOD
				FROM DeliveryBackOffice.dbo.CatConceptCOD
				WHERE RowStatus = 1
				AND Concept LIKE ('%' + @ConceptCustomer)) CatConceptCODId
		INTO #TableCustomerPaymentTemp
		FROM #TableAmountCODTemp tact;

		SELECT tact.ItemSerie GuideSerie, 
			   tact.ItemNumber GuideNumber, 
			   (SELECT IdCatDebitAccountCOD 
				FROM DeliveryBackOffice.dbo.CatDebitAccountCOD 
				WHERE BankId = @BankBAC 
				AND RowStatus = 1) CatDebitAccountCODId,
			   @CreditAccountId CreditAccountId,
			   (tact.Commission + IIF(do.IsCollect = 1, tact.Price, 0)) Amount,
			   tact.Commission,
			   (SELECT IdCatTransactionTypeCOD
				FROM DeliveryBackOffice.dbo.CatTransactionTypeCOD 
				WHERE BankId = @BankBAC 
				AND RowStatus = 1
				AND Description = @InAccount) CatTransactionTypeCODId,
			   @BankBAC BankId,
			   (SELECT IdCatAccountTypeCOD
				FROM DeliveryBackOffice.dbo.CatAccountTypeCOD
				WHERE RowStatus = 1
				AND AccountType = UPPER(@AccountType)) CatAccountTypeCODId,
			   (SELECT IdCatConceptCOD
				FROM DeliveryBackOffice.dbo.CatConceptCOD
				WHERE RowStatus = 1
				AND Concept LIKE (@ConceptForza + '%')) CatConceptCODId
		INTO #TableForzaPaymentTemp
		FROM #TableAmountCODTemp tact
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do
			ON do.Guide_Serie = tact.ItemSerie
			AND do.Guide_Number = tact.ItemNumber;

		SELECT *
		INTO #TableBACFormatTemp
		FROM #TableCustomerPaymentTemp
		WHERE BankId NOT IN (SELECT DISTINCT PayingBank
							 FROM DeliveryBackOffice.dbo.DeliveryBank
							 WHERE Id_country = @IdCountry
							 AND Id_status = 1
							 AND PayingBank <> @BankBAC)
		UNION ALL
		SELECT *
		FROM #TableForzaPaymentTemp;

		UPDATE #TableBACFormatTemp
		SET CatDebitAccountCODId = (SELECT IdCatDebitAccountCOD 
									FROM DeliveryBackOffice.dbo.CatDebitAccountCOD 
									WHERE BankId = @BankBAC 
									AND RowStatus = 1)
		WHERE CatDebitAccountCODId IS NULL;

		SELECT @UpdateLast = COUNT(1)
		FROM #TableBACFormatTemp;

		SELECT *, NULL Reference 
		INTO #TableFullFormatTemp
		FROM #TableCustomerPaymentTemp 
		WHERE BankId IN (SELECT DISTINCT PayingBank
						 FROM DeliveryBackOffice.dbo.DeliveryBank
						 WHERE Id_country = @IdCountry
						 AND Id_status = 1
						 AND PayingBank <> @BankBAC)
		AND Amount > 0
		UNION ALL
		SELECT *, ((ROW_NUMBER() OVER(ORDER BY GuideNumber)) + @Reference) Reference 
		FROM #TableBACFormatTemp
		WHERE Amount > 0;

		SELECT @Reference = MAX(Reference)
		FROM #TableFullFormatTemp;

		UPDATE DeliveryBackOffice.dbo.CatCorrelativeCOD
		SET Last = @Reference
		WHERE BankId = @BankBAC
		AND RowStatus = 1;

		DECLARE @Index INT = 1;
		DECLARE @MaxSize INT;
		DECLARE @MaxBatchNumber INT = ((SELECT ISNULL(MAX(BatchNumber), 0)
										FROM DeliveryBackOffice.dbo.BatchCOD) + 1);

		SELECT DISTINCT PayingBank, NULL IdBatchCOD
		INTO #TableDistinctBankTemp
		FROM DeliveryBackOffice.dbo.DeliveryBank
		WHERE Id_country = @IdCountry
		AND Id_status = 1;

		SELECT *, (ROW_NUMBER() OVER(ORDER BY PayingBank)) IndexRow 
		INTO #TableDistinctBankIndexTemp
		FROM #TableDistinctBankTemp;

		SELECT @MaxSize = COUNT(1)
		FROM #TableDistinctBankIndexTemp;

		WHILE @Index <= @MaxSize
		BEGIN
			DECLARE @NewIdBatchCOD INT;
			DECLARE @ExistRows INT;
			DECLARE @ActualBankId INT = (SELECT PayingBank
										 FROM #TableDistinctBankIndexTemp
										 WHERE IndexRow = @Index);

			IF @ActualBankId IN (SELECT DISTINCT PayingBank
								 FROM DeliveryBackOffice.dbo.DeliveryBank
								 WHERE Id_country = @IdCountry
								 AND Id_status = 1
								 AND PayingBank <> @BankBAC)
			BEGIN
				SELECT @ExistRows = COUNT(1)
				FROM #TableFullFormatTemp
				WHERE BankId = @ActualBankId;
			END
			ELSE
			BEGIN
				SELECT @ExistRows = COUNT(1)
				FROM #TableFullFormatTemp
				WHERE BankId NOT IN (SELECT DISTINCT PayingBank
									 FROM DeliveryBackOffice.dbo.DeliveryBank
									 WHERE Id_country = @IdCountry
									 AND Id_status = 1
									 AND PayingBank <> @BankBAC);
			END

			IF @ExistRows > 0
			BEGIN
				INSERT INTO DeliveryBackOffice.dbo.BatchCOD (BankId, BatchNumber)
					VALUES (@ActualBankId, @MaxBatchNumber);

				SELECT @NewIdBatchCOD = SCOPE_IDENTITY();

				UPDATE #TableDistinctBankIndexTemp
				SET IdBatchCOD = @NewIdBatchCOD
				WHERE IndexRow = @Index;

				IF @ActualBankId = @BankBAC
				BEGIN
					INSERT INTO DeliveryBackOffice.dbo.BatchDetailCOD 
							(BatchCODId, GuideSerie, GuideNumber, CatDebitAccountCODId, CreditAccountId, 
							 Amount, Commission, CatTransactionTypeCODId, BankId, CatAccountTypeCODId, 
							 CatConceptCODId, Reference)
					SELECT @NewIdBatchCOD, GuideSerie, GuideNumber, CatDebitAccountCODId, CreditAccountId, 
						   Amount, Commission, CatTransactionTypeCODId, BankId, CatAccountTypeCODId, 
						   CatConceptCODId, Reference
					FROM #TableFullFormatTemp
					WHERE BankId NOT IN (SELECT DISTINCT PayingBank
										 FROM DeliveryBackOffice.dbo.DeliveryBank
										 WHERE Id_country = @IdCountry
										 AND Id_status = 1
										 AND PayingBank <> @BankBAC);
				END
				ELSE
				BEGIN
					INSERT INTO DeliveryBackOffice.dbo.BatchDetailCOD 
							(BatchCODId, GuideSerie, GuideNumber, CatDebitAccountCODId, CreditAccountId, 
							 Amount, Commission, CatTransactionTypeCODId, BankId, CatAccountTypeCODId, 
							 CatConceptCODId, Reference)
					SELECT @NewIdBatchCOD, GuideSerie, GuideNumber, CatDebitAccountCODId, CreditAccountId, 
						   Amount, Commission, CatTransactionTypeCODId, BankId, CatAccountTypeCODId, 
						   CatConceptCODId, Reference
					FROM #TableFullFormatTemp
					WHERE BankId = @ActualBankId;
				END
			END
			ELSE
			BEGIN
				DELETE FROM #TableDistinctBankIndexTemp
				WHERE IndexRow = @Index;
			END

			SET @Index = @Index + 1;
		END

		SELECT PayingBank, IdBatchCOD, (ROW_NUMBER() OVER(ORDER BY PayingBank)) IndexRow 
		INTO #TableDistinctBankFinalIndexTemp
		FROM #TableDistinctBankIndexTemp

		DECLARE @Index2 INT = 1;
		DECLARE @MaxSize2 INT;

		SELECT @MaxSize2 = COUNT(1)
		FROM #TableDistinctBankFinalIndexTemp;

		WHILE @Index2 <= @MaxSize2
		BEGIN
			DECLARE @ActualBank INT = (SELECT PayingBank
									   FROM #TableDistinctBankFinalIndexTemp
									   WHERE IndexRow = @Index2);

			IF @ActualBank IN (SELECT DISTINCT PayingBank
							   FROM DeliveryBackOffice.dbo.DeliveryBank
							   WHERE Id_country = @IdCountry
							   AND Id_status = 1
							   AND PayingBank <> @BankBAC)
			BEGIN
				UPDATE DeliveryBackOffice.dbo.ProcessedGuideCOD
				SET BatchCODId = (SELECT IdBatchCOD
								  FROM #TableDistinctBankFinalIndexTemp
								  WHERE PayingBank = @ActualBank),
					BatchCODIdCommission = (SELECT IdBatchCOD
											FROM #TableDistinctBankFinalIndexTemp
											WHERE PayingBank = @BankBAC)
				WHERE CONCAT(GuideSerie, CAST(GuideNumber AS nvarchar(50))) 
						IN (SELECT DISTINCT CONCAT(tfft.GuideSerie, CAST(tfft.GuideNumber AS nvarchar(50)))
							FROM #TableFullFormatTemp tfft
							WHERE tfft.BankId = @ActualBank)
				AND BatchCODId IS NULL
				AND BatchCODIdCommission IS NULL;
			END
			ELSE
			BEGIN
				UPDATE DeliveryBackOffice.dbo.ProcessedGuideCOD
				SET BatchCODId = (SELECT IdBatchCOD
								  FROM #TableDistinctBankFinalIndexTemp
								  WHERE PayingBank = @BankBAC),
					BatchCODIdCommission = (SELECT IdBatchCOD
											FROM #TableDistinctBankFinalIndexTemp
											WHERE PayingBank = @BankBAC)
				WHERE CONCAT(GuideSerie, CAST(GuideNumber AS nvarchar(50))) 
						IN (SELECT DISTINCT CONCAT(tffte.GuideSerie, CAST(tffte.GuideNumber AS nvarchar(50)))
							FROM #TableFullFormatTemp tffte
							WHERE CONCAT(tffte.GuideSerie, CAST(tffte.GuideNumber AS nvarchar(50)))
								NOT IN (SELECT DISTINCT CONCAT(tfft.GuideSerie, CAST(tfft.GuideNumber AS nvarchar(50)))
										FROM #TableFullFormatTemp tfft
										WHERE tfft.BankId IN (SELECT DISTINCT PayingBank
															  FROM DeliveryBackOffice.dbo.DeliveryBank
															  WHERE Id_country = @IdCountry
															  AND Id_status = 1
															  AND PayingBank <> @BankBAC)))
				AND BatchCODId IS NULL
				AND BatchCODIdCommission IS NULL;
			END

			SET @Index2 = @Index2 + 1;
		END

		--SELECT * FROM #TableAmountCODTemp;
		--SELECT * FROM #TableCustomerPaymentTemp;
		--SELECT * FROM #TableForzaPaymentTemp;
		--SELECT * FROM #TableBACFormatTemp;
		--SELECT * FROM #TableDistinctBankTemp;
		--SELECT * FROM #TableFullFormatTemp;
		--SELECT * FROM #TableDistinctBankIndexTemp;
		
		-- SOLO PARA BANCO BANRURAL
		SELECT * FROM #TableDistinctBankFinalIndexTemp
		WHERE PayingBank = 5;
	END
	ELSE
	BEGIN
		SELECT 'NO HAY GUIAS PARA PROCESAR';
	END
END
GO


