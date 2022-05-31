USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetFinishService]    Script Date: 31/05/2022 10:29:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Alejandro, Rodríguez>
-- Create date: <2022-05-25>
-- Description:	< Copia del método sps_set_finishService pero haciendolo transaccional con la lógica de los SP's SetRecolectionRequest y Set >
-- =============================================

CREATE PROCEDURE [dbo].[SetFinishService] 
	
	--Campos de sps_set_finishService
	@InGuidesP VARCHAR(MAX),
	@TblListGuides AS TblListGuides READONLY,
	@TblDetail AS TblPaymentList READONLY,
	@IdModuleP INT,
	@TokenP VARCHAR(100),
	@ServiceType VARCHAR(100),
	@CUI VARCHAR(100),
	@Name VARCHAR(100),
	@TblPayment AS TblPayment READONLY,
	@TblExclusions AS TblExclusions READONLY,

	--Campos de SetRecolectionRequest
	@TblDeliveryOrdersList AS [TblDeliveryOrdersList2] READONLY,
	@Iscollected bit = true,
	@status int = 15,
	@ShipmentCompleted bit = true,
	@IdStatus as int = 15,
	@IdAccount as int = null,
	@InstructionsCurrier as nvarchar (300) = null,
	@PartDimensions as int  = 1,
	@Regularpiezer  as int  =  1,
	@StartDate as datetime = null,
	@EndDate as datetime  = null,
	@WeightEstimated as decimal (18,2) = null,
	@BigPackages as bit = false ,
	@ValidateFilter as int = 0,
	@RecollectionLatitude as decimal(18,15) = 0,
	@RecollectionLongitude as decimal(18,15) = 0,
	@DeliveryLatitude as decimal(18,15) = 0,
	@DeliveryLongitude as decimal(18,15) = 0,
	@IdUser INT = 0,

	--Campo nuevo para determinar si se hará la llamada al SP SetRecoletionRequest
	@TotalAmount decimal(18,15) = 0


AS
BEGIN

	DECLARE @DateCreated DATETIME = GETDATE();
	DECLARE @Output VARCHAR(MAX);
	DECLARE @statuscode INT = 200;

	DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
	BEGIN
        -- Procedure called when there is  
        -- an active transaction.  
        -- Create a savepoint to be able  
        -- to roll back only the work done  
        -- in the procedure if there is an  
        -- error.  
        SAVE TRANSACTION FinishService;  
	END
    ELSE  
	BEGIN
        -- Procedure must start its own  
        -- transaction.  
        BEGIN TRANSACTION;  
	END

	BEGIN
		-- Insert statements for procedure here
		--IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
		IF OBJECT_ID('tempdb.dbo.#listGuidesNotExist', 'U') IS NOT NULL
			DROP TABLE #listGuidesNotExist;
		IF OBJECT_ID('tempdb.dbo.#listGuidesEnabled', 'U') IS NOT NULL
			DROP TABLE #listGuidesEnabled;
		IF OBJECT_ID('tempdb.dbo.#listGuidesEnabled', 'U') IS NOT NULL
			DROP TABLE #listGuidesEnabled;
		IF OBJECT_ID('tempdb.dbo.#listGuidesDisabled', 'U') IS NOT NULL
			DROP TABLE #listGuidesDisabled;

		SELECT * INTO #TblListGuidesTwo
		FROM @TblListGuides;

		DECLARE @IdTypeOfMoney INT;
		DECLARE @Amount DECIMAL(18, 2);
		DECLARE @Voucher VARCHAR(100);
		DECLARE @Responsible VARCHAR(100);

		SELECT
			@IdTypeOfMoney = td.IdTypeOfMoney
		   ,@Amount = td.Amount
		   ,@Voucher = td.Voucher
		   ,@Responsible = td.Responsible
		FROM @TblDetail td;

		SELECT
			* INTO #TblExclusions2
		FROM @TblExclusions;



		CREATE NONCLUSTERED INDEX IX_TLGT_SERIE
			ON #TblListGuidesTwo (Guide_Serie);
		CREATE NONCLUSTERED INDEX IX_TLGT_NUMBER
			ON #TblListGuidesTwo (Guide_Number);
		CREATE NONCLUSTERED INDEX IX_TLGT_EXCLUDE
			ON #TblListGuidesTwo (ExcludeCOD);

		---- Obtener guias que no existen ------------------------------------
		SELECT
			lg.Guide_Serie
		   ,lg.Guide_Number
		   ,-1 StatusOrderId
		   ,'La guía no existe en el sistema.' 'Description' INTO #listGuidesNotExist
		FROM #TblListGuidesTwo lg
		WHERE NOT EXISTS (SELECT 1
			FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
			WHERE lg.Guide_Serie = do.Guide_Serie
				AND lg.Guide_Number = do.Guide_Number
			);

		CREATE NONCLUSTERED INDEX IX_LGNE_SERIE
			ON #listGuidesNotExist (Guide_Serie);
		CREATE NONCLUSTERED INDEX IX_LGNE_NUMBER
		ON #listGuidesNotExist (Guide_Number);

		--SELECT COUNT(1) FROM #listGuidesNotExist;
		IF ((SELECT
					COUNT(1)
				FROM #listGuidesNotExist)
			<= 0)
		BEGIN TRY

			IF (UPPER(@ServiceType) = 'PICKUP')
			BEGIN
				UPDATE #TblListGuidesTwo
				SET ExcludeCOD = 0;
			END;

			-- OBTENER GUIAS HABILITADAS --------------------------------------------------------------------

			SELECT
				lg.Guide_Serie
			   ,lg.Guide_Number
			   ,so.StatusOrderId
			   ,so.OrderDescription StatusOrderDescription
			   ,lg.ExcludeCOD INTO #listGuidesEnabled
			FROM #TblListGuidesTwo lg
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
				ON lg.Guide_Serie = do.Guide_Serie
					AND lg.Guide_Number = do.Guide_Number
			INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
				ON do.StatusOrderId = so.StatusOrderId
			WHERE (
					UPPER(@ServiceType) = 'PICKUP'
					AND so.StatusOrderId IN (15, 4, 1, 16)
					)
				OR (
					UPPER(@ServiceType) = 'DELIVERY'
					AND so.StatusOrderId IN (2, 3, 10, 11, 20, 21)
					)
					OR (
					UPPER(@ServiceType) = 'RETURN'
					AND so.StatusOrderId IN (2, 3, 8, 10, 11, 12, 17, 18, 20, 21)
					);


			-- OBTENER GUIAS DESHABILITADAS ---------------------------------------------------------------------
			SELECT
				lg.Guide_Serie
			   ,lg.Guide_Number
			   ,so.StatusOrderId
			   ,so.OrderDescription StatusOrderDescription INTO #listGuidesDisabled
			FROM #TblListGuidesTwo lg
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
				ON lg.Guide_Serie = do.Guide_Serie
					AND lg.Guide_Number = do.Guide_Number
			INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
				ON do.StatusOrderId = so.StatusOrderId
			WHERE (
			UPPER(@ServiceType) = 'PICKUP'
			AND so.StatusOrderId NOT IN (15, 4, 1, 16)
			)
			OR (
			UPPER(@ServiceType) = 'DELIVERY'
			AND so.StatusOrderId NOT IN (2, 3, 10, 11, 20, 21)
			)
			OR (
			UPPER(@ServiceType) = 'RETURN'
			AND so.StatusOrderId NOT IN (2, 3, 8, 10, 11, 12, 17, 18, 20, 21)
			);

			--Select *From #listGuidesDisabled;
			DECLARE @GuidesEnable INT;
			DECLARE @GuidesDisable INT;
			SET @GuidesEnable = (SELECT
					COUNT(1)
				FROM #listGuidesEnabled);
			SET @GuidesDisable = (SELECT
					COUNT(1)
				FROM #listGuidesDisabled);

			--------VALIDAR PAGO---------------------------------------------------------
			DECLARE @InTimeP INT;
			DECLARE @IsReturnP BIT;
			IF UPPER(@ServiceType) = 'PICKUP'
			BEGIN
				SET @InTimeP = 2;
				SET @IsReturnP = 'FALSE';
			END;
			ELSE
			IF UPPER(@ServiceType) = 'DELIVERY'
			BEGIN
				SET @InTimeP = 3;
				SET @IsReturnP = 'FALSE';
			END;
			ELSE
			IF @ServiceType = 'RETURN'
			BEGIN
				SET @InTimeP = 3;
				SET @IsReturnP = 'TRUE';
			END;

			CREATE TABLE #PendingPaymentTemp (
				GuideSerie NVARCHAR(25) NULL
			   ,GuideNumber INT
			   ,IsCollect BIT
			   ,Price DECIMAL(14, 2) NULL
			   ,COD DECIMAL(14, 2) NULL
			   ,AmountPaid DECIMAL(14, 2) NULL
			   ,CODPaid DECIMAL(14, 2) NULL
			   ,CODIsPaid BIT
			   ,PaymentTime INT NULL
			   ,TimeSequence INT NULL
			   ,FelNumber NVARCHAR(50) NULL
			   ,IsPaid BIT
			   ,IsCustomer INT NULL
			   ,ConditionPayment VARCHAR(200)
			   ,HaveCredit BIT
			   ,CollectCOD BIT
			   ,ReturnRate DECIMAL(14, 2) NULL
			   ,AmountToPay DECIMAL(14, 2) NULL
			   ,CODAmount DECIMAL(14, 2) NULL
			   ,ReturnRates DECIMAL(14, 2) NULL
			);

			CREATE NONCLUSTERED INDEX IX_PPT_GS ON #PendingPaymentTemp (GuideSerie);
			CREATE NONCLUSTERED INDEX IX_PPT_GN ON #PendingPaymentTemp (GuideNumber);

			INSERT INTO #PendingPaymentTemp (GuideSerie,
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
			AmountToPay,
			CODAmount,
			ReturnRates)
			EXEC DeliveryBackOffice.dbo.spws_get_guide_pending_payment @InGuides = @InGuidesP
																	  ,@InTime = @InTimeP
																	  ,@IsReturn = @IsReturnP
																	  ,@CodeApp = ''
																	  ,@IdModule = @IdModuleP
																	  ,@Token = @TokenP;

			SELECT
				ROW_NUMBER() OVER (ORDER BY ppt.GuideNumber ASC) AS Id
			   ,ppt.GuideSerie
			   ,ppt.GuideNumber
			   ,ppt.IsCollect
			   ,ppt.Price
			   ,ppt.COD
			   ,ppt.AmountPaid
			   ,ppt.CODPaid
			   ,ppt.CODIsPaid
			   ,ppt.PaymentTime
			   ,ppt.TimeSequence
			   ,ppt.FelNumber
			   ,ppt.IsPaid
			   ,ppt.IsCustomer
			   ,ppt.ConditionPayment
			   ,ppt.HaveCredit
			   ,ppt.CollectCOD
			   ,ppt.ReturnRate
			   ,ppt.AmountToPay
			   ,ppt.CODAmount
			   ,ppt.ReturnRates
			   ,CONCAT(
				do.Sender_Department,
				', ',
				do.Sender_Town,
				', ',
				'Zona ',
				do.Sender_Zone,
				', ',
				do.Sender_Address
				) SenderAddress
			   ,CONCAT(
				do.Receiver_Department,
				', ',
				do.Receiver_Town,
				', ',
				'Zona ',
				do.Receiver_Zone,
				', ',
				do.Receiver_Address
				) ReceiverAddress
			   ,IIF(LTRIM(RTRIM(ISNULL(do.Sender_FirstName, ''))) = '',
				LTRIM(RTRIM(ISNULL(do.Sender_LastName, ''))),
				IIF(LTRIM(RTRIM(ISNULL(do.Sender_LastName, ''))) = '',
				LTRIM(RTRIM(do.Sender_FirstName)),
				CONCAT(LTRIM(RTRIM(do.Sender_FirstName)), ' ', LTRIM(RTRIM(do.Sender_LastName))))) SenderName
			   ,CONCAT(
				IIF(LTRIM(RTRIM(ISNULL(do.Receiver_FirstName, ''))) = '',
				LTRIM(RTRIM(ISNULL(do.Receiver_LastName, ''))),
				IIF(LTRIM(RTRIM(ISNULL(do.Receiver_LastName, ''))) = '',
				LTRIM(RTRIM(do.Receiver_FirstName)),
				CONCAT(
				LTRIM(RTRIM(do.Receiver_FirstName)),
				' ',
				LTRIM(RTRIM(do.Receiver_LastName))
				))),
				IIF(LTRIM(RTRIM(ISNULL(do.Receiver_Alternant_FullName, ''))) = '',
				'',
				CONCAT(' / ', LTRIM(RTRIM(do.Sender_FirstName))))
				) ReceiverName
			   ,IIF(UPPER(@ServiceType) = 'DELIVERY',
				LTRIM(RTRIM(ISNULL(do.IndicationsToSendDestination, ''))),
				LTRIM(RTRIM(ISNULL(do.IndicationsToSendOrigin, '')))) Indications
			   ,(ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0)) Pieces
			   ,IIF(do.TypeService = 'EXP', 'NDD', ISNULL(do.TypeService, 'NDD')) ServiceType INTO #PendingPaymentTempId
			FROM #PendingPaymentTemp ppt
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
				ON ppt.GuideSerie = do.Guide_Serie
					AND ppt.GuideNumber = do.Guide_Number;


			DECLARE @TotalAmountBD DECIMAL(18, 2);
			DECLARE @TotalAmountPortal DECIMAL(18, 2);
			SET @TotalAmountBD = (SELECT
					SUM(AmountToPay)
				FROM #PendingPaymentTemp);
			SET @TotalAmountPortal = (SELECT
					SUM(ServiceAmount)
				FROM @TblPayment);

			IF (@TotalAmountBD IS NULL)
			BEGIN
				SET @TotalAmountBD = 0;
			END;

			DECLARE @TotalCODAmountBD DECIMAL(18, 2);
			DECLARE @TotalCODAmountPortal DECIMAL(18, 2);
			DECLARE @Exclude INT;
			SET @TotalCODAmountBD = (SELECT
					SUM(CODAmount)
				FROM #PendingPaymentTemp);
			SET @TotalCODAmountPortal = (SELECT
					SUM(CODAmount)
				FROM @TblPayment);

			SET @Exclude = (SELECT
					COUNT(ExcludeCOD)
				FROM #TblListGuidesTwo
				WHERE ExcludeCOD = 1);

			-- LLAMADO PARA SP SetRecolectionRequest

			IF(@TotalAmount > 0)
			BEGIN

				DECLARE @storevalue INT;

				EXEC @storevalue = DeliveryBackOffice.dbo.SetServiceRecolect @TblDeliveryOrdersList = @TblDeliveryOrdersList,
																	@Iscollected = @Iscollected,
																	@status = @status,
																	@ShipmentCompleted = @ShipmentCompleted,
																	@IdStatus =  @IdStatus,
																	@Token = @TokenP,
																	@IdAccount = @IdAccount,
																	@InstructionsCurrier = @InstructionsCurrier,
																	@PartDimensions = @PartDimensions,
																	@Regularpiezer = @Regularpiezer,
																	@StartDate = @StartDate,
																	@EndDate = @EndDate,
																	@WeightEstimated = @WeightEstimated,
																	@BigPackages = @BigPackages,
																	@ValidateFilter = @ValidateFilter,
																	@RecollectionLatitude = @RecollectionLatitude,
																	@RecollectionLongitude = @RecollectionLongitude,
																	@DeliveryLatitude = @DeliveryLatitude,
																	@DeliveryLongitude = @DeliveryLongitude,
																	@IdUser = @IdUser;

				PRINT 'Valor de storevalue = ' + CAST(@storevalue AS VARCHAR);

				IF(@storevalue = 0)
				BEGIN
					SET @statuscode = 409;
					RAISERROR('Error en la transacción', 16, 1);
				END

			END
			-- FIN LLAMADO PARA SP SetRecolectionRequest

			--IF((SELECT COUNT(1) FROM #listGuidesEnabled2) > 0) --VER GUIAS VALIDAS
			IF (
				((SELECT
						COUNT(1)
					FROM #listGuidesEnabled)
				> 0
				)
				AND ((SELECT
						COUNT(1)
					FROM #listGuidesDisabled)
				<= 0
				)
				)
			BEGIN
				--select @TotalAmountBD
				--select @TotalAmountPortal

				--select @TotalCODAmountBD
				--select @TotalCODAmountPortal

				IF (@TotalAmountBD = @TotalAmountPortal) --VALIDAR SUMAS ServiceAmount
				BEGIN

					IF (
						(
						(@TotalCODAmountBD = @TotalCODAmountPortal)
						AND (@Exclude = 0)
						)
						OR (@Exclude > 0)
						) --VALIDAR SUMAS CODAmount
					BEGIN

						---------TABLA PARA GUIAS INCLUDE--------------------
						CREATE TABLE #TblInclude (
							Guide_Serie VARCHAR(2) NULL
						   ,Guide_Number INT NULL
						   ,ExcludeCOD BIT NULL
						);

						INSERT INTO #TblInclude (Guide_Serie,
						Guide_Number,
						ExcludeCOD)
							SELECT
								tlg.Guide_Serie
							   ,tlg.Guide_Number
							   ,tlg.ExcludeCOD
							FROM #TblListGuidesTwo tlg
							WHERE tlg.ExcludeCOD = 0;

						DECLARE @TotalGuidesInclude DECIMAL(18, 2);
						SET @TotalGuidesInclude = (SELECT
								SUM(pd.CODAmount)
							FROM #PendingPaymentTemp pd
							INNER JOIN #TblInclude ti
								ON pd.GuideNumber = ti.Guide_Number);


						--select * from #PendingPaymentTemp;
						IF (@TotalGuidesInclude IS NULL)
						BEGIN
							SET @TotalGuidesInclude = 0;
						END;
						--select @TotalGuidesInclude as cod;
						--select @TotalCODAmountPortal;
						---------------------------------------------------------
						IF (@TotalGuidesInclude = @TotalCODAmountPortal)
						BEGIN
							DECLARE @VoucherExclude VARCHAR(100);
							DECLARE @ResponsibleExclude VARCHAR(100);

							SET @VoucherExclude = (SELECT TOP 1
									Voucher
								FROM @TblExclusions);
							SET @ResponsibleExclude = (SELECT TOP 1
									Responsible
								FROM @TblExclusions);

							INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail (Guide_Serie,
							Guide_Number,
							StatusOrderId,
							UserCreated,
							DateCreated,
							DateCreatedInSystem,
							Observations)
								SELECT
									lge.Guide_Serie
								   ,lge.Guide_Number
								   ,CASE UPPER(@ServiceType)
										WHEN 'PICKUP' THEN 21
										WHEN 'DELIVERY' THEN 22
										WHEN 'RETURN' THEN 23
									END StatusOrderId
								   ,@TokenP UserCreated
								   ,@DateCreated DateCreated
								   ,@DateCreated DateCreatedInSystem
								   ,CASE UPPER(@ServiceType)
										WHEN 'PICKUP' THEN 'Recibido de ' + @Name
										WHEN 'DELIVERY' THEN 'Entregado a ' + @Name
										WHEN 'RETURN' THEN 'Devueldo a ' + @Name
									END Observations
								--@CUI+'-'+@Name
								FROM #listGuidesEnabled lge;


							UPDATE dot
							SET dot.Observations = 'Entregado a ' + @Name + ', Entrega sin cobro COD '
							+ @VoucherExclude + ' ' + @ResponsibleExclude
							FROM DeliveryOrderDetail dot WITH (NOLOCK)
							INNER JOIN #listGuidesEnabled lge
								ON lge.Guide_Number = dot.Guide_Number
								AND lge.Guide_Serie = dot.Guide_Serie
							WHERE lge.ExcludeCOD = 1
							AND dot.StatusOrderId = 22;








							-------GUARDAR COSTO--------------------
							DECLARE @IdCost INT = 0;
							DECLARE @TotalAmountPaid DECIMAL(12, 2) = 0;
							DECLARE @ProductNumber VARCHAR(25);
							DECLARE @FullPayment DECIMAL(18, 2);
							DECLARE @CODPayment DECIMAL(18, 2);
							DECLARE @Serie VARCHAR(2);
							DECLARE @Number VARCHAR(20);



							-- si no existe insertar registro en tabla cost

							INSERT INTO [dbo].[Cost] ([IdProduct],
							[ProductNumber],
							[IdTypeCharge],
							[TotalAmount],
							[PaymentDate],
							[IdModule],
							[RowStatus],
							[TokenCreated],
							[DateCreated],
							[TotalAmountPaid],
							[CODAmount])
								SELECT
									1 IdProduct
								   ,CONCAT(ti.Guide_Serie, ti.Guide_Number) ProductNumber
								   ,1 IdTypeCharge
								   ,IIF(((pgt.AmountToPay = 0) AND (@ServiceType = 'PICKUP')), NULL, pgt.AmountToPay) TotalAmount
								   ,GETDATE() PaymentDate
								   ,@IdModuleP IdModule
								   ,1 RowStatus
								   ,@TokenP TokenCreated
								   ,GETDATE() DateCreated
								   ,IIF(((pgt.AmountToPay = 0) AND (@ServiceType = 'PICKUP')), NULL, pgt.AmountToPay) TotalAmountPaid
								   ,IIF(((pgt.CODAmount = 0) AND (@ServiceType = 'PICKUP')), NULL, pgt.CODAmount) CODAmount
								FROM #TblInclude ti
								INNER JOIN #PendingPaymentTemp pgt
									ON ti.Guide_Number = pgt.GuideNumber
										AND ti.Guide_Serie = pgt.GuideSerie
								WHERE NOT EXISTS (SELECT
										1
									FROM dbo.Cost ct WITH (NOLOCK)
									WHERE ct.IdProduct = 1
									AND ct.ProductNumber = CONCAT(ti.Guide_Serie, ti.Guide_Number));

							SET @IdCost = SCOPE_IDENTITY();

							UPDATE ct
							SET [PaymentDate] = GETDATE()
							   ,[TokenUpdated] = @TokenP
							   ,[DateUpdated] = GETDATE()
							   ,[TotalAmountPaid] = IIF(((ppt.AmountToPay = 0) AND (@ServiceType = 'PICKUP')),
								NULL,
								ppt.AmountToPay)
							   ,[CODAmount] = IIF(((ppt.CODAmount = 0) AND (@ServiceType = 'PICKUP')),
								NULL,
								ppt.CODAmount)
							FROM Cost ct WITH (NOLOCK)
							INNER JOIN #PendingPaymentTemp ppt
								ON ct.ProductNumber = CONCAT(ppt.GuideSerie, ppt.GuideNumber)
							INNER JOIN #TblInclude ti
								ON ct.ProductNumber = CONCAT(ti.Guide_Serie, ti.Guide_Number)
							WHERE ISNULL(ct.TotalAmountPaid, 0) = 0;


							INSERT INTO [dbo].[CostDetail] ([IdCost],
							[IdTypeOfMoney],
							[Amount],
							[Voucher],
							[RowStatus],
							[TokenCreated],
							[DateCreated],
							[Responsible])
								SELECT
									IdCost
								   ,@IdTypeOfMoney
								   ,@Amount
								   ,@Voucher
								   ,1
								   , -- crear registro activo por default
									@TokenP
								   ,GETDATE()
								   ,@Responsible
								FROM Cost ct WITH (NOLOCK)
								INNER JOIN #TblInclude ti
									ON ct.ProductNumber = CONCAT(ti.Guide_Serie, ti.Guide_Number);

							-----------------------------------------
							----INSERTAR REGISTRO EN ProcessGuideCOD CUANDO SEA ENTREGA Y SEA COD---------
							IF (UPPER(@ServiceType) = 'DELIVERY')
							BEGIN

								UPDATE do
								SET do.Collect_OnDelivery = 0
								   ,do.LastCollectOnDelivery = ppt.CODAmount
								FROM DeliveryOrder do
								INNER JOIN #listGuidesEnabled lge
									ON lge.Guide_Number = do.Guide_Number
									AND lge.Guide_Serie = do.Guide_Serie
								INNER JOIN #PendingPaymentTemp ppt
									ON ppt.GuideNumber = do.Guide_Number
									AND ppt.GuideSerie = do.Guide_Serie
								WHERE lge.ExcludeCOD = 1;


								INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD (GuideSerie,
								GuideNumber,
								DataOriginId,
								Token,
								CustomerID)
									SELECT
										lge.Guide_Serie
									   ,lge.Guide_Number
									   ,25
									   ,@TokenP UserCreated
									   ,cus.IdCustomer
									FROM #listGuidesEnabled lge
									INNER JOIN DeliveryOrder dlo WITH (NOLOCK)
										ON lge.Guide_Number = dlo.Guide_Number
									LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
										ON vp.CodeOfReference = dlo.Sender_ID
									LEFT JOIN dbo.Customer cus WITH (NOLOCK)
										ON cus.IdCustomer = ISNULL(dlo.IdCustomer, vp.CustomerID)
									LEFT JOIN ProcessedGuideCOD pcd WITH (NOLOCK)
										ON pcd.GuideSerie = dlo.Guide_Serie
											AND pcd.GuideNumber = dlo.Guide_Number
									WHERE dlo.Collect_OnDelivery > 0
									AND pcd.IdProcessedGuideCOD IS NULL
									
									
									--COLLECT--
									DECLARE @CatBatchIdCollect AS INT = (SELECT
											IdCatBatch
										FROM CatBatch
										WHERE [CatName] = 'COLLECT'
										AND RowStatus = 1) --HW-110
									
									INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideBatch (GuideSerie,
								GuideNumber,
								DataOriginId,
								Token,
								CustomerID,
								CatBatchId)
									SELECT
										lge.Guide_Serie
									   ,lge.Guide_Number
									   ,25
									   ,@TokenP UserCreated
									   ,cus.IdCustomer
									   ,@CatBatchIdCollect
									FROM #listGuidesEnabled lge
									INNER JOIN DeliveryOrder dlo WITH (NOLOCK)
										ON lge.Guide_Serie = dlo.Guide_Serie
											AND lge.Guide_Number = dlo.Guide_Number
									LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
										ON vp.CodeOfReference = dlo.Sender_ID
									LEFT JOIN dbo.Customer cus WITH (NOLOCK)
										ON cus.IdCustomer = ISNULL(dlo.IdCustomer, vp.CustomerID)
									LEFT JOIN ProcessedGuideBatch pcd WITH (NOLOCK)
										ON pcd.GuideSerie = dlo.Guide_Serie
											AND pcd.GuideNumber = dlo.Guide_Number
											AND pcd.CatBatchId = @CatBatchIdCollect AND pcd.RowStatus = 1
									WHERE 
									dlo.Collect_OnDelivery = 0
									AND 
									dlo.IsCollect = 'true'
									AND NOT EXISTS (SELECT
											1
										FROM DeliveryBackOffice.dbo.Cost C WITH (NOLOCK)
										JOIN CostDetail CD WITH (NOLOCK)
											ON CD.IdCost = C.IdCost
											AND CD.IdTypeOfMoney IN (2, 6)
										WHERE C.ProductNumber = CONCAT(dlo.Guide_Serie, CAST(dlo.Guide_Number AS VARCHAR(50))))
									AND pcd.IdProcessedGuideBatch IS NULL
							END;

							UPDATE do
							SET do.StatusOrderId = (CASE UPPER(@ServiceType)
								WHEN 'PICKUP' THEN 21
								WHEN 'DELIVERY' THEN 22
								WHEN 'RETURN' THEN 23
							END
							)
							FROM DeliveryOrder do
							INNER JOIN #listGuidesEnabled lge
								ON lge.Guide_Number = do.Guide_Number
								AND lge.Guide_Serie = do.Guide_Serie;

							UPDATE dop
							SET StatusOrderId = (CASE UPPER(@ServiceType)
								WHEN 'PICKUP' THEN 21
								WHEN 'DELIVERY' THEN 22
								WHEN 'RETURN' THEN 23
							END
							)
							FROM DeliveryOrderPiece dop
							INNER JOIN #listGuidesEnabled lge
								ON lge.Guide_Number = dop.GuideNumber
								AND lge.Guide_Serie = dop.GuideSerie;

							IF (UPPER(@ServiceType) = 'PICKUP')
							BEGIN

										DECLARE @CatBatchId AS INT = (SELECT
											IdCatBatch
										FROM CatBatch
										WHERE [CatName] = 'RECOLECCION'
										AND RowStatus = 1) --HW-110

								UPDATE do
								SET do.Collect_OnDelivery = 0
								   ,do.LastCollectOnDelivery = ppt.CODAmount
								FROM DeliveryOrder do 
								INNER JOIN #listGuidesEnabled lge
									ON lge.Guide_Number = do.Guide_Number
									AND lge.Guide_Serie = do.Guide_Serie
								INNER JOIN #PendingPaymentTemp ppt
									ON ppt.GuideNumber = do.Guide_Number
									AND ppt.GuideSerie = do.Guide_Serie
								WHERE lge.ExcludeCOD = 1;


								INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideBatch (GuideSerie,
								GuideNumber,
								DataOriginId,
								Token,
								CustomerID,
								CatBatchId	)
									SELECT
										lge.Guide_Serie
									   ,lge.Guide_Number
									   ,25
									   ,@TokenP UserCreated
									   ,cus.IdCustomer
									   ,@CatBatchId
									FROM #listGuidesEnabled lge
									INNER JOIN DeliveryOrder dlo WITH (NOLOCK)
										ON lge.Guide_Number = dlo.Guide_Number
									INNER JOIN dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
										ON dlo.Guide_Serie = DOP.GuideSerie
											AND dlo.Guide_Number = DOP.GuideNumber
									LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
										ON vp.CodeOfReference = dlo.Sender_ID
									LEFT JOIN dbo.Customer cus WITH (NOLOCK)
										ON cus.IdCustomer = ISNULL(dlo.IdCustomer, vp.CustomerID)
									LEFT JOIN ProcessedGuideBatch pcd WITH (NOLOCK)
										ON pcd.GuideSerie = dlo.Guide_Serie
											AND pcd.GuideNumber = dlo.Guide_Number 
											AND cus.RowSatus = 1 
											AND pcd.CatBatchId = @CatBatchId
									WHERE (
									--dlo.Collect_OnDelivery = 0
									--AND 
									dlo.IsCollect = 'false'
									AND DOP.PayTypeId = 1
									AND (DOP.TimePlaId = 1
									OR DOP.TimePlaId = 2)
									AND DOP.TypeofInOutMoneyId = 1)
									AND NOT EXISTS (SELECT
											1
										FROM DeliveryBackOffice.dbo.Cost C WITH (NOLOCK)
										JOIN CostDetail CD WITH (NOLOCK)
											ON CD.IdCost = C.IdCost
											AND CD.IdTypeOfMoney IN (2, 6)
										WHERE C.ProductNumber = CONCAT(dlo.Guide_Serie, CAST(dlo.Guide_Number AS VARCHAR(50))))
									AND pcd.IdProcessedGuideBatch IS NULL

							END;
							----fin PROCESSEDGUIDECOD---

							DECLARE @OutSize2 INT;
							DECLARE @OutPrueba2 VARCHAR(MAX);
							SET @OutPrueba2
							= '[ { ' + '"Guides": [ '
							+ (SELECT
									STUFF((SELECT
											' { "Guide": "'
											+ CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR))
											+ '", '
											+
											'"Status": ' + CAST(@statuscode AS VARCHAR) + ', ' +
											--'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
											--'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
											'"StatusOrderId": '
											+ CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', '
											+ '"StatusOrderDescription": "' + lge.StatusOrderDescription
											+ '" }, '
										FROM #listGuidesEnabled lge
										FOR XML PATH (''))
									,
									1,
									1,
									''
									));

							--PRINT(@OutPrueba);
							SET @OutSize2 = LEN(@OutPrueba2) - 1;
							PRINT (@OutSize2);
							DECLARE @FINAL2 VARCHAR(MAX);
							SET @FINAL2 = (SELECT
									SUBSTRING(@OutPrueba2, 1, @OutSize2));

							SET @Output
							= @FINAL2 + '], ' + '"Client": [ '
							+ (SELECT
									STUFF((SELECT
											' { "CUI": "' + @CUI + '", '
											+
											--'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
											--'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
											'"Name": "' + @Name + '" }, '
										FOR XML PATH (''))
									,
									1,
									1,
									''
									))
							+ '] } ]';

							SET @Output
							= SUBSTRING(@Output, 1, (LEN(@Output) - 7))
							+ SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

							SELECT
								@Output FormatJson;

						END;
						ELSE
						BEGIN
							SET @Output
							= '[ { ' + '"Rejects": [ '
							+ (SELECT
									STUFF((SELECT
											' {"StatusOrderDescription": "'
											+ ('La suma de las guias no coincide con el monto de pago.')
											+ '" }, '
										FOR XML PATH (''))
									,
									1,
									1,
									''
									))
							+ '] } ]';

							SET @Output
							= SUBSTRING(@Output, 1, (LEN(@Output) - 7))
							+ SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

							SELECT
								@Output FormatJson;
						END;

					END;


					ELSE --VALIDAR SUMAS CODAmount
					BEGIN
						SET @Output
						= '[ { ' + '"Rejects": [ '
						+ (SELECT
								STUFF((SELECT
										' {"StatusOrderDescription": "'
										+ ('La suma de las guias no coincide con el monto de pago.')
										+ '" }, '
									FOR XML PATH (''))
								,
								1,
								1,
								''
								))
						+ '] } ]';

						SET @Output
						= SUBSTRING(@Output, 1, (LEN(@Output) - 7))
						+ SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

						SELECT
							@Output FormatJson;
					END;

				END;

				ELSE
				IF ((SELECT
							COUNT(1)
						FROM #listGuidesNotExist)
					> 0)
				BEGIN
					SET @Output
					= '[ { ' + '"Rejects": [ '
					+ (SELECT
							STUFF((SELECT
									' { "Guide": "'
									+ CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR)) + '", ' +
									--'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
									--'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
									'"StatusOrderId": ' + ('-1') + ', ' + '"Description": "'
									+ (lge.Description) + '" }, '
								FROM #listGuidesNotExist lge
								FOR XML PATH (''))
							,
							1,
							1,
							''
							))
					+ '] } ]';

					SET @Output
					= SUBSTRING(@Output, 1, (LEN(@Output) - 7))
					+ SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));
					SELECT
						@Output FormatJson;

				END;

				ELSE
				IF ((@GuidesEnable > 0)
					AND (@GuidesDisable > 0))
				BEGIN
					DECLARE @OutSize INT;
					DECLARE @OutPrueba VARCHAR(MAX);
					SET @OutPrueba
					= '[ { ' + '"Guides": [ '
					+ (SELECT
							STUFF((SELECT
									' { "Guide": "'
									+ CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR)) + '", ' 
									+
									'"Status": ' + CAST(@statuscode AS VARCHAR) + ', ' +
									--'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
									--'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
									'"StatusOrderId": ' + CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', '
									+ '"StatusOrderDescription": "' + lge.StatusOrderDescription + '" }, '
								FROM #listGuidesEnabled lge
								FOR XML PATH (''))
							,
							1,
							1,
							''
							));

					PRINT (@OutPrueba);
					SET @OutSize = LEN(@OutPrueba) - 1;
					PRINT (@OutSize);
					DECLARE @FINAL VARCHAR(MAX);
					SET @FINAL = (SELECT
							SUBSTRING(@OutPrueba, 1, @OutSize));

					SET @Output
					= @FINAL + '], ' + '"Rejects": [ '
					+ (SELECT
							STUFF((SELECT
									' { "Guide": "'
									+ CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR)) + '", ' +
									--'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
									--'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
									'"StatusOrderId": ' + CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', '
									+ '"StatusOrderDescription": "' + lge.StatusOrderDescription + '" }, '
								FROM #listGuidesDisabled lge
								FOR XML PATH (''))
							,
							1,
							1,
							''
							))
					+ '] } ]';

					SET @Output
					= SUBSTRING(@Output, 1, (LEN(@Output) - 7))
					+ SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

					SELECT
						@Output FormatJson;
				END;

				ELSE
				BEGIN
					SET @Output
					= '[ { ' + '"Rejects": [ '
					+ (SELECT
							STUFF((SELECT
									' {"StatusOrderDescription": "'
									+ ('La suma de las guias no coincide con el monto de pago.') + '" }, '
								FOR XML PATH (''))
							,
							1,
							1,
							''
							))
					+ '] } ]';

					SET @Output
					= SUBSTRING(@Output, 1, (LEN(@Output) - 7))
					+ SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

					SELECT
						@Output FormatJson;
				END;


			-----------------------------------------------------------------------------------------------------	
			END; --VER GUIAS VALIDAS
			ELSE
			IF (
				((SELECT
						COUNT(1)
					FROM #listGuidesEnabled)
				> 0
				)
				AND ((SELECT
						COUNT(1)
					FROM #listGuidesDisabled)
				> 0
				)
				)
			BEGIN
				DECLARE @OutSizee INT;
				DECLARE @OutPruebaa VARCHAR(MAX);
				SET @OutPruebaa
				= '[ { ' + '"Guides": [ '
				+ (SELECT
						STUFF((SELECT
								' { "Guide": "'
								+ CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR)) + '", ' 
								+
								'"Status": ' + CAST(@statuscode AS VARCHAR) + ', ' +
								--'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
								--'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
								'"StatusOrderId": ' + CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', '
								+ '"StatusOrderDescription": "' + lge.StatusOrderDescription + '" }, '
							FROM #listGuidesEnabled lge
							FOR XML PATH (''))
						,
						1,
						1,
						''
						));

				SET @OutSizee = LEN(@OutPruebaa) - 1;
				DECLARE @FINALL VARCHAR(MAX);
				SET @FINALL = (SELECT
						SUBSTRING(@OutPruebaa, 1, @OutSizee));

				SET @Output
				= @FINALL + '], ' + '"Rejects": [ '
				+ (SELECT
						STUFF((SELECT
								' { "Guide": "'
								+ CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR)) + '", ' +
								--'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
								--'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
								'"StatusOrderId": ' + CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', '
								+ '"StatusOrderDescription": "' + lge.StatusOrderDescription + '" }, '
							FROM #listGuidesDisabled lge
							FOR XML PATH (''))
						,
						1,
						1,
						''
						))
				+ '] } ]';

				SET @Output
				= SUBSTRING(@Output, 1, (LEN(@Output) - 7)) + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

				SELECT
					@Output FormatJson;


			END;

			ELSE
			IF ((SELECT
						COUNT(1)
					FROM #listGuidesDisabled)
				> 0)
			BEGIN
				SET @Output
				= '[ { ' + '"Rejects": [ '
				+ (SELECT
						STUFF((SELECT
								' { "Guide": "'
								+ CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR)) + '", ' +
								--'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
								--'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
								'"StatusOrderId": ' + CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', '
								+ '"StatusOrderDescription": "' + lge.StatusOrderDescription + '" }, '
							FROM #listGuidesDisabled lge
							FOR XML PATH (''))
						,
						1,
						1,
						''
						))
				+ '] } ]';

				SET @Output
				= SUBSTRING(@Output, 1, (LEN(@Output) - 7)) + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

				SELECT
					@Output FormatJson;

			END;

			IF @TranCounter = 0  
			BEGIN
				-- @TranCounter = 0 means no transaction was  
				-- started before the procedure was called.  
				-- The procedure must commit the transaction  
				-- it started.  
				COMMIT TRANSACTION;
			END

			--Valor para validar la transacción si es llamado por otro SP
			RETURN 1;

		END TRY
		BEGIN CATCH

			SELECT
				'ERROR' AS message
			   ,'FALSE' blnResult
			   ,CAST(500 AS VARCHAR(5)) StatusResult
			   ,CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber
			   ,CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity
			   ,CAST(ERROR_STATE() AS VARCHAR) AS ErrorState
			   ,CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure
			   ,CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine
			   ,CAST(ERROR_MESSAGE() AS VARCHAR(100)) AS ResultMessage;


			-- Error si alguna guía no existe
			IF OBJECT_ID('tempdb.dbo.#listGuidesNotExist') IS NOT NULL
			BEGIN
				SET @Output
				= '[ { ' + '"Rejects": [ '
				+ (SELECT
						STUFF((SELECT
								' { "Guide": "' + CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR))
								+ '", ' +
								--'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
								--'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
								'"StatusOrderId": ' + ('-1') + ', ' + '"Description": "' + (lge.Description)
								+ '" }, '
							FROM #listGuidesNotExist lge
							FOR XML PATH (''))
						,
						1,
						1,
						''
						))
				+ '] } ]';

				SET @Output
				= SUBSTRING(@Output, 1, (LEN(@Output) - 7)) + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));
				SELECT
					@Output FormatJson;
			END

			-- Error si la transacción en la tabla DeliveryOrderPaymentTransaction falla
			ELSE
			BEGIN
				SET @Output
				= '{"Status":"Error en la transacción"}';

				SELECT
					@Output FormatJson;
			END


			IF @TranCounter = 0  
			BEGIN
				PRINT '=====> ROLLBACK ';
				-- Transaction started in procedure.  
				-- Roll back complete transaction.  
				ROLLBACK TRANSACTION;  
			END
			ELSE  
			BEGIN
				-- Transaction started before procedure  
				-- called, do not roll back modifications  
				-- made before the procedure was called.  
				IF XACT_STATE() <> -1  
				BEGIN
				PRINT '=====> ROLLBACK FinishService';
				-- If the transaction is still valid, just  
				-- roll back to the savepoint set at the  
				-- start of the stored procedure.  
					ROLLBACK TRANSACTION FinishService;  
				-- If the transaction is uncommitable,			
				END
			END

			--Valor para validar la transacción si es llamado por otro SP
			RETURN 0;

		END CATCH;

	END;
END;