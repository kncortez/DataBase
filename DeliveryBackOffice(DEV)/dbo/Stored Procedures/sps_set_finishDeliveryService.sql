-- =============================================
-- Author:		<Tito García>
-- Create date: <2025-06-23>
-- Description:	<Confirma servicio de entrega de guía en express center>
-- =============================================
CREATE PROCEDURE [dbo].[sps_set_finishDeliveryService]
    @IdModuleP INT
  , @TokenP VARCHAR(100)
  , @CUI VARCHAR(100)
  , @Name VARCHAR(100)
  , @TblListGuides AS TblListGuidesWithAnticipatedCOD READONLY
  , @TblDetail AS TblPaymentList READONLY
  , @TblPayment AS TblPayment READONLY
  , @TblExclusions AS TblExclusions READONLY
AS
BEGIN
	SET ARITHABORT ON;
	SET NOCOUNT ON;

	BEGIN TRY
        -- =====================================================================
        -- SECCIÓN 1: INICIALIZACIÓN Y PREPARACIÓN DE DATOS
        -- =====================================================================
    
		DECLARE @DateCreated DATETIME = GETDATE();
		DECLARE @CatSalesPackageStatusId INT = 0;

		IF OBJECT_ID('tempdb.dbo.#listGuidesNotExist', 'U') IS NOT NULL
			DROP TABLE #listGuidesNotExist;
		IF OBJECT_ID('tempdb.dbo.#listGuidesEnabled', 'U') IS NOT NULL
			DROP TABLE #listGuidesEnabled;
		IF OBJECT_ID('tempdb.dbo.#listGuidesDisabled', 'U') IS NOT NULL
			DROP TABLE #listGuidesDisabled;
		IF OBJECT_ID('tempdb.dbo.#TempDataSFS', 'U') IS NOT NULL
			DROP TABLE #TempDataSFS;
		IF OBJECT_ID('tempdb.dbo.#TblListGuidesTwo', 'U') IS NOT NULL
			DROP TABLE #TblListGuidesTwo;
		IF OBJECT_ID('tempdb.dbo.#TempDataClientSFS', 'U') IS NOT NULL
			DROP TABLE #TempDataClientSFS;

		CREATE TABLE #TempDataSFS
		(
			IdProcessedGuideCOD INT,
			GuideSerie  NVARCHAR(2),
			GuideNumber INT
		);
		CREATE NONCLUSTERED INDEX INDX_sps_set_finishService_Temp ON #TempDataSFS (GuideSerie, GuideNumber);

		CREATE TABLE  #TempDataClientSFS
		(
			IdCustomer INT NOT NULL,
			PortfolioId INT NOT NULL,
		);
		CREATE NONCLUSTERED INDEX IDX_PK_TempDataClient ON #TempDataClientSFS (IdCustomer, PortfolioId);

		SELECT *
		INTO #TblListGuidesTwo
		FROM @TblListGuides;
		CREATE NONCLUSTERED INDEX IX_TLGT_SERIE ON #TblListGuidesTwo (Guide_Serie, Guide_Number);
		CREATE NONCLUSTERED INDEX IX_TLGT_EXCLUDE ON #TblListGuidesTwo (ExcludeCOD);

		DECLARE @IdTypeOfMoney INT;
		DECLARE @Amount DECIMAL(18, 2);
		DECLARE @Voucher VARCHAR(100);
		DECLARE @Responsible VARCHAR(100);

		SELECT @IdTypeOfMoney = td.IdTypeOfMoney
				, @Amount        = td.Amount
				, @Voucher       = td.Voucher
				, @Responsible   = td.Responsible
		FROM @TblDetail td;
		
        -- =====================================================================
        -- SECCIÓN 2: VALIDACIÓN DE GUIAS EXISTENTES EN EL SISTEMA
        -- =====================================================================

		SELECT lg.Guide_Serie
				, lg.Guide_Number
				, -1                                 StatusOrderId
				, 'La guía no existe en el sistema.' 'Description'
		INTO #listGuidesNotExist
		FROM #TblListGuidesTwo lg
		WHERE NOT EXISTS
		(
			SELECT 1
			FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
			WHERE lg.Guide_Serie = do.Guide_Serie 
				AND lg.Guide_Number = do.Guide_Number
		);	

		-- Si hay guías que no existen, terminar el proceso con error
		IF ((SELECT COUNT(1) FROM #listGuidesNotExist) <= 0)
		BEGIN
			SELECT
				  '2'															AS 'ResponseCode'
				, 'Existen guías que no existen en el sistema.'					AS 'Description'
				, ISNULL(lge.Description,'')									AS 'StatusOrderDescription'
				, CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR))	AS 'Guide'
				, '-1'															AS 'StatusOrderId'
			FROM #listGuidesNotExist lge;
            RETURN;
		END;
        
        -- =====================================================================
        -- SECCIÓN 3: VALIDACIÓN DE ESTADOS DE GUIAS
        -- =====================================================================
		SELECT lg.Guide_Serie
			, lg.Guide_Number
			, so.StatusOrderId
			, so.OrderDescription StatusOrderDescription
		INTO #listGuidesDisabled
		FROM #TblListGuidesTwo                              lg
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
				ON lg.Guide_Serie = do.Guide_Serie
				AND lg.Guide_Number = do.Guide_Number
			INNER JOIN DeliveryBackOffice.dbo.StatusOrder   so WITH (NOLOCK)
				ON do.StatusOrderId = so.StatusOrderId
		WHERE so.StatusOrderId NOT IN ( 2, 3, 10, 11, 20, 21 );

		IF ((SELECT COUNT(1)FROM #listGuidesDisabled) > 0)
		BEGIN --VER GUIAS VALIDAS E INVALIDAS

			SELECT
					'4'															AS 'ResponseCode'
				, 'Existen guías invalidas.'									AS 'Description'
				, ISNULL(lge.StatusOrderDescription,'')							AS 'StatusOrderDescription'
				, CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR))	AS 'Guide'
				, CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR)					AS 'StatusOrderId'
			FROM #listGuidesDisabled lge;			
            RETURN;
		END;
		
        -- =====================================================================
        -- SECCIÓN 4: PROCESAMIENTO DE GUIAS HABILITADAS
        -- =====================================================================
		SELECT lg.Guide_Serie
			, lg.Guide_Number
			, do.StatusOrderId
			, lg.ExcludeCOD
			, do.IdCustomer
			, do.PriceShippment
			, lg.IsAnticipatedCOD
		INTO #listGuidesEnabled
		FROM #TblListGuidesTwo                              lg
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
				ON lg.Guide_Serie = do.Guide_Serie
					AND lg.Guide_Number = do.Guide_Number
		WHERE do.StatusOrderId IN ( 2, 3, 10, 11, 20, 21 );

		CREATE NONCLUSTERED INDEX IX_TLGT_SERIE_enable ON #listGuidesEnabled (Guide_Serie, Guide_Number);
		CREATE NONCLUSTERED INDEX IX_TLGT_SERIE_enable_excludeCOD ON #listGuidesEnabled (ExcludeCOD);

		DECLARE @TotalAmount DECIMAL(18, 2);
		DECLARE @TotalAmountPortal DECIMAL(18, 2);
		SET @TotalAmount = ( SELECT SUM(AmountToPay)FROM #TblListGuidesTwo);
		SET @TotalAmountPortal = ( SELECT SUM(ServiceAmount)FROM @TblPayment );

		IF (@TotalAmount IS NULL)
		BEGIN
			SET @TotalAmount = 0;
		END;

		DECLARE @TotalCODAmount DECIMAL(18, 2);
		DECLARE @TotalCODAmountPortal DECIMAL(18, 2);
		DECLARE @Exclude INT;
		SET @TotalCODAmount = ( SELECT SUM(CODAmount)FROM #TblListGuidesTwo);
		SET @TotalCODAmountPortal = ( SELECT SUM(CODAmount)FROM @TblPayment );
		SET @Exclude = ( SELECT COUNT(ExcludeCOD)FROM #TblListGuidesTwo WHERE ExcludeCOD = 1 );

		IF (@TotalAmount <> @TotalAmountPortal) --VALIDAR SUMAS ServiceAmount
		BEGIN

			SELECT
					'5'															AS 'ResponseCode'
				, 'La suma de las guías no coincide con el monto de pago.'		AS 'Description';
			RETURN;
				
		END;

        -- =====================================================================
        -- SECCIÓN 5: TRANSACCIÓN PRINCIPAL - ACTUALIZACIÓN DE ESTADOS
        -- =====================================================================

		IF (
				((@TotalCODAmount = @TotalCODAmountPortal) AND (@Exclude = 0))
				OR (@Exclude > 0)
			)
		BEGIN
			-- GUIAS INCLUDE 

			DECLARE @TblInclude AS TABLE
			(
					Guide_Serie VARCHAR(2) NULL
				, Guide_Number INT NULL
				, ExcludeCOD BIT NULL
			);

			INSERT INTO @TblInclude
			(
					Guide_Serie
				, Guide_Number
				, ExcludeCOD
			)
			SELECT    tlg.Guide_Serie
					, tlg.Guide_Number
					, tlg.ExcludeCOD
			FROM #TblListGuidesTwo tlg
			WHERE tlg.ExcludeCOD = 0;

			DECLARE @TotalGuidesInclude DECIMAL(18, 2);
			SET @TotalGuidesInclude =
			(
				SELECT SUM(pd.CODAmount)
				FROM #TblListGuidesTwo   pd
					INNER JOIN @TblInclude ti
						ON pd.Guide_Serie = ti.Guide_Serie
						AND pd.Guide_Number = ti.Guide_Number
			);

			IF (@TotalGuidesInclude IS NULL)
			BEGIN
				SET @TotalGuidesInclude = 0;
			END;

			IF (@TotalGuidesInclude = @TotalCODAmountPortal)
			BEGIN
				BEGIN TRANSACTION;

				DECLARE @VoucherExclude VARCHAR(100);
				DECLARE @ResponsibleExclude VARCHAR(100);
				SET @VoucherExclude = ( SELECT TOP 1 Voucher FROM @TblExclusions );
				SET @ResponsibleExclude = ( SELECT TOP 1 Responsible FROM @TblExclusions );

				DECLARE @statusOrderId INT = 22; -- Entregado En Express Center
				DECLARE @observations NVARCHAR(200) = CONCAT('Entregado a ', @Name, ' ', ISNULL(@CUI, ''));

				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
				(
					Guide_Serie
					, Guide_Number
					, StatusOrderId
					, UserCreated
					, DateCreated
					, DateCreatedInSystem
					, Observations
				)
				SELECT lge.Guide_Serie
					, lge.Guide_Number
					, @statusOrderId
					, @TokenP      UserCreated
					, @DateCreated DateCreated
					, @DateCreated DateCreatedInSystem
					, @observations
				FROM #listGuidesEnabled lge;

				UPDATE dot
				SET dot.Observations = 'Entregado a ' + @Name + ', Entrega sin cobro COD '
									+ @VoucherExclude + ' ' + @ResponsibleExclude
				FROM DeliveryOrderDetail          dot WITH (NOLOCK)
					INNER JOIN #listGuidesEnabled lge
						ON lge.Guide_Serie = dot.Guide_Serie
						AND lge.Guide_Number = dot.Guide_Number
				WHERE lge.ExcludeCOD = 1
				AND dot.StatusOrderId = 22;

				
				-- ==============================================================================
				-- SECCIÓN 6: INSERTAR REGISTRO EN ProcessGuideCOD CUANDO SEA ENTREGA Y SEA COD
				-- ==============================================================================

				UPDATE do
					SET do.Collect_OnDelivery = 0
					, do.LastCollectOnDelivery = ppt.CODAmount
				FROM DeliveryOrder                 do WITH (NOLOCK)
					INNER JOIN #listGuidesEnabled  lge
						ON lge.Guide_Serie = do.Guide_Serie
						AND lge.Guide_Number = do.Guide_Number
					INNER JOIN #TblListGuidesTwo ppt
						ON ppt.Guide_Serie = do.Guide_Serie
						AND ppt.Guide_Number = do.Guide_Number
				WHERE lge.ExcludeCOD = 1;

				INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD
				(
					GuideSerie
					, GuideNumber
					, DataOriginId
					, Token
					, CustomerId
					, IsAnticipatedCOD
				)
				OUTPUT	inserted.IdProcessedGuideCOD,
						inserted.GuideSerie,
						inserted.GuideNumber
				INTO #TempDataSFS
				SELECT lge.Guide_Serie
					, lge.Guide_Number
					, 25
					, @TokenP UserCreated
					, cus.IdCustomer
					, 0 AS 'IsAnticipatedCOD'
				FROM #listGuidesEnabled            lge
					INNER JOIN DeliveryOrder       dlo WITH (NOLOCK)
						ON lge.Guide_Serie = dlo.Guide_Serie
							AND lge.Guide_Number = dlo.Guide_Number
					LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
						ON vp.CodeOfReference = dlo.Sender_ID
					LEFT JOIN dbo.Customer         cus WITH (NOLOCK)
						ON cus.IdCustomer = ISNULL(dlo.IdCustomer, vp.CustomerID)
					LEFT JOIN ProcessedGuideCOD    pcd WITH (NOLOCK)
						ON pcd.GuideSerie = dlo.Guide_Serie
							AND pcd.GuideNumber = dlo.Guide_Number
				WHERE dlo.Collect_OnDelivery > 0
					AND pcd.IdProcessedGuideCOD IS NULL
				UNION
				SELECT lge.Guide_Serie
					, lge.Guide_Number
					, 25
					, @TokenP UserCreated
					, cus.IdCustomer
					, 0 AS 'IsAnticipatedCOD'
				FROM #listGuidesEnabled            lge
					INNER JOIN DeliveryOrder       dlo WITH (NOLOCK)
						ON lge.Guide_Serie = dlo.Guide_Serie
							AND lge.Guide_Number = dlo.Guide_Number
					LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
						ON vp.CodeOfReference = dlo.Sender_ID
					LEFT JOIN dbo.Customer         cus WITH (NOLOCK)
						ON cus.IdCustomer = ISNULL(dlo.IdCustomer, vp.CustomerID)
					LEFT JOIN ProcessedGuideCOD    pcd WITH (NOLOCK)
						ON pcd.GuideSerie = dlo.Guide_Serie
							AND pcd.GuideNumber = dlo.Guide_Number
				WHERE	(
							dlo.Collect_OnDelivery = 0
							AND dlo.IsCollect = 'true'
						)
						AND pcd.IdProcessedGuideCOD IS NULL
				UNION
				SELECT lge.Guide_Serie
					, lge.Guide_Number
					, 25
					, @TokenP UserCreated
					, cus.IdCustomer
					, 0 AS 'IsAnticipatedCOD'
				FROM #listGuidesEnabled                       lge
					INNER JOIN DeliveryOrder                  dlo WITH (NOLOCK)
					ON lge.Guide_Serie = dlo.Guide_Serie
						AND lge.Guide_Number = dlo.Guide_Number
					INNER JOIN dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
						ON dlo.Guide_Serie = DOP.GuideSerie
							AND dlo.Guide_Number = DOP.GuideNumber
					LEFT JOIN dbo.VisitPointClient            vp WITH (NOLOCK)
						ON vp.CodeOfReference = dlo.Sender_ID
					LEFT JOIN dbo.Customer                    cus WITH (NOLOCK)
						ON cus.IdCustomer = ISNULL(dlo.IdCustomer, vp.CustomerID)
					LEFT JOIN ProcessedGuideCOD               pcd WITH (NOLOCK)
						ON pcd.GuideSerie = dlo.Guide_Serie
							AND pcd.GuideNumber = dlo.Guide_Number
				WHERE	(
							dlo.IsCollect = 'false'
							AND DOP.TimePlaId = 2
						)
						AND pcd.IdProcessedGuideCOD IS NULL;
				-- ACTUALIZACION DE ESTADO DE BALANCE PARA ANTICIPATEDCODDETAIL
				UPDATE ACD
				SET ACD.BalanceStatus = 'COBRADO',
					ACD.DateUpdated = GETDATE(),
					ACD.TokenUpdated = @TokenP
				FROM DeliveryBackOffice.dbo.AnticipatedCODDetail ACD WITH(NOLOCK)
				INNER JOIN #listGuidesEnabled LGD
					ON LGD.Guide_Serie = ACD.GuideSerie AND LGD.Guide_Number = ACD.GuideNumber

				-- FIN INSERTAR REGISTRO EN ProcessGuideCOD

				DECLARE @NewStatusOrderId INT;
				SET @NewStatusOrderId = 22;

				UPDATE do
					SET do.StatusOrderId = @NewStatusOrderId
				FROM DeliveryOrder                do WITH (NOLOCK)
				INNER JOIN #listGuidesEnabled lge
					ON lge.Guide_Serie = do.Guide_Serie
					AND lge.Guide_Number = do.Guide_Number;

				UPDATE dop
					SET StatusOrderId = @NewStatusOrderId
				FROM DeliveryOrderPiece           dop WITH (NOLOCK)
				INNER JOIN #listGuidesEnabled lge
					ON lge.Guide_Serie = dop.GuideSerie
					AND lge.Guide_Number = dop.GuideNumber;

				DECLARE @CartGuides AS TABLE
				(
					GuideSerie NVARCHAR(2)
					, GuideNumber INT
				);

				UPDATE ASCD
				SET RowStatus = 0
				, TokenUpdated = @TokenP
				, DateUpdated = GETDATE()
				OUTPUT inserted.GuideSerie
						, inserted.GuideNumber
				INTO @CartGuides
				(
					GuideSerie, GuideNumber
				)
				FROM [DeliveryBackOffice].[dbo].[AccountServiceCartDetail] ASCD WITH (NOLOCK)
					INNER JOIN #listGuidesEnabled                          LGE
						ON ASCD.GuideSerie = LGE.Guide_Serie
						AND ASCD.GuideNumber = LGE.Guide_Number
				WHERE ASCD.RowStatus = 1;

				UPDATE DOPD
					SET DOPD.ShipmentCompleted = 1
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD
				INNER JOIN @CartGuides                                   CG
					ON DOPD.GuideSerie = CG.GuideSerie
					AND DOPD.GuideNumber = CG.GuideNumber;


				-- =====================================================================
				-- SECCIÓN 7: REGISTRO DE COSTOS Y PAGOS
				-- =====================================================================
				DECLARE @IdCost INT = 0;
				DECLARE @TotalAmountPaid DECIMAL(18, 2) = 0;
				DECLARE @ProductNumber VARCHAR(25);
				DECLARE @FullPayment DECIMAL(18, 2);
				DECLARE @CODPayment DECIMAL(18, 2);
				DECLARE @Serie VARCHAR(2);
				DECLARE @Number VARCHAR(20);

				-- si no existe insertar registro en tabla cost
				INSERT INTO [dbo].[Cost]
				(
					[IdProduct]
				, [ProductNumber]
				, [IdTypeCharge]
				, [TotalAmount]
				, [PaymentDate]
				, [IdModule]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated]
				, [TotalAmountPaid]
				, [CODAmount]
				, [GuideSerie]
				, [GuideNumber]
				)
				SELECT 1                                                                                IdProduct
					, CONCAT(ti.Guide_Serie, ti.Guide_Number)                                           ProductNumber
					, 1                                                                                 IdTypeCharge
					, pgt.AmountToPay																	TotalAmount
					, GETDATE()                                                                         PaymentDate
					, @IdModuleP                                                                        IdModule
					, 1                                                                                 RowStatus
					, @TokenP                                                                           TokenCreated
					, GETDATE()                                                                         DateCreated
					, pgt.AmountToPay																	TotalAmountPaid
					, pgt.CODAmount																		CODAmount
					, ti.Guide_Serie
					, ti.Guide_Number
				FROM @TblInclude                   ti
					INNER JOIN #TblListGuidesTwo pgt
						ON ti.Guide_Serie = pgt.Guide_Serie
						AND ti.Guide_Number = pgt.Guide_Number
				WHERE NOT EXISTS
				(
					SELECT 1
					FROM dbo.Cost ct WITH (NOLOCK)
					WHERE ct.GuideSerie = ti.Guide_Serie
						AND ct.GuideNumber = ti.Guide_Number
				);

				UPDATE ct
				SET 
						ct.[PaymentDate] = GETDATE()
					, ct.[TokenUpdated] = @TokenP
					, ct.[DateUpdated] = GETDATE()
					, ct.[TotalAmountPaid] = ppt.AmountToPay
					, ct.[CODAmount] =  ppt.CODAmount
					, ct.[GuideSerie] = (CASE
											WHEN ct.IdCost = CoAux.IdCost THEN
												ti.Guide_Serie
											ELSE
												NULL
										END
										)
					, ct.[GuideNumber] = (CASE
												WHEN ct.IdCost = CoAux.IdCost THEN
													ti.Guide_Number
												ELSE
													NULL
											END
										)
				FROM Cost                          ct WITH (NOLOCK)
					INNER JOIN #TblListGuidesTwo ppt
						ON ct.GuideSerie = ppt.Guide_Serie
						AND ct.GuideNumber = ppt.Guide_Number
					INNER JOIN @TblInclude         ti
						ON ct.GuideSerie = ti.Guide_Serie
						AND ct.GuideNumber = ti.Guide_Number
					OUTER APPLY
					(
						SELECT TOP 1 Co.IdCost
						FROM [DeliveryBackOffice].[dbo].[Cost] Co WITH (NOLOCK)
						WHERE Co.GuideSerie = ti.Guide_Serie
							AND Co.GuideNumber = ti.Guide_Number
							AND Co.RowStatus = 1
						ORDER BY Co.DateCreated DESC
					)                                  CoAux
				WHERE ISNULL(ct.TotalAmountPaid, 0) = 0;

				IF (@Amount > 0)
				BEGIN
					INSERT INTO [dbo].[CostDetail]
					(
							[IdCost]
						, [IdTypeOfMoney]
						, [Amount]
						, [Voucher]
						, [RowStatus]
						, [TokenCreated]
						, [DateCreated]
						, [Responsible]
					)
					SELECT ct.IdCost
						, @IdTypeOfMoney
						, ct.TotalAmountPaid
						, IIF(@IdTypeOfMoney = 6, @Voucher, '')
						, 1 -- crear registro activo por default
						, @TokenP
						, GETDATE()
						, @Responsible
					FROM Cost                                             ct WITH(NOLOCK)
						INNER JOIN @TblInclude                            ti
							ON ct.GuideSerie = ti.Guide_Serie
							AND ti.Guide_Number = ti.Guide_Number
						LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH(NOLOCK)
							ON ct.IdCost = CD.IdCost
					WHERE ISNULL(ct.TotalAmountPaid, 0) <> 0
					AND NOT EXISTS (
							SELECT 1
							FROM [DeliveryBackOffice].[dbo].[CostDetail] cd WITH(NOLOCK)
							WHERE cd.IdCost = ct.IdCost
						);

					UPDATE CD
						SET CD.Amount = ct.TotalAmountPaid
						, CD.IdTypeOfMoney = @IdTypeOfMoney
						, CD.Voucher = IIF(@IdTypeOfMoney = 6, @Voucher, '')
						, CD.TokenUpdated = @TokenP
						, CD.DateUpdated = GETDATE()
					FROM Cost                                              ct WITH(NOLOCK)
						INNER JOIN @TblInclude                             ti
							ON ct.GuideSerie = ti.Guide_Serie
							AND ct.GuideNumber = ti.Guide_Number
						INNER JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH(NOLOCK)
							ON ct.IdCost = CD.IdCost
					WHERE ISNULL(ct.TotalAmountPaid, 0) <> 0;
				END;
				-- FIN Guardar Costos
		
				-- Borrado Logico de posición en la guía
				UPDATE wh
					SET Active = 0
					,UserUpdated = @TokenP
					,DateUpdated = GETDATE()
				FROM Warehouse wh WITH(NOLOCK)
				INNER JOIN #TblListGuidesTwo tlg
					ON wh.Guide_Serie = tlg.Guide_Serie
					AND wh.Guide_Number = tlg.Guide_Number
				WHERE wh.Active = 1


				-- =====================================================================
				-- SECCIÓN 8: ACUMULACIÓN DE PUNTOS FORZA
				-- =====================================================================

				DECLARE @MembershipId INT = 0;
				DECLARE @MaxServiceMembership INT = 0;
				DECLARE @CustomerId INT = 0;
				DECLARE @DayName NVARCHAR(20) = N'';
				DECLARE @IsValidDay BIT = 0;
				DECLARE @PointsGenerated INT = 0;
				DECLARE @ForzaPointsGenerationValue DECIMAL = 0;
				DECLARE @ForzaPointsGenerationType NVARCHAR(50) = N'';
				DECLARE @CatPointPromoTbl TABLE
				(
					IdPointPromo INT
					, PointPromoDescription NVARCHAR(400)
					, Monday BIT
					, Tuesday BIT 
					, Wednesday BIT
					, Thursday BIT
					, Friday BIT  
					, Saturday BIT
					, Sunday BIT
					, PointPromoFactor DECIMAL
				);
				DECLARE @TblGuidesForPoints TABLE
				(
					GuideSerie NVARCHAR(5)
					, GuideNumber INT
					, CustomerId INT
					, PriceShipment DECIMAL(18, 2)
					, LogServiceNumber INT
					, MembershipId INT
					, MaxServiceMembership INT
				);

				SET @ForzaPointsGenerationType = (	SELECT [Value] FROM DeliveryBackOffice.dbo.ConfigParams WITH(NOLOCK)
													WHERE  [Name] = 'ForzaPointsGenerationType');

				SET @ForzaPointsGenerationValue = (	SELECT [Value] FROM DeliveryBackOffice.dbo.ConfigParams WITH(NOLOCK)
													WHERE  [Name] = 'ForzaPointsGenerationValue');

				SET @CatSalesPackageStatusId   =  (	SELECT [IdCatSalesPackageStatus] FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] WITH(NOLOCK)
													WHERE  [SalesPackageStatusName] = 'Activa' AND [RowStatus] = 1 );

				INSERT INTO @CatPointPromoTbl
				SELECT TOP 1
						[CPP].[IdPointPromo]
						, [CPP].[PointPromoDescription]
						, [CPP].[Monday]
						, [CPP].[Tuesday]
						, [CPP].[Wednesday]
						, [CPP].[Thursday]
						, [CPP].[Friday]
						, [CPP].[Saturday]
						, [CPP].[Sunday]
						, [CPP].[PointPromoFactor]
				FROM [dbo].[CatPointPromo] CPP
				WHERE [CPP].[RowStatus] = 1
						AND [CPP].[InPointGeneration] = 1
						AND SYSDATETIME()
						BETWEEN [CPP].[StartPromoDate] AND [CPP].[FinishPromoDate]
				ORDER BY [CPP].[PointPromoWeight] DESC;

				DECLARE @AuxCont INT = ( SELECT COUNT(1)FROM #listGuidesEnabled);
                DECLARE @AuxGuideSerie NVARCHAR(5);
                DECLARE @AuxGuideNumber INT;
                DECLARE @AuxPriceShipment DECIMAL(18, 2);
                DECLARE @AuxLogServiceNumber INT;
                DECLARE @AuxPointsGenerated INT;

                INSERT INTO @TblGuidesForPoints
                (
                        [GuideSerie]
					, [GuideNumber]
					, [CustomerId]
					, [PriceShipment]
					, [LogServiceNumber]
					, [MembershipId]
					, [MaxServiceMembership]
                )
                SELECT [LEG].[Guide_Serie]
                    , [LEG].[Guide_Number]
                    , [LEG].[IdCustomer]
                    , [LEG].[PriceShippment]
                    , ISNULL([MSL].[LogServiceNumber], 0)
                    , ISNULL([M].[IdMembership], 0)
                    , ISNULL([M].[MembershipMaxServiceFixedValue], 0)
                FROM #listGuidesEnabled                         LEG
                LEFT JOIN [dbo].[MembershipSubscriptionLog] MSL WITH(NOLOCK)
                    ON [LEG].[Guide_Serie] = [MSL].[LogGuideSerie]
                    AND [LEG].[Guide_Number] = [MSL].[LogGuideNumber]
                        AND [MSL].[SalesPackageStatusId] = @CatSalesPackageStatusId
                LEFT JOIN [dbo].[Membership]                M WITH(NOLOCK)
                        ON [LEG].[IdCustomer] = [M].[CustomerId]
                        AND [M].[ExpirationDate] >= SYSDATETIME()
                        AND [M].[RowStatus] = 1
                        AND [MSL].[RowStatus] = 1;

				WHILE @AuxCont > 0
                -- Recorrer listado de guías
                BEGIN

					SELECT TOP 1
                            @MembershipId         = [TGP].[MembershipId]
                        , @MaxServiceMembership = [TGP].[MaxServiceMembership]
                        , @CustomerId           = [TGP].[CustomerId]
                        , @AuxGuideSerie        = [TGP].[GuideSerie]
                        , @AuxGuideNumber       = [TGP].[GuideNumber]
                        , @AuxPriceShipment     = [TGP].[PriceShipment]
                        , @AuxLogServiceNumber  = [TGP].[LogServiceNumber]
                    FROM @TblGuidesForPoints TGP;

					SET @AuxPointsGenerated = 
					CASE
                        WHEN @ForzaPointsGenerationType = 'SERVICIO'	THEN
                            CAST(@ForzaPointsGenerationValue AS INT)
                        WHEN @ForzaPointsGenerationType = 'MONTO'		THEN
                            CAST((@AuxPriceShipment / @ForzaPointsGenerationValue) AS INT)
                        ELSE
                            0
                    END;

					IF (	@MembershipId > 0
                            AND
                            ( @AuxLogServiceNumber > @MaxServiceMembership OR @AuxLogServiceNumber = 0 )
                        )
					BEGIN
									
						-- Agregar Log de puntos 
                        INSERT INTO [dbo].[PointsByServiceLog]
                        (
								[MembershipId]
							, [GuideSerie]
							, [GuideNumber]
							, [GuidePrice]
							, [PointsReceived]
							, [PointsConsumed]
							, [TypeTransaction]
							, [CatPointPromoId]
							, [RowStatus]
							, [DateCreated]
							, [TokenCreated]
                        )
                        VALUES
                        (   @MembershipId, @AuxGuideSerie, @AuxGuideNumber, @AuxPriceShipment
                        , @AuxPointsGenerated -- POINTS GENERATED
                        , 0                   -- POINTS CONSUMED
                        , @ForzaPointsGenerationType, NULL, 1, SYSDATETIME(), @TokenP);

						-- Acumulación adicional por promoción
						IF ((SELECT COUNT(IdPointPromo)FROM @CatPointPromoTbl) > 0)
						BEGIN

							SET @DayName = ( SELECT DATENAME(dw, SYSDATETIME()) );
                            SET @IsValidDay = 
							CASE
                                WHEN @DayName = 'Monday' THEN
                                (
                                    SELECT TOP 1 Monday FROM @CatPointPromoTbl
                                )
                                WHEN @DayName = 'Tuesday' THEN
                                (
                                    SELECT TOP 1 Tuesday FROM @CatPointPromoTbl
                                )
                                WHEN @DayName = 'Wednesday' THEN
                                (
                                    SELECT TOP 1 Wednesday FROM @CatPointPromoTbl
                                )
                                WHEN @DayName = 'Thursday' THEN
                                (
                                    SELECT TOP 1 Thursday FROM @CatPointPromoTbl
                                )
                                WHEN @DayName = 'Friday' THEN
                                (
                                    SELECT TOP 1 Friday FROM @CatPointPromoTbl
                                )
                                WHEN @DayName = 'Saturday' THEN
                                (
                                    SELECT TOP 1 Saturday FROM @CatPointPromoTbl
                                )
                                WHEN @DayName = 'Sunday' THEN
                                (
                                    SELECT TOP 1 Sunday FROM @CatPointPromoTbl
                                )
                                ELSE
                                    0
                            END;
							IF (@IsValidDay = 1)
                            BEGIN

								UPDATE PSL
                                    SET [PSL].[CatPointPromoId] = ( SELECT IdPointPromo FROM @CatPointPromoTbl )
                                        , [PSL].[PointsReceived] = [PSL].[PointsReceived] + 
										CASE
                                            WHEN @ForzaPointsGenerationType = 'SERVICIO' THEN
                                                CAST((
                                                        SELECT PointPromoFactor FROM @CatPointPromoTbl
                                                        ) AS INT)
                                            WHEN @ForzaPointsGenerationType = 'MONTO'	THEN
                                                CAST([PSL].[PointsReceived]
                                                /
                                                ( SELECT PointPromoFactor FROM @CatPointPromoTbl) AS INT)
                                            ELSE
                                                0
                                        END
                                FROM [dbo].[PointsByServiceLog] PSL WITH(NOLOCK)
                                WHERE [PSL].[GuideSerie] = @AuxGuideSerie
                                AND [PSL].[GuideNumber] = @AuxGuideNumber;

							END;
						END;
						-- Agregar puntos a membresía
                        SET @PointsGenerated
                            = ISNULL(
								( SELECT SUM([PSL].[PointsReceived])
                                    FROM [dbo].[PointsByServiceLog] PSL WITH(NOLOCK)
                                    WHERE [PSL].[GuideSerie] = @AuxGuideSerie
                                    AND [PSL].[GuideNumber] = @AuxGuideNumber ) , 0);

                        UPDATE [dbo].[Membership]
							SET [AccumulatedPoints] = ISNULL([AccumulatedPoints], 0) + (@PointsGenerated)
							, [AvailablePoints] = ISNULL([AvailablePoints], 0) + (@PointsGenerated)
                        WHERE [IdMembership] = @MembershipId;

					END;

					DELETE TOP (1)
                    FROM @TblGuidesForPoints;
                    SET @AuxCont =
                    (
                        SELECT COUNT(1)FROM @TblGuidesForPoints
                    );

				END;
				
				-- =====================================================================
				-- SECCIÓN 9: SERVICIO WEBHOOK
				-- =====================================================================
				DECLARE @WebhookCustomerTable AS TABLE
                (
                    CustomerId INT
                    , CustomerEndpointId BIGINT
                    , WebhookType INT
                    , GuideSerie NVARCHAR(2)
                    , GuideNumber INT
                    , GuideStatusId TINYINT
                );

				DECLARE @GuideStatusChangeWebhook INT =
                (
                    SELECT TOP 1
                        WT.IdWebhookType
                    FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH (NOLOCK)
                    WHERE WT.WebhookName = 'GuideStatusChange'
                        AND WT.RowStatus = 1
                );

				-- Clientes de las guías por procesar
                INSERT INTO @WebhookCustomerTable
                (
                        CustomerId
					, GuideSerie
					, GuideNumber
					, GuideStatusId
                )
                SELECT DISTINCT
                        DO.IdCustomer
                    , TLG.Guide_Serie
                    , TLG.Guide_Number
                    , DO.StatusOrderId
                FROM #TblListGuidesTwo TLG
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                        ON TLG.Guide_Serie = DO.Guide_Serie
                        AND TLG.Guide_Number = DO.Guide_Number;

				-- Ingresar endpoints de cliente
                UPDATE @WebhookCustomerTable
					SET CustomerEndpointId = WE.IdWebhookEndpoint
					, WebhookType = @GuideStatusChangeWebhook
                FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH (NOLOCK)
                    INNER JOIN @WebhookCustomerTable              WCT
                        ON WE.CustomerId = WCT.CustomerId
                WHERE WE.WebhookTypeId = @GuideStatusChangeWebhook;

				DECLARE @ResponseTable AS TABLE
                (
                    InsertedId BIGINT
                );

                INSERT INTO [DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
                (
                    [GuideSerie]
                    , [GuideNumber]
                    , [CustomerId]
                    , [StatusOrderId]
                    , [WebhookEndpointId]
                    , [HasNotified]
                    , [TokenCreated]
                    , [DateCreated]
                )
                OUTPUT inserted.IdWebhookTrackingQueue
                INTO @ResponseTable
                (
                    InsertedId
                )
                SELECT WCT.GuideSerie
                    , WCT.GuideNumber
                    , WCT.CustomerId
                    , WCT.GuideStatusId
                    , WCT.CustomerEndpointId
                    , 0
                    , @TokenP
                    , GETDATE()
                FROM @WebhookCustomerTable                                           WCT
                    LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH (NOLOCK)
                        ON WCT.CustomerId = WRBU.CustomerId
                        AND WCT.GuideStatusId = WRBU.StatusOrderId
                        AND WCT.WebhookType = WRBU.WebhookTypeId
                    INNER JOIN [DeliveryBackOffice].[dbo].[WebhookEndpoint]          WHE WITH (NOLOCK)
                        ON WRBU.CustomerId = WHE.CustomerId
                    LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookTrackingQueue]      WTQ WITH (NOLOCK)
                        ON WCT.GuideSerie = WTQ.GuideSerie
                        AND WCT.GuideNumber = WTQ.GuideNumber
                        AND WCT.GuideStatusId = WTQ.StatusOrderId
                        AND WTQ.RowStatus = 1
                WHERE WRBU.IdWebhookRestrinctionByUser IS NOT NULL
                    AND WTQ.IdWebhookTrackingQueue IS NULL
                    AND WHE.TypeConnectionId = 1;

				--Agregar datos en cola de webhooks de clientes SFTP---INI
                DECLARE @GuidePiecesTable AS TABLE
                (
                    CustomerId INT
                    , CustomerEndpointId BIGINT
                    , WebhookType INT
                    , GuideSerie NVARCHAR(2)
                    , GuideNumber INT
                    , GuideStatusId TINYINT
                    , NumberPieces INT
                    , NumberRelatedPieces INT
                );

				INSERT INTO @GuidePiecesTable
                (
                        CustomerId
                    , GuideSerie
                    , GuideNumber
                    , GuideStatusId
                    , NumberPieces
                )
                SELECT wct.CustomerId
                    , dop.GuideSerie
                    , dop.GuideNumber
                    , wct.GuideStatusId
                    , COUNT(dop.GuideNumber)
                FROM DeliveryOrderPiece              dop WITH (NOLOCK)
                    INNER JOIN @WebhookCustomerTable wct
                        ON dop.GuideSerie = wct.GuideSerie
                        AND dop.GuideNumber = wct.GuideNumber
                    INNER JOIN WebhookEndpoint       WHE WITH (NOLOCK)
                        ON wct.CustomerId = WHE.CustomerId
                    INNER JOIN DeliveryOrder         do WITH (NOLOCK)
                        ON dop.GuideSerie = do.Guide_Serie
                        AND dop.GuideNumber = do.Guide_Number
                WHERE do.IdCustomer = wct.CustomerId
                    AND WHE.TypeConnectionId = 2
                GROUP BY wct.CustomerId
                    , dop.GuideSerie
                    , dop.GuideNumber
                    , wct.GuideStatusId;

				DECLARE @PiecesGuideRelatedTable AS TABLE
                (
                        CustomerId INT
                    , CustomerEndpointId BIGINT
                    , WebhookType INT
                    , GuideSerie NVARCHAR(2)
                    , GuideNumber INT
                    , GuideStatusId TINYINT
                    , NumberRelatedPieces INT
                );

                INSERT INTO @PiecesGuideRelatedTable
                (
                        CustomerId
                    , GuideSerie
                    , GuideNumber
                    , GuideStatusId
                    , NumberRelatedPieces
                )
                SELECT wct.CustomerId
                    , dop.GuideSerie
                    , dop.GuideNumber
                    , wct.GuideStatusId
                    , COUNT(dop.GuideNumber)
                FROM DeliveryOrderPiece              dop WITH (NOLOCK)
                    INNER JOIN @WebhookCustomerTable wct
                        ON dop.GuideSerie = wct.GuideSerie
                            AND dop.GuideNumber = wct.GuideNumber
                    INNER JOIN WebhookEndpoint       WHE WITH (NOLOCK)
                        ON wct.CustomerId = WHE.CustomerId
                    INNER JOIN DeliveryOrder         do WITH (NOLOCK)
                        ON dop.GuideSerie = do.Guide_Serie
                        AND dop.GuideNumber = do.Guide_Number
                WHERE do.IdCustomer = wct.CustomerId
                    AND WHE.TypeConnectionId = 2
                    AND dop.ExternalPieceId IS NOT NULL
                GROUP BY wct.CustomerId
                    , dop.GuideSerie
                    , dop.GuideNumber
                    , wct.GuideStatusId;

				INSERT INTO WebhookTrackingQueueDetailForSFTP
                (
                        CustomerId
                    , GuideSerie
                    , GuideNumber
                    , GuidePiece
                    , ExternalNumber
                    , ExternalPieceId
                    , StatusOrderId
                    , RowStatus
                    , DateCreated
                    , TokenCreated
                )
                SELECT wct.CustomerId
                    , dop.GuideSerie
                    , dop.GuideNumber
                    , dop.GuidePiece
                    , do.Ticket_Number
                    , dop.ExternalPieceId
                    , wct.GuideStatusId
                    , 1         AS RowStatus
                    , GETDATE() AS DateCreated
                    , @TokenP   AS TokenCreated
                FROM DeliveryOrderPiece                 dop WITH (NOLOCK)
                    INNER JOIN @WebhookCustomerTable    wct
						ON dop.GuideSerie = wct.GuideSerie
                        AND dop.GuideNumber = wct.GuideNumber
                    INNER JOIN WebhookEndpoint          WHE WITH (NOLOCK)
                        ON wct.CustomerId = WHE.CustomerId
                    INNER JOIN DeliveryOrder            do WITH (NOLOCK)
						ON dop.GuideSerie = do.Guide_Serie
                        AND dop.GuideNumber = do.Guide_Number                                     
                    INNER JOIN @GuidePiecesTable        gpt
						ON wct.GuideSerie = gpt.GuideSerie
                        AND wct.GuideNumber = gpt.GuideNumber
					INNER JOIN @PiecesGuideRelatedTable pgt
						ON gpt.GuideSerie = pgt.GuideSerie
						AND gpt.GuideNumber = pgt.GuideNumber
                WHERE do.IdCustomer = wct.CustomerId
                    AND WHE.TypeConnectionId = 2
                    AND do.IdCustomer = wct.CustomerId    
                    AND gpt.NumberPieces = pgt.NumberRelatedPieces;

				-- =====================================================================
				-- SECCIÓN 10: TRANSACCION EXITOSA
				-- =====================================================================

				IF @@TRANCOUNT > 0
				BEGIN
				
					COMMIT TRANSACTION;

					UPDATE pgd 
					SET pgd.IsCompleted = 1
					FROM ProcessedGuideCOD pgd WITH(NOLOCK)
						INNER JOIN #TempDataSFS tmp
							ON pgd.GuideSerie   = tmp.GuideSerie
							AND pgd.GuideNumber = tmp.GuideNumber
							AND pgd.IdProcessedGuideCOD = tmp.IdProcessedGuideCOD;

					IF OBJECT_ID('tempdb..#TempDataSFS') IS NOT NULL
						DROP TABLE #TempDataSFS;
				END;

				SELECT
						'1'															AS 'ResponseCode'
					, 'Proceso realizado con exito'									AS 'Description'

			END;
			ELSE
			BEGIN

				SELECT
						'5'															AS 'ResponseCode'
					, 'La suma de las guias no coincide con el monto de pago.'		AS 'Description'

			END;

		END;


	END TRY
	BEGIN CATCH
        -- =====================================================================
        -- SECCIÓN 11: MANEJO DE ERRORES
        -- =====================================================================

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT
			  '6'															AS 'ResponseCode'
			, 'Hubo un error comuníquese con soporte.'						AS 'Description'

		SELECT 'ERROR'                               AS message
            , 'FALSE'                                AS blnResult
            , CAST(500 AS VARCHAR(5))                AS StatusResult
            , CAST(ERROR_NUMBER() AS VARCHAR)		 AS ErrorNumber
            , CAST(ERROR_SEVERITY() AS VARCHAR)      AS ErrorSeverity
            , CAST(ERROR_STATE() AS VARCHAR)         AS ErrorState
            , CAST(ERROR_PROCEDURE() AS VARCHAR)     AS ErrorProcedure
            , CAST(ERROR_LINE() AS VARCHAR)          AS ErrorLine
            , CAST(ERROR_MESSAGE() AS VARCHAR(3000)) AS ResultMessage;

        INSERT INTO [dbo].[RoutePreparationLogError]
			([ErrorDescription]
			,[ErrorNumber]
			,[ErrorProcedure]
			,[ErrorLine]
			,[GuideSerie]
			,[GuideNumber]
			,[TokenCreated]
			,[DateCreated])
        VALUES
            (CAST(ERROR_MESSAGE() AS VARCHAR(300))
            ,ERROR_NUMBER()
            ,CAST(ERROR_PROCEDURE() AS VARCHAR(3000))
            ,ERROR_LINE()
            ,NULL
            ,NULL
            ,@TokenP
            ,GETDATE())

	END CATCH;
END;
