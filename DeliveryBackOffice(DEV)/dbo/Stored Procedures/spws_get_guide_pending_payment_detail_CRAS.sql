-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-05-21>
-- Description:	<Devuleve el monto a cobrar >
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_guide_pending_payment_detail_CRAS]
    @InGuidesP VARCHAR(MAX),
    @IdModuleP INT,
	@ServiceType VARCHAR(100),
    @TokenP VARCHAR(100)
AS
BEGIN

	-- Insert statements for procedure here
	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
	IF OBJECT_ID('tempdb.dbo.#listGuidesNotExist', 'U') IS NOT NULL DROP TABLE #listGuidesNotExist;
	IF OBJECT_ID('tempdb.dbo.#listGuidesExcluded', 'U') IS NOT NULL DROP TABLE #listGuidesExcluded;
	IF OBJECT_ID('tempdb.dbo.#listGuidesIncluded', 'U') IS NOT NULL DROP TABLE #listGuidesIncluded;
	IF OBJECT_ID('tempdb.dbo.#RevalueGuides', 'U') IS NOT NULL DROP TABLE #RevalueGuides;
	IF OBJECT_ID('tempdb.dbo.#PendingPaymentTemp', 'U') IS NOT NULL DROP TABLE #PendingPaymentTemp;
	IF OBJECT_ID('tempdb.dbo.#PendingPaymentTempId', 'U') IS NOT NULL DROP TABLE #PendingPaymentTempId;
	
	--DECLARE @InGuidesP VARCHAR(MAX) = 'FD509086,FD509087,FD509088';
    --DECLARE @IdModuleP INT = 35;
	--DECLARE @ServiceType VARCHAR(100) = 'PICKUP';
    --DECLARE @TokenP VARCHAR(100) = '3E9C2157FD6D5863CFBA2366C0838F8B';
	DECLARE @InTimeP INT;
    DECLARE @IsReturnP BIT;

	---- Convertir cadena de guias en tabla de guias ---------------------------------------------
	CREATE TABLE #listGuides
	(
		Guide_Serie NVARCHAR(2),
		Guide_Number INT
	);
	
	CREATE NONCLUSTERED INDEX tempSerie ON #listGuides (Guide_Serie);
	CREATE NONCLUSTERED INDEX tempGuide ON #listGuides (Guide_Number);

	INSERT INTO #listGuides
	(
		Guide_Serie,
		Guide_Number
	)
	SELECT SUBSTRING(Item, 1, 2) Guide_Serie, 
		   SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) Guide_Number
	FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuidesP, ',');
	----------------------------------------------------------------------------------------------------

	---- Obtener guias que no existen ------------------------------------
	SELECT lg.Guide_Serie,
			lg.Guide_Number,
			-1 StatusOrderId,
			'No existe' 'Description'
	INTO #listGuidesNotExist
	FROM #listGuides lg
	WHERE NOT EXISTS (SELECT 1 
					  FROM DeliveryBackOffice.dbo.DeliveryOrder do 
					  WHERE lg.Guide_Serie = do.Guide_Serie 
					  AND lg.Guide_Number = do.Guide_Number);
	
	CREATE NONCLUSTERED INDEX IX_LGNE_SERIE ON #listGuidesNotExist (Guide_Serie);
	CREATE NONCLUSTERED INDEX IX_LGNE_NUMBER ON #listGuidesNotExist (Guide_Number);
	-----------------------------------------------------------------------------------------------------------------

	SELECT * FROM #listGuidesNotExist

	---- Obtener guias que si se pueden procesar con el modulo indicado ------------------------------------
	SELECT lg.Guide_Serie,
			lg.Guide_Number
	INTO #listGuidesIncluded
	FROM #listGuides lg
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do
		ON lg.Guide_Serie = do.Guide_Serie
		AND lg.Guide_Number = do.Guide_Number
	INNER JOIN DeliveryBackOffice.dbo.StatusOrder so
		ON do.StatusOrderId = so.StatusOrderId
	WHERE (UPPER(@ServiceType) = 'PICKUP'
			AND so.StatusOrderId IN (1, 4, 15, 16))
	OR (UPPER(@ServiceType) = 'DELIVERY'
		AND so.StatusOrderId IN (2, 3, 10, 11, 20, 21))
	OR (UPPER(@ServiceType) = 'RETURN'
		AND so.StatusOrderId IN (2, 3, 8, 10, 11, 12, 17, 18, 20, 21));
	
	/*SELECT lg.Guide_Serie,
			lg.Guide_Number
	INTO #listGuidesIncluded
	FROM #listGuides lg
	WHERE NOT EXISTS (SELECT 1
					  FROM #listGuidesNotExist lgne
					  WHERE lgne.Guide_Serie = lg.Guide_Serie
					  AND lgne.Guide_Number = lg.Guide_Number);*/
	
	CREATE NONCLUSTERED INDEX IX_LGI_SERIE ON #listGuidesIncluded (Guide_Serie);
	CREATE NONCLUSTERED INDEX IX_LGI_NUMBER ON #listGuidesIncluded (Guide_Number);
	-----------------------------------------------------------------------------------------------------------------

	
	---- Obtener guias que no se pueden procesar con el modulo indicado ------------------------------------
	SELECT lg.Guide_Serie,
			lg.Guide_Number,
			so.StatusOrderId,
			so.OrderDescription 'Description'
	INTO #listGuidesExcluded
	FROM #listGuides lg
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do
		ON lg.Guide_Serie = do.Guide_Serie
		AND lg.Guide_Number = do.Guide_Number
	INNER JOIN DeliveryBackOffice.dbo.StatusOrder so
		ON do.StatusOrderId = so.StatusOrderId
	WHERE (UPPER(@ServiceType) = 'PICKUP'
			AND so.StatusOrderId NOT IN (1, 4, 15, 16))
	OR (UPPER(@ServiceType) = 'DELIVERY'
		AND so.StatusOrderId NOT IN (2, 3, 10, 11, 20,21))
	OR (UPPER(@ServiceType) = 'RETURN'
		AND so.StatusOrderId NOT IN (2, 3, 8, 10, 11, 12, 17, 18, 20, 21));
	
	CREATE NONCLUSTERED INDEX IX_LGE_SERIE ON #listGuidesExcluded (Guide_Serie);
	CREATE NONCLUSTERED INDEX IX_LGE_NUMBER ON #listGuidesExcluded (Guide_Number);
	-----------------------------------------------------------------------------------------------------------------
	

	SELECT * FROM #listGuidesExcluded
	---- Asignar configuracion de parametros -------------------------------------------------------------
	IF UPPER(@ServiceType) = 'PICKUP'
	BEGIN
		SET @InTimeP = 2;
		SET @IsReturnP = 'FALSE';
	END
	ELSE IF UPPER(@ServiceType) = 'DELIVERY'
	BEGIN
		SET @InTimeP = 3;
		SET @IsReturnP = 'FALSE';
	END
	ELSE IF UPPER(@ServiceType) = 'RETURN'
	BEGIN
		SET @InTimeP = 3;
		SET @IsReturnP = 'TRUE';
	END
	--------------------------------------------------------------------------------------------------------
		
	---- Revalorizar guias que no tengan un precio asociado ---------------------------------------------
	SELECT ROW_NUMBER() OVER (ORDER BY ord.Guide_Number ASC) AS fila,
			ord.Guide_Serie,
			ord.Guide_Number
	INTO #RevalueGuides
	FROM #listGuidesIncluded lst
	JOIN DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
		ON ord.Guide_Number = lst.Guide_Number
		AND ord.Guide_Serie = lst.Guide_Serie
	WHERE ISNULL(ord.PriceShippment,0) = 0;

	CREATE NONCLUSTERED INDEX tempFila ON #RevalueGuides (fila);

	DECLARE @count INT = 1;
	DECLARE @RevalueSerie VARCHAR(10);
	DECLARE @RevalueGuide INT;
	DECLARE @IdMax INT = (SELECT MAX(fila) FROM #RevalueGuides);
	DECLARE @RC INT;

	WHILE @count <= @IdMax
	BEGIN

		PRINT '************************revalue**********************';
		PRINT CONVERT(VARCHAR(100), GETDATE(), 9);
		PRINT @RevalueSerie;
		PRINT @RevalueGuide;
		PRINT @count;

		SELECT @RevalueSerie = rv.Guide_Serie,
				@RevalueGuide = rv.Guide_Number
		FROM #RevalueGuides rv
		WHERE rv.fila = @count;

		EXECUTE @RC = DeliveryBackOffice.dbo.spws_revalue_guide @GuideSerie = @RevalueSerie,
																@GuideNumber = @RevalueGuide,
																@CodeApp = '',
																@Format = 'Non',
																@CalculateTaxes = 'true',
																@IdModule = @IdModuleP,
																@SetUpdate = 'true',
																@Token = @TokenP,
																@IsReturn = 'false';
		
		SET @count = @count + 1;
	END
	-----------------------------------------------------------------------------------------------------

	SET @InGuidesP = '';
	SELECT @InGuidesP = (SELECT STUFF((SELECT ',' + CONCAT(lgi.Guide_Serie, lgi.Guide_Number) 
										FROM #listGuidesIncluded lgi
										FOR XML PATH ('')), 1, 1, ''));

PRINT @InGuidesP
	
	CREATE TABLE #PendingPaymentTemp (
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
										CurrencyPrice_CODCodeISO NVARCHAR(8),
										CurrencyPrice_CODSymbol  NVARCHAR(8),
										CurrencyPriceCodeISO     NVARCHAR(8),
										CurrencyPriceSymbol      NVARCHAR(8),
										AmountToPay DECIMAL(14, 2) NULL,
										CODAmount DECIMAL(14, 2) NULL,
										ReturnRates DECIMAL(14, 2) NULL
									 );

	CREATE NONCLUSTERED INDEX IX_PPT_GS ON #PendingPaymentTemp (GuideSerie);
	CREATE NONCLUSTERED INDEX IX_PPT_GN ON #PendingPaymentTemp (GuideNumber);
		
	PRINT '@InTime'
	PRINT @InTimeP

	INSERT INTO #PendingPaymentTemp (GuideSerie, GuideNumber, IsCollect, Price, COD, 
										AmountPaid, CODPaid, CODIsPaid, PaymentTime, TimeSequence,
										FelNumber, IsPaid, IsCustomer, ConditionPayment, HaveCredit,
										CollectCOD, ReturnRate, AmountToPay, CODAmount, ReturnRates)
	
	EXEC  DeliveryBackOffice.dbo.spws_get_guide_pending_payment @InGuides = @InGuidesP, 
																@InTime = @InTimeP,
																@IsReturn = @IsReturnP,
																@CodeApp = '',
																@IdModule = @IdModuleP,
																@Token = @TokenP;

	SELECT * FROM #PendingPaymentTemp
	
	SELECT ROW_NUMBER() OVER (ORDER BY ppt.GuideNumber ASC) AS Id,
			CONCAT(ppt.GuideSerie, CAST(ppt.GuideNumber AS VARCHAR)) Guide,
			ppt.GuideSerie, 
			ppt.GuideNumber, 
			ppt.IsCollect, 
			ppt.Price, 
			ppt.COD, 
			ppt.AmountPaid, 
			ppt.CODPaid, 
			ppt.CODIsPaid, 
			ppt.PaymentTime, 
			ppt.TimeSequence, 
			ppt.FelNumber, 
			ppt.IsPaid, 
			ppt.IsCustomer, 
			ppt.ConditionPayment, 
			ppt.HaveCredit, 
			ppt.CollectCOD, 
			ppt.ReturnRate, 
			ppt.AmountToPay, 
			ppt.CODAmount, 
			ppt.ReturnRates,
			(ISNULL(ppt.AmountToPay, 0) + ISNULL(ppt.CODAmount, 0)) AmountToCollect,
			DeliveryBackOffice.dbo.fn_replace_special_characters(CONCAT(do.Sender_Department, ', ', do.Sender_Town, ', ', 'Zona ', do.Sender_Zone, ', ', do.Sender_Address)) SenderAddress,
			DeliveryBackOffice.dbo.fn_replace_special_characters(CONCAT(do.Receiver_Department, ', ', do.Receiver_Town, ', ', 'Zona ', do.Receiver_Zone, ', ', do.Receiver_Address)) ReceiverAddress,
			DeliveryBackOffice.dbo.fn_replace_special_characters(IIF(LTRIM(RTRIM(ISNULL(do.Sender_FirstName, ''))) = '', LTRIM(RTRIM(ISNULL(do.Sender_LastName, ''))), IIF(LTRIM(RTRIM(ISNULL(do.Sender_LastName, ''))) = '', LTRIM(RTRIM(do.Sender_FirstName)), CONCAT(LTRIM(RTRIM(do.Sender_FirstName)), ' ', LTRIM(RTRIM(do.Sender_LastName)))))) SenderName,
			DeliveryBackOffice.dbo.fn_replace_special_characters(CONCAT(IIF(LTRIM(RTRIM(ISNULL(do.Receiver_FirstName, ''))) = '', LTRIM(RTRIM(ISNULL(do.Receiver_LastName, ''))), IIF(LTRIM(RTRIM(ISNULL(do.Receiver_LastName, ''))) = '', LTRIM(RTRIM(do.Receiver_FirstName)), CONCAT(LTRIM(RTRIM(do.Receiver_FirstName)), ' ', LTRIM(RTRIM(do.Receiver_LastName))))), IIF(LTRIM(RTRIM(ISNULL(do.Receiver_Alternant_FullName, ''))) = '', '', CONCAT(' / ', LTRIM(RTRIM(do.Sender_FirstName)))))) ReceiverName,
			DeliveryBackOffice.dbo.fn_replace_special_characters(IIF(@ServiceType = 'DELIVERY', LTRIM(RTRIM(ISNULL(do.IndicationsToSendDestination, ''))), LTRIM(RTRIM(ISNULL(do.IndicationsToSendOrigin, ''))))) Indications,
			(ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0)) Pieces,
			IIF(do.TypeService = 'EXP', 'NDD', ISNULL(do.TypeService, 'NDD')) ServiceType
	INTO #PendingPaymentTempId
	FROM #PendingPaymentTemp ppt
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do
		ON ppt.GuideSerie = do.Guide_Serie
		AND ppt.GuideNumber = do.Guide_Number;

	CREATE NONCLUSTERED INDEX IX_PPTID_ID ON #PendingPaymentTempId ([Id]);

	DECLARE @Output VARCHAR(MAX);
	DECLARE @RowsNumber INT = (SELECT COUNT(1) FROM #PendingPaymentTempId);
	--Select *from #PendingPaymentTempId
	DECLARE @Index INT = 1;
	
	SET @Output = 
			'[ { ' + 
			'"Total": ' + (SELECT CAST(CAST(ISNULL(SUM(ppt.AmountToPay), 0) AS DECIMAL(18, 2)) AS VARCHAR)
							FROM #PendingPaymentTempId ppt) + ', ' + 
			'"Guides": [ ';

	WHILE @Index <= @RowsNumber
	BEGIN
		PRINT('EPRUEBA1')
		DECLARE @ActualGuide VARCHAR(50);
		DECLARE @Amount DECIMAL(18, 2);

		SELECT @ActualGuide = CONCAT(GuideSerie,  GuideNumber),
				@Amount = AmountToPay
		FROM #PendingPaymentTempId
		WHERE Id = @Index;

		SET @Output = @Output + (SELECT ' { "Guide": "' + pg.Guide + '", ' + 
										--'"GuideSerie": "' + pg.GuideSerie + '", ' + 
										--'"GuideNumber": "' + CAST(pg.GuideNumber AS VARCHAR) + '", ' + 
										'"SenderName": "' + pg.SenderName + '", ' + 
										'"SenderAddress": "' + pg.SenderAddress + '", ' + 
										'"ReceiverName": "' + pg.ReceiverName + '", ' + 
										'"ReceiverAddress": "' + pg.ReceiverAddress + '", ' + 
										'"Indications": "' + pg.Indications + '", ' + 
										'"CurrencySymbol": "Q.",' + 
										'"AmountToCollect": ' + CAST(CAST(pg.AmountToCollect AS DECIMAL(18, 2)) AS VARCHAR) + ', ' + 
										'"ServicePrice": ' + CAST(CAST(ISNULL(pg.AmountToPay, 0) AS DECIMAL(18, 2)) AS VARCHAR) + ', ' + 
										'"CODAmount": ' + CAST(CAST(ISNULL(pg.CODAmount, 0) AS DECIMAL(18, 2)) AS VARCHAR) + ', ' + 
										'"IsCollect": ' + CAST(ISNULL(pg.IsCollect, 0) AS VARCHAR) + ', ' + 
										'"Pieces": ' + CAST(ISNULL(pg.Pieces, 0) AS VARCHAR) + ', ' + 
										'"ServiceType": "' + pg.ServiceType + '", ' + 
										'"GuideDetail": [ '
									FROM #PendingPaymentTempId pg
									WHERE Id = @Index);

		DECLARE @Detail VARCHAR(MAX);
		SET @Detail = 
			(SELECT STUFF(
			(
				SELECT ' { "Description": "' + ISNULL(br.Description, '') + '", ' + 
						'"Amount": ' + CAST(CAST(ISNULL(br.Amount, 0) AS DECIMAL(18, 2)) AS VARCHAR) + ' }, '
				FROM Cost c 
				INNER JOIN BreakdownOfPayment br 
					ON c.IdCost = br.IdCost 
				WHERE c.ProductNumber = @ActualGuide
				AND ABS(br.Amount) > 0
				FOR XML PATH ('')
			), 1, 1, ''));
		
		IF @Detail IS NOT NULL
		BEGIN
			SET @Detail = SUBSTRING(@Detail, 1, (len(@Detail) - 1));
		END
		
		SET @Output = @Output + IIF(@Amount > 0, ISNULL(@Detail, ''), '') + ' ] }, ';
		SET @Index = @Index + 1;
	END

	IF (@RowsNumber > 0)
	BEGIN
		SET @Output = SUBSTRING(@Output, 1, (len(@Output) - 1));
	END
	
	SET @Output = @Output + '], ';
	SET @Output = @Output + 
				'"Rejects": [ ';
				
	IF ((SELECT COUNT(1) FROM #listGuidesExcluded) > 0)
	BEGIN
		SET @Output = @Output + 
				(SELECT STUFF((SELECT ' { "Guide": "' + CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR)) + '", ' + 
											--'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
											--'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
											'"StatusOrderId": ' + CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', ' + 
											'"Description": "' + lge.Description + '" }, '
									 FROM #listGuidesExcluded lge
									 FOR XML PATH ('')), 1, 1, ''));
	END

	IF ((SELECT COUNT(1) FROM #listGuidesNotExist) > 0)
	BEGIN
		SET @Output = @Output + 
				(SELECT STUFF((SELECT ' { "Guide": "' + CONCAT(lgne.Guide_Serie, CAST(lgne.Guide_Number AS VARCHAR)) + '", ' + 
											--'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
											--'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
											'"StatusOrderId": ' + CAST(ISNULL(lgne.StatusOrderId, 0) AS VARCHAR) + ', ' + 
											'"Description": "' + lgne.Description + '" }, '
									 FROM #listGuidesNotExist lgne
									 FOR XML PATH ('')), 1, 1, ''));
	END

	IF (((SELECT COUNT(1) FROM #listGuidesExcluded) > 0) OR ((SELECT COUNT(1) FROM #listGuidesNotExist) > 0))
	BEGIN
		SET @Output = SUBSTRING(@Output, 1, (len(@Output) - 1));
	END

	SET @Output = @Output + ' ] } ]';
	
	SELECT @Output FormatJson;
END