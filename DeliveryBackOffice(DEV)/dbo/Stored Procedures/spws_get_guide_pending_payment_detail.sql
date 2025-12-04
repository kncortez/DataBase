-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-05-21>
-- Description:	<Devuleve el monto a cobrar >
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Create date: <2023-03-21>
-- Description:	<Agregar guìas con estado terminal a tabla temporal de guìas excluidas, asì evitar que realicen algun proceso en recolecciòn, entrega o devoluciòn>
-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-07-02>
-- Description: <Se agrega filtro para el remitente por pais>
-- =============================================
-- =============================================
-- Author:      <Walter Orozco>
-- Create date: <2024-12-02>
-- Description: <Se agrega parametros para enviar información de COD anticipado.>
-- =============================================
-- =============================================
-- Author:      <Cristian Suazo>
-- Create date: <2025-01-07>
-- Description: <Se agrega procedimiento por ticketnumber>
-- =============================================
-- =============================================
-- Author:      <Tito García>
-- Create date: <2024-12-18>
-- Description: <Se realizan optimizaciones recomendadas por DBA>
-- =============================================
-- =============================================
-- Author:      <Bilkar Morataya>
-- Create date: <2025-09-02>
-- Description: <Se incluyen las Guías pagas por Zigi dentro del objeto Rejects>
-- =============================================
-- =============================================
-- Author:      <Bilkar Morataya>
-- Create date: <2025-12-04>
-- Description: <Se incluye el campo isNeedBilling>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_guide_pending_payment_detail]
    @InGuidesP VARCHAR(MAX),
    @IdModuleP INT,
    @ServiceType VARCHAR(100),
    @TokenP VARCHAR(100),
    @IdCountry VARCHAR(2) = 'GT',
	@TicketNumber NVARCHAR(MAX) = NULL
AS
BEGIN
    -- Insert statements for procedure here
    IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
        DROP TABLE #listGuides;
    IF OBJECT_ID('tempdb.dbo.#listGuidesNotExist', 'U') IS NOT NULL
        DROP TABLE #listGuidesNotExist;
    IF OBJECT_ID('tempdb.dbo.#listGuidesExcluded', 'U') IS NOT NULL
        DROP TABLE #listGuidesExcluded;
    IF OBJECT_ID('tempdb.dbo.#listGuidesIncluded', 'U') IS NOT NULL
        DROP TABLE #listGuidesIncluded;
    IF OBJECT_ID('tempdb.dbo.#RevalueGuides', 'U') IS NOT NULL
        DROP TABLE #RevalueGuides;
    IF OBJECT_ID('tempdb.dbo.#PendingPaymentTemp', 'U') IS NOT NULL
        DROP TABLE #PendingPaymentTemp;
    IF OBJECT_ID('tempdb.dbo.#PendingPaymentTempId', 'U') IS NOT NULL
        DROP TABLE #PendingPaymentTempId;

    --DECLARE @InGuidesP VARCHAR(MAX) = 'FD509086,FD509087,FD509088';
    --DECLARE @IdModuleP INT = 35;
    --DECLARE @ServiceType VARCHAR(100) = 'PICKUP';
    --DECLARE @TokenP VARCHAR(100) = '3E9C2157FD6D5863CFBA2366C0838F8B';
    DECLARE @InTimeP INT;
    DECLARE @IsReturnP BIT;

	DECLARE  @CODAnticipatedTable TABLE(
		GuideSerie NVARCHAR(2),
        GuideNumber INT,
		IdCustomer INT,
		IdPortafolio INT,
		COD DECIMAL(18,2),
		ComisionCOD DECIMAL(18,2),
		ComisionCODAnticipated DECIMAL(18,2)
	) 

    ---- Convertir cadena de guias en tabla de guias ---------------------------------------------
    CREATE TABLE #listGuides
    (
        Guide_Serie NVARCHAR(2),
        Guide_Number INT
    );
    CREATE NONCLUSTERED INDEX tempGuides ON #listGuides (Guide_Serie, Guide_Number);


	IF @InGuidesP IS NOT NULL AND @InGuidesP != ''
	BEGIN
	PRINT ' NORMAL '
		INSERT INTO #listGuides
		(
			Guide_Serie,
			Guide_Number
		)
		SELECT SUBSTRING(Item, 1, 2) Guide_Serie,
			   SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) Guide_Number
		FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuidesP, ',');
	END
	ELSE
	BEGIN

		SET @InGuidesP = ''
		SELECT @InGuidesP = STRING_AGG(CAST(CONCAT(Guide_Serie, Guide_Number) AS VARCHAR(MAX)), ',')
		FROM DeliveryOrder WITH (NOLOCK)
		WHERE Ticket_Number IN ( @TicketNumber )

		INSERT INTO #listGuides
		(
			Guide_Serie,
			Guide_Number
		)
		SELECT SUBSTRING(Item, 1, 2) Guide_Serie,
			   SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) Guide_Number
		FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuidesP, ',');

	END
	----------------------------------------------------------------------------------------------------

    ---- Obtener guias que no existen ------------------------------------
    SELECT lg.Guide_Serie,
           lg.Guide_Number,
           -1 StatusOrderId,
           'No existe' 'Description'
    INTO #listGuidesNotExist
    FROM #listGuides lg
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
        WHERE lg.Guide_Serie = do.Guide_Serie
              AND lg.Guide_Number = do.Guide_Number
          AND ISNULL(do.SenderCountryId,'GT') = @IdCountry
    );

    CREATE NONCLUSTERED INDEX IX_LGNE_NGUIDES ON #listGuidesNotExist (Guide_Serie, Guide_Number);
    -----------------------------------------------------------------------------------------------------------------


    ---- Crear tabla temporal para guías excluidas si no existe ----
    CREATE TABLE #listGuidesExcluded (
        Guide_Serie NVARCHAR(2),
        Guide_Number INT,
        StatusOrderId INT,
        Description NVARCHAR(255)
    );

    -- 1. Crear tabla temporal de guías pagadas en Zigi
    IF OBJECT_ID('tempdb.dbo.#listGuidesPaidZigi', 'U') IS NOT NULL
        DROP TABLE #listGuidesPaidZigi;
    SELECT lg.Guide_Serie, lg.Guide_Number
    INTO #listGuidesPaidZigi
    FROM #listGuides lg
    INNER JOIN PaymentZigi pz WITH(NOLOCK)
        ON lg.Guide_Serie = pz.GuideSerie AND lg.Guide_Number = pz.GuideNumber
    WHERE pz.ZigiLinkStatus = 'PAID';

    -- 2. Agregar guías pagadas a los excluidos (Rejects)
    -- INSERT INTO #listGuidesExcluded (Guide_Serie, Guide_Number, StatusOrderId, Description)
    -- SELECT Guide_Serie, Guide_Number, 999, 'Guía pagada en Zigi'
    -- FROM #listGuidesPaidZigi;



    -- 3. Poblar #listGuidesIncluded se mueve después de poblar completamente #listGuidesExcluded
    -- -----------------------------------------------------------------------------------------------------------------


    -- Insertar guias que no se pueden procesar con el modulo indicado en #listGuidesExcluded
    INSERT INTO #listGuidesExcluded (Guide_Serie, Guide_Number, StatusOrderId, Description)
    SELECT lg.Guide_Serie,
           lg.Guide_Number,
           so.StatusOrderId,
           so.OrderDescription 'Description'
    FROM #listGuides lg
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
            ON lg.Guide_Serie = do.Guide_Serie
               AND lg.Guide_Number = do.Guide_Number
        INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH(NOLOCK)
            ON do.StatusOrderId = so.StatusOrderId
    WHERE (
              UPPER(@ServiceType) = 'PICKUP'
              AND (so.StatusOrderId NOT IN ( 1, 15, 50, 45 ))
          )
          OR
          (
              UPPER(@ServiceType) = 'DELIVERY'
              AND (so.StatusOrderId NOT IN ( 10, 11, 12, 20, 21, 50, 45, 48, 51 ))
          )
          OR
          (
              UPPER(@ServiceType) = 'RETURN'
              AND so.StatusOrderId NOT IN ( 10, 11, 12, 20, 50, 45, 17, 32, 31, 34, 35 )
          )
      AND ISNULL(do.SenderCountryId,'GT') = @IdCountry;

    -- Insertar guias en estado terminal en #listGuidesExcluded
    INSERT INTO #listGuidesExcluded (Guide_Serie, Guide_Number, StatusOrderId, Description)
    SELECT lg.Guide_Serie,
           lg.Guide_Number,
           so.StatusOrderId,
           so.OrderDescription 'Description'
    FROM #listGuides lg
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
            ON lg.Guide_Serie = do.Guide_Serie
               AND lg.Guide_Number = do.Guide_Number
        INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH(NOLOCK)
            ON do.StatusOrderId = so.StatusOrderId
    WHERE (
            (so.StatusOrderId  IN ( SELECT SO.[StatusOrderId]
                                    FROM [dbo].[StatusOrder] SO  WITH(NOLOCK)
                                    WHERE [CatCheckpointTypeId] = 3 
                                        AND RowStatus = 1 ))
        )
      AND ISNULL(do.SenderCountryId,'GT') = @IdCountry

------------------------------------  Validación de estados terminales --------------------------------------------------
 
--------------------------------------------------------------------------------------------------------------------------

		  IF ((SELECT COUNT(1)FROM #listGuidesExcluded) = 0)
			BEGIN
						
			INSERT INTO #listGuidesExcluded(Guide_Serie,Guide_Number,StatusOrderId,Description)			
				SELECT lg.Guide_Serie,
           lg.Guide_Number,
           so.StatusOrderId,
                            so.OrderDescription 'Description'
    FROM #listGuides lg
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
            ON lg.Guide_Serie = do.Guide_Serie
               AND lg.Guide_Number = do.Guide_Number
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
		ON DOD.Guide_Serie = do.Guide_Serie 
        AND DOD.Guide_Number = do.Guide_Number
        INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
            ON DOD.StatusOrderId = so.StatusOrderId
    WHERE           
          (
              UPPER(@ServiceType) = 'DELIVERY'
              AND DO.IsLastMileReturn = 1
			  AND DOD.StatusOrderId IN ( 32 )						
          )
      AND ISNULL(do.SenderCountryId,'GT') = @IdCountry
         
			END

    CREATE NONCLUSTERED INDEX IX_LGE_GUIDES ON #listGuidesExcluded (Guide_Serie, Guide_Number);

    -- Ahora sí, poblar #listGuidesIncluded después de poblar completamente #listGuidesExcluded
    SELECT lg.Guide_Serie,
           lg.Guide_Number
    INTO #listGuidesIncluded
    FROM #listGuides lg
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
            ON lg.Guide_Serie = do.Guide_Serie
               AND lg.Guide_Number = do.Guide_Number
        INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH(NOLOCK)
            ON do.StatusOrderId = so.StatusOrderId
    WHERE (
            (UPPER(@ServiceType) = 'PICKUP' AND so.StatusOrderId IN (1, 15, 50, 45))
         OR (UPPER(@ServiceType) = 'DELIVERY' AND so.StatusOrderId IN (10, 11, 12, 20, 21, 50, 45, 48, 51) AND COALESCE(DO.IsLastMileReturn,0) = 0)
         OR (UPPER(@ServiceType) = 'RETURN' AND so.StatusOrderId IN (10, 11, 12, 20, 50, 45, 17, 32, 31, 34, 35))
    )
    AND ISNULL(do.SenderCountryId,'GT') = @IdCountry
    -- AND NOT EXISTS (
          -- SELECT 1 FROM #listGuidesPaidZigi paid
          -- WHERE paid.Guide_Serie = lg.Guide_Serie AND paid.Guide_Number = lg.Guide_Number
    -- )
    AND NOT EXISTS (
          SELECT 1 FROM #listGuidesExcluded ex
          WHERE ex.Guide_Serie = lg.Guide_Serie AND ex.Guide_Number = lg.Guide_Number
    );
    CREATE NONCLUSTERED INDEX IX_LGI_GUIDES ON #listGuidesIncluded (Guide_Serie, Guide_Number);
    -----------------------------------------------------------------------------------------------------------------

    ---- Asignar configuracion de parametros -------------------------------------------------------------
    IF UPPER(@ServiceType) = 'PICKUP'
    BEGIN
        SET @InTimeP = 2;
        SET @IsReturnP = 'FALSE';
    END;
    ELSE IF UPPER(@ServiceType) = 'DELIVERY'
    BEGIN
        SET @InTimeP = 3;
        SET @IsReturnP = 'FALSE';
    END;
    ELSE IF UPPER(@ServiceType) = 'RETURN'
    BEGIN
        SET @InTimeP = 3;
        SET @IsReturnP = 'TRUE';
    END;
    --------------------------------------------------------------------------------------------------------

    ---- Revalorizar guias que no tengan un precio asociado ---------------------------------------------
    SELECT ROW_NUMBER() OVER (ORDER BY ord.Guide_Number ASC) AS fila,
           ord.Guide_Serie,
           ord.Guide_Number
    INTO #RevalueGuides
    FROM #listGuidesIncluded lst
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
            ON ord.Guide_Number = lst.Guide_Number
               AND ord.Guide_Serie = lst.Guide_Serie
		LEFT JOIN [DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH(NOLOCK)
			ON lst.Guide_Serie = PC.GuideSerieDestination
				AND lst.Guide_Number = PC.GuideNumberDestination
    WHERE ISNULL(ord.PriceShippment, 0) = 0
		AND PC.IdPromoCoupon IS NULL
		AND PC.FinalActiveDate >= GETDATE()
		AND PC.RowStatus = 1
        AND ISNULL(ord.SenderCountryId,'GT') = @IdCountry ;

    CREATE NONCLUSTERED INDEX tempFila ON #RevalueGuides (fila);

    DECLARE @count INT = 1;
    DECLARE @RevalueSerie VARCHAR(10);
    DECLARE @RevalueGuide INT;
    DECLARE @IdMax INT =
            (
                SELECT MAX(fila)FROM #RevalueGuides
            );
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

		----Obtener bandera de tipo de suscripcion para enviar a sp revalorizador----
		DECLARE @TypeSubsId INT;
		SET @TypeSubsId = (SELECT TOP 1 sb.CatTypeSubscriptionId 
        FROM MembershipSubscriptionLog sbl WITH (NOLOCK)
		INNER JOIN Subscription sb WITH (NOLOCK)
		ON sbl.SubscriptionId = sb.IdSubscription
		WHERE sbl.LogGuideNumber = @RevalueGuide AND sbl.LogGuideSerie = @RevalueSerie )

		IF(@TypeSubsId IS NULL)
			BEGIN
			SET @TypeSubsId = 0
			END
		-----Fin--------------------------------
        --EXECUTE @RC = DeliveryBackOffice.dbo.spws_revalue_guide @GuideSerie = @RevalueSerie,
        --                                                        @GuideNumber = @RevalueGuide,
        --                                                        @CodeApp = '',
        --                                                        @Format = 'Non',
        --                                                        @CalculateTaxes = 'true',
        --                                                        @IdModule = @IdModuleP,
        --                                                        @SetUpdate = 'true',
        --                                                        @Token = @TokenP,
        --                                                        @IsReturn = 'false',
								--								@TypeSubscriptionId =@TypeSubsId;

        SET @count = @count + 1;
    END;
    -----------------------------------------------------------------------------------------------------

    SET @InGuidesP = '';
    SELECT @InGuidesP =
    (
        SELECT STUFF(
               (
                   SELECT ',' + CONCAT(lgi.Guide_Serie, lgi.Guide_Number)
                   FROM #listGuidesIncluded lgi
                   FOR XML PATH('')
               ),
               1,
               1,
               ''
                    )
    );

    CREATE TABLE #PendingPaymentTemp
    (
        GuideSerie NVARCHAR(25) NULL,
        GuideNumber INT,
        IsCollect BIT,
        Price DECIMAL(18, 2) NULL,
        COD DECIMAL(18, 2) NULL,
        AmountPaid DECIMAL(18, 2) NULL,
        CODPaid DECIMAL(18, 2) NULL,
        CODIsPaid BIT,
        PaymentTime INT NULL,
        TimeSequence INT NULL,
        FelNumber NVARCHAR(50) NULL,
        IsPaid BIT,
        IsCustomer INT NULL,
        ConditionPayment VARCHAR(200),
        HaveCredit BIT,
        CollectCOD BIT,
        ReturnRate DECIMAL(18, 2) NULL,
        CurrencyPrice_CODCodeISO NVARCHAR(8),
		CurrencyPrice_CODSymbol  NVARCHAR(8),
		CurrencyPriceCodeISO     NVARCHAR(8),
		CurrencyPriceSymbol      NVARCHAR(8),
        AmountToPay DECIMAL(18, 2) NULL,
        CODAmount DECIMAL(18, 2) NULL,
        ReturnRates DECIMAL(18, 2) NULL
    );

    CREATE NONCLUSTERED INDEX IX_PPT_GNS ON #PendingPaymentTemp (GuideSerie,GuideNumber);

    PRINT '@InTime';
    PRINT @InTimeP;

    INSERT INTO #PendingPaymentTemp
    (
        GuideSerie,
        GuideNumber,
        IsCollect,
        Price,
        COD,
        AmountPaid,
        CODPaid,
        CODIsPaid,
        PaymentTime,
        TimeSequence,
        FelNumber,
        IsPaid,
        IsCustomer,
        ConditionPayment,
        HaveCredit,
        CollectCOD,
        ReturnRate,
        CurrencyPrice_CODCodeISO,
		CurrencyPrice_CODSymbol,
		CurrencyPriceCodeISO,
		CurrencyPriceSymbol,
        AmountToPay,
        CODAmount,
        ReturnRates
    )
    EXEC DeliveryBackOffice.dbo.spws_get_guide_pending_payment @InGuides = @InGuidesP,
                                                               @InTime = @InTimeP,
                                                               @IsReturn = @IsReturnP,
                                                               @CodeApp = '',
                                                               @IdModule = @IdModuleP,
                                                               @Token = @TokenP;





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
           DeliveryBackOffice.dbo.fn_replace_special_characters(CONCAT(
                                                                          do.Sender_Department,
                                                                          ', ',
                                                                          do.Sender_Town,
                                                                          ', ',
                                                                          'Zona ',
                                                                          do.Sender_Zone,
                                                                          ', ',
                                                                          do.Sender_Address
                                                                      )
                                                               ) SenderAddress,
           DeliveryBackOffice.dbo.fn_replace_special_characters(CONCAT(
                                                                          do.Receiver_Department,
                                                                          ', ',
                                                                          do.Receiver_Town,
                                                                          ', ',
                                                                          'Zona ',
                                                                          do.Receiver_Zone,
                                                                          ', ',
                                                                          do.Receiver_Address
                                                                      )
                                                               ) ReceiverAddress,
           DeliveryBackOffice.dbo.fn_replace_special_characters(IIF(LTRIM(RTRIM(ISNULL(do.Sender_FirstName, ''))) = '',
                                                                    LTRIM(RTRIM(ISNULL(do.Sender_LastName, ''))),
                                                                    IIF(
                                                                        LTRIM(RTRIM(ISNULL(do.Sender_LastName, ''))) = '',
                                                                        LTRIM(RTRIM(do.Sender_FirstName)),
                                                                        CONCAT(
                                                                                  LTRIM(RTRIM(do.Sender_FirstName)),
                                                                                  ' ',
                                                                                  LTRIM(RTRIM(do.Sender_LastName))
                                                                              )))
                                                               ) SenderName,
           DeliveryBackOffice.dbo.fn_replace_special_characters(CONCAT(
                                                                          IIF(
                                                                              LTRIM(RTRIM(ISNULL(
                                                                                                    do.Receiver_FirstName,
                                                                                                    ''
                                                                                                )
                                                                                         )
                                                                                   ) = '',
                                                                              LTRIM(RTRIM(ISNULL(
                                                                                                    do.Receiver_LastName,
                                                                                                    ''
                                                                                                )
                                                                                         )
                                                                                   ),
                                                                              IIF(
                                                                                  LTRIM(RTRIM(ISNULL(
                                                                                                        do.Receiver_LastName,
                                                                                                        ''
                                                                                                    )
                                                                                             )
                                                                                       ) = '',
                                                                                  LTRIM(RTRIM(do.Receiver_FirstName)),
                                                                                  CONCAT(
                                                                                            LTRIM(RTRIM(do.Receiver_FirstName)),
                                                                                            ' ',
                                                                                            LTRIM(RTRIM(do.Receiver_LastName))
                                                                                        ))),
                                                                          IIF(
                                                                              LTRIM(RTRIM(ISNULL(
                                                                                                    do.Receiver_Alternant_FullName,
                                                                                                    ''
                                                                                                )
                                                                                         )
                                                                                   ) = '',
                                                                              '',
                                                                              CONCAT(
                                                                                        ' / ',
                                                                                        LTRIM(RTRIM(do.Sender_FirstName))
                                                                                    ))
                                                                      )
                                                               ) ReceiverName,
           DeliveryBackOffice.dbo.fn_replace_special_characters(IIF(@ServiceType = 'DELIVERY',
                                                                    LTRIM(RTRIM(ISNULL(
                                                                                          do.IndicationsToSendDestination,
                                                                                          ''
                                                                                      )
                                                                               )
                                                                         ),
                                                                    LTRIM(RTRIM(ISNULL(do.IndicationsToSendOrigin, ''))))
                                                               ) Indications,
           (ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0)) Pieces,
           IIF(do.TypeService = 'EXP', 'NDD', ISNULL(do.TypeService, 'NDD')) ServiceType,
           ppt.CurrencyPriceSymbol,
		     IIF(ISNULL(pyt.ShipmentCompleted, 0) = 0,
				'PENDIENTE',
				(ISNULL(
					CONVERT(
								VARCHAR,
								CASE
									WHEN pyt.TypeofInOutMoneyId = 1 THEN
										UPPER(cpt.PayTypeName)
									WHEN pyt.TypeofInOutMoneyId = 2 THEN
										UPPER(cpt.PayTypeName)
									WHEN pyt.TypeofInOutMoneyId = 8 THEN
										UPPER('credito')
									ELSE
										CASE
											WHEN ppt.IsCollect = 1 THEN
												'COLLECT'
											ELSE
												'CONTADO'
										END
								END
							),
					'N/A'
				)
				)) AS TypePayment,
	DO.IdCustomer,
    CAST(1 AS BIT) AS IsNeedBilling
    INTO #PendingPaymentTempId
    FROM #PendingPaymentTemp ppt
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
            ON ppt.GuideSerie = do.Guide_Serie
               AND ppt.GuideNumber = do.Guide_Number
        LEFT JOIN dbo.DeliveryOrderPaymentDetail pyt WITH (NOLOCK)
            ON pyt.GuideSerie = ppt.GuideSerie
               AND pyt.GuideNumber = ppt.GuideNumber
		LEFT JOIN [dbo].[CatPaymentType] cpt WITH(NOLOCK)
			ON (cpt.PayTypeId = pyt.PayTypeId)
   WHERE do.SenderCountryId = @IdCountry;

    CREATE NONCLUSTERED INDEX IX_PPTID_ID ON #PendingPaymentTempId ([Id]);

    ---------------------------------------------------------
    -- Actualización masiva de IsNeedBilling
    ---------------------------------------------------------
    UPDATE T
    SET IsNeedBilling = 0
    FROM #PendingPaymentTempId T
    INNER JOIN DeliveryBackOffice.dbo.invoiceDetail ID WITH (NOLOCK)
        ON T.GuideSerie = ID.dti_fk_orderSerie 
        AND T.GuideNumber = ID.dti_fk_orderNumber
    INNER JOIN DeliveryBackOffice.dbo.invoiceHeader IH WITH (NOLOCK)
        ON IH.inv_pk_id = ID.dti_fk_header
    WHERE IH.inv_certificationFEL IS NOT NULL
      AND LTRIM(RTRIM(IH.inv_certificationFEL)) <> ''
    ---------------------------------------------------------

	DECLARE @IdCountrySender NVARCHAR(2) = 
	(
		SELECT top 1 do.SenderCountryId FROM #PendingPaymentTemp ppt
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
            ON ppt.GuideSerie = do.Guide_Serie
               AND ppt.GuideNumber = do.Guide_Number
		WHERE Guide_Serie = ppt.GuideSerie AND Guide_Number = ppt.GuideNumber
	)

	DECLARE @CODRateDefault DECIMAL(18, 2) =
						(
							SELECT CONVERT(DECIMAL(18, 2), ISNULL(cf.Value, '0')) val
							FROM DeliveryBackOffice.dbo.ConfigParams cf WITH(NOLOCK)
							WHERE cf.Name = 'CODRateDef'
									AND Status = 1
									AND cf.IdCountry = @IdCountrySender
						);
	DECLARE @CODExemptDefault DECIMAL(18, 2) =
						(
							SELECT CONVERT(DECIMAL(18, 2), ISNULL(cf.Value, '0')) val
							FROM DeliveryBackOffice.dbo.ConfigParams cf WITH(NOLOCK)
							WHERE cf.Name = 'CODExemptDef'
									AND Status = 1
									AND cf.IdCountry = @IdCountrySender
						);
	DECLARE @IdSegmentDefault INT =
					(
						SELECT TOP 1
								CrsId
						FROM dbo.CatRateSegment WITH(NOLOCK)
						WHERE CrsShortName = 'FOR'
								AND CrsRowStatus = 'true'
					);

	DECLARE @MinCODCommissionAmount DECIMAL(18, 2) =
					(
						SELECT CONVERT(DECIMAL(18, 2), ISNULL(cf.Value, '0')) val
						FROM DeliveryBackOffice.dbo.ConfigParams cf WITH(NOLOCK)
						WHERE cf.Name = 'MinCODCommissionAmount'
								AND Status = 1
								AND ISNULL(cf.IdCountry,'GT') = @IdCountrySender
					);

	INSERT INTO @CODAnticipatedTable (GuideSerie, GuideNumber,IdCustomer,IdPortafolio,COD,ComisionCOD,ComisionCODAnticipated)
	SELECT
		ppt.GuideSerie,
        ppt.GuideNumber,
		ISNULL(ach.CustomerId,0),
		ISNULL(ach.PortfolioId,0),
		DO.Collect_OnDelivery,
		IIF((DO.Collect_OnDelivery - ISNULL(RCO.CODExempt, @CODExemptDefault)) > 0
		, IIF(OP.Deposit_Number IS NULL
			, IIF(ISNULL(VPC.ExcludeCommissionCOD, ISNULL(C.ExcludeCommissionCOD, 0)) = 1
				, 0
				, (CONVERT(
							DECIMAL(18, 2)
							, ((DO.Collect_OnDelivery)* ISNULL(RCO.CODRate, @CODRateDefault) / 100)
						)
				))
			, 0)
		, 0)											AS 'ComisionCOD'
	,
	CASE
		WHEN 
			(ACC.AnticipatedCODComission IS NOT NULL AND ACC.AnticipatedCODComission > 0.00)
			AND (ACC.InitialRange <= DO.Collect_OnDelivery AND DO.Collect_OnDelivery <= ACC.FinalRange)
		THEN
			ACC.AnticipatedCODComission
		ELSE
			CASE
				WHEN
					CPmin1.Value >= DO.Collect_OnDelivery AND DO.Collect_OnDelivery <= CPmax1.Value
				THEN
					CAST(CPv1.value AS DECIMAL)
				WHEN
					CPmin2.Value >= DO.Collect_OnDelivery AND DO.Collect_OnDelivery <= CPmax2.Value
				THEN
					CAST(CPv2.value AS DECIMAL)
				ELSE
					CAST(CPv3.value AS DECIMAL)
			END
	END													AS 'ComisionCODAnticipated'
	FROM #PendingPaymentTemp ppt
         INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
            ON ppt.GuideSerie = do.Guide_Serie
               AND ppt.GuideNumber = do.Guide_Number
		LEFT JOIN DeliveryBackOffice.dbo.AnticipatedCODDetail acd WITH(NOLOCK)
			ON do.Guide_Serie = acd.GuideSerie AND do.Guide_Number = acd.GuideNumber
		LEFT JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH(NOLOCK)
			ON do.IdCustomer = ach.CustomerId 
            AND ISNULL(do.VisitpointClientPortfolioId, 0) = ISNULL(ach.PortfolioId, 0)
            --Tomar en cuenta validar especificamente
            --por portafolio cuando el cliente sea redistribuidor 10/02/2025
		LEFT JOIN dbo.VisitPointClient            VPC WITH (NOLOCK)
			ON VPC.CodeOfReference = DO.Sender_ID
		LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)
			ON RBC.RbcIdCustomer = ISNULL(DO.IdCustomer, VPC.CustomerID)
				AND RBC.RbcRowStatus = 1 AND RBC.RbcCodeOfReference IS NULL
		LEFT JOIN dbo.RatebyCustomer RBC2 WITH (NOLOCK)
			ON RBC2.RbcIdCustomer = ISNULL(DO.IdCustomer, VPC.CustomerID)
				AND RBC2.RbcRowStatus = 1 AND RBC2.RbcCodeOfReference = DO.Sender_ID
		LEFT JOIN DeliveryBackOffice.dbo.RateHeader RH WITH(NOLOCK)
			ON RBC.RbcIdRate = RH.RheId
		LEFT JOIN DeliveryBackOffice.dbo.AnticipatedCODComission ACC WITH(NOLOCK)
			ON RH.RheId = ACC.RateHeaderId
		--COD inmediato
		LEFT JOIN dbo.Customer C WITH (NOLOCK)
			ON C.IdCustomer = ISNULL(DO.IdCustomer, VPC.CustomerID)
		LEFT JOIN dbo.CatTypeService CSV WITH (NOLOCK)
			ON CSV.CtsShortName = IIF(DO.TypeService = 'EXP', 'NDD', ISNULL(DO.TypeService, 'NDD'))
				AND CSV.CtsRowStatus = 'true'
		LEFT JOIN dbo.CatRateSegment CSG WITH (NOLOCK)
			ON CSG.CrsShortName = dbo.fn_get_segment(DO.Guide_Serie, DO.Guide_Number)
				AND CSG.CrsRowStatus = 'true'
		LEFT JOIN dbo.RateCOD RCO WITH (NOLOCK)
			ON RCO.RateId = ISNULL(RBC2.RbcIdRate, RBC.RbcIdRate)
				AND RCO.TypeServiceId = CSV.CtsId
				AND RCO.TypeSegmentId = ISNULL(CSG.CrsId, @IdSegmentDefault)
				AND RCO.RowStatus = 1
		LEFT JOIN dbo.DeliveryOrderPaid OP WITH (NOLOCK)
			ON OP.Guide_Serie = DO.Guide_Serie
				AND OP.Guide_Number = DO.Guide_Number
				AND OP.IdStatus = 'true'
		LEFT JOIN dbo.DeliveryOrderPaymentDetail PYT WITH (NOLOCK)
			ON PYT.GuideSerie = DO.Guide_Serie AND PYT.GuideNumber = DO.Guide_Number
		--Son rangos por default que tenemos si en dado caso el tarifario no cumple su rango
		LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmin1 WITH(NOLOCK)
			ON CPmin1.IdCountry = DO.ReceiverCountryId AND CPmin1.Name = 'MinRangeCODComisison1Param'
		LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmin2 WITH(NOLOCK)
			ON CPmin2.IdCountry = DO.ReceiverCountryId AND CPmin2.Name = 'MinRangeCODComisison2Param'
		LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmax1 WITH(NOLOCK)
			ON CPmax1.IdCountry = DO.ReceiverCountryId AND CPmax1.Name = 'MaxRangeCODComisison1Param'
		LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmax2 WITH(NOLOCK)
			ON CPmax2.IdCountry = DO.ReceiverCountryId AND CPmax2.Name = 'MaxRangeCODComisison2Param'
		LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv1 WITH(NOLOCK)
			ON CPv1.IdCountry = DO.ReceiverCountryId AND CPv1.Name = 'ValueCODComisison1Param'
		LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv2 WITH(NOLOCK)
			ON CPv2.IdCountry = DO.ReceiverCountryId AND CPv2.Name = 'ValueCODComisison2Param'
		LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv3 WITH(NOLOCK)
			ON CPv3.IdCountry = DO.ReceiverCountryId AND CPv3.Name = 'ValueCODComisison3Param'
	WHERE ISNULL(do.SenderCountryId,'GT') = @IdCountry AND ach.RowStatus = 1;

    DECLARE @Output VARCHAR(MAX);
    DECLARE @RowsNumber INT =
            (
                SELECT COUNT(1)FROM #PendingPaymentTempId
            );
    DECLARE @Index INT = 1;

    SET @Output = '[ { ' + '"Total": ' +
                  (
                      SELECT CAST(CAST(ISNULL(SUM(ppt.AmountToPay), 0) AS DECIMAL(18, 2)) AS VARCHAR)
                      FROM #PendingPaymentTempId ppt
                  ) + ', ' + '"Guides": [ ';

    WHILE @Index <= @RowsNumber
    BEGIN
        DECLARE @ActualGuide VARCHAR(50);
        DECLARE @Amount DECIMAL(18, 2);

        SELECT @ActualGuide = CONCAT(GuideSerie, GuideNumber),
               @Amount = AmountToPay
        FROM #PendingPaymentTempId
        WHERE Id = @Index;

        SET @Output
            = @Output
              +
              (
                  SELECT ' { "Guide": "' + pg.Guide + '", ' +
                      --'"GuideSerie": "' + pg.GuideSerie + '", ' + 
                      --'"GuideNumber": "' + CAST(pg.GuideNumber AS VARCHAR) + '", ' + 
                      '"SenderName": "' + pg.SenderName + '", ' + '"SenderAddress": "' + pg.SenderAddress + '", '
                         + '"ReceiverName": "' + pg.ReceiverName + '", ' + '"ReceiverAddress": "' + pg.ReceiverAddress
                         + '", ' + '"Indications": "' + pg.Indications + '", ' + '"CurrencySymbol": "' + CurrencyPriceSymbol  + '.",'
                         + '"AmountToCollect": ' + CAST(CAST(pg.AmountToCollect AS DECIMAL(18, 2)) AS VARCHAR) + ', '
                         + '"ServicePrice": ' + CAST(CAST(ISNULL(pg.AmountToPay, 0) AS DECIMAL(18, 2)) AS VARCHAR)
                         + ', ' + '"CODAmount": ' + CAST(CAST(ISNULL(pg.CODAmount, 0) AS DECIMAL(18, 2)) AS VARCHAR)
                         + ', ' + '"PriceShippment": ' + CAST(CAST(ISNULL(pg.Price, 0) AS DECIMAL(18, 2)) AS VARCHAR)
                         + ', ' + '"TypePayment": "' + pg.TypePayment +'"'
                         + ', ' + '"IsCollect": ' + CAST(ISNULL(pg.IsCollect, 0) AS VARCHAR) + ', ' + '"Pieces": '
                         + CAST(ISNULL(pg.Pieces, 0) AS VARCHAR) + ', ' + '"ServiceType": "' + pg.ServiceType + '", '
                         + '"isNeedBilling": ' + CAST(pg.IsNeedBilling AS VARCHAR) + ', '
						 + '"IdCustomer": ' + CAST(ISNULL(c.IdCustomer,0) AS VARCHAR) + ', '
						 + '"IdPortafolio": ' + CAST(ISNULL(c.IdPortafolio,0) AS VARCHAR) + ', '
						 + '"COD": ' + CAST(ISNULL(c.COD,0) AS VARCHAR) + ', '
						 + '"ComisionCOD": ' + 
						 CASE
							WHEN pg.ServiceType != 'COD' --Si la guía no es de tipo COD no deberia cobrar comision
							THEN '0'
							WHEN ISNULL(c.ComisionCOD, 0)	< ISNULL(@MinCODCommissionAmount, 0)	
							THEN ISNULL(CAST(@MinCODCommissionAmount AS VARCHAR) , '0')
							ELSE ISNULL(CAST(c.ComisionCOD AS VARCHAR) , '0')
						END
						 + ', '
						 + '"ComisionCODAnticipated": ' + CAST(ISNULL(c.ComisionCODAnticipated,0) AS VARCHAR) + ', '
                         + '"GuideDetail": [ '
                  FROM #PendingPaymentTempId pg
				  left JOIN @CODAnticipatedTable c
					ON pg.GuideSerie = c.GuideSerie AND pg.GuideNumber = c.GuideNumber
                  WHERE Id = @Index
              );

        DECLARE @Detail VARCHAR(MAX);
        SET @Detail =
        (
            SELECT STUFF(
                   (
                       SELECT ' { "Description": "' + ISNULL(br.Description, '') + '", ' + '"Amount": '
                              + CAST(CAST(ISNULL(br.Amount, 0) AS DECIMAL(18, 2)) AS VARCHAR) + ' }, '
                       FROM Cost c WITH (NOLOCK)
                           INNER JOIN BreakdownOfPayment br WITH (NOLOCK)
                               ON c.IdCost = br.IdCost
                       WHERE c.ProductNumber = @ActualGuide
                             AND ABS(br.Amount) > 0
                       FOR XML PATH('')
                   ),
                   1,
                   1,
                   ''
                        )
        );

        IF @Detail IS NOT NULL
        BEGIN
            SET @Detail = SUBSTRING(@Detail, 1, (LEN(@Detail) - 1));
        END;

        SET @Output = @Output + IIF(@Amount > 0, ISNULL(@Detail, ''), '') + ' ] }, ';
        SET @Index = @Index + 1;
    END;

    IF (@RowsNumber > 0)
    BEGIN
        SET @Output = SUBSTRING(@Output, 1, (LEN(@Output) - 1));
    END;

    SET @Output = @Output + '], ';
    SET @Output = @Output + '"Rejects": [ ';

    IF ((SELECT COUNT(1)FROM #listGuidesExcluded) > 0)
    BEGIN
        SET @Output
            = @Output
              +
              (
                  SELECT STUFF(
                         (
                             SELECT ' { "Guide": "' + CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR))
                                    + '", ' +
                                 --'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
                                 --'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
                                 '"StatusOrderId": ' + CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', '
                                    + '"Description": "' +'Guía en estado : ' + lge.Description +' , no permite realizar el proceso.' + '" }, '
                             FROM #listGuidesExcluded lge
                             FOR XML PATH('')
                         ),
                         1,
                         1,
                         ''
                              )
              );
    END;

    IF ((SELECT COUNT(1)FROM #listGuidesNotExist) > 0)
    BEGIN
        SET @Output
            = @Output
              +
              (
                  SELECT STUFF(
                         (
                             SELECT ' { "Guide": "' + CONCAT(lgne.Guide_Serie, CAST(lgne.Guide_Number AS VARCHAR))
                                    + '", ' +
                                 --'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
                                 --'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
                                 '"StatusOrderId": ' + CAST(ISNULL(lgne.StatusOrderId, 0) AS VARCHAR) + ', '
                                  + '"Description": "' + lgne.Description + '" }, '
                             FROM #listGuidesNotExist lgne
                             FOR XML PATH('')
                         ),
                         1,
                         1,
                         ''
                              )
              );
    END;

    IF (
           (
           (
               SELECT COUNT(1)FROM #listGuidesExcluded
           ) > 0
           )
           OR (
              (
                  SELECT COUNT(1)FROM #listGuidesNotExist
              ) > 0
              )
       )
    BEGIN
        SET @Output = SUBSTRING(@Output, 1, (LEN(@Output) - 1));
    END;

    SET @Output = @Output + ' ] } ]';

    SELECT @Output FormatJson;
END;