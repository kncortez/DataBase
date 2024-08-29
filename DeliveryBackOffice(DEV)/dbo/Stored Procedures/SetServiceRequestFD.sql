
CREATE PROCEDURE [dbo].[SetServiceRequestFD]
@TblServiceRequestFD AS TblServiceRequest READONLY,	
@TblDeliveryOrdersFD AS TblDeliveryOrdersFD READONLY,
@VisitPointByClientPortfolioId BIGINT = 0,
@UserAddressId BIGINT = 0,
@SystemModule NVARCHAR(200) = NULL,
@IdAccount BIGINT = NULL,
@AddToServiceCart BIT = 0
AS
BEGIN
	DECLARE @IdTransaction BIGINT = NULL
	DECLARE @ManifestNumber INT = 0
	DECLARE @ManifestSerie VARCHAR(2) = 'FM'
	DECLARE @GuideSerie VARCHAR(2) = 'FD'


	-- MODIFICACION 16/02/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	DECLARE @CustomerID int = (SELECT [CustomerID] FROM @TblServiceRequestFD)
	--FIN MODIFICACIÓN
	DECLARE @StatusPackage INT = (SELECT IdCatSalesPackageStatus FROM CatSalesPackageStatus WHERE SalesPackageStatusName = 'Activa')
  IF(@VisitPointByClientPortfolioId = 0)
  BEGIN
  SET @VisitPointByClientPortfolioId = NULL;
  END

  IF(@UserAddressId = 0)
  BEGIN
  SET @UserAddressId = NULL;
  END
  
  DECLARE @system INT = NULL;
  DECLARE @module INT = NULL;

  IF (@SystemModule != '') 
  BEGIN
  --Se almacena el sistema y modulo desde donde se crea una guía
		SET @system = (
						SELECT SysIdSystem from CatSystem ca
						WHERE ca.SysNameSystem = (SELECT item FROM dbo.SplitUnlimited(@SystemModule, '/') 
						WHERE id = 1)
					   );

		-- Se deja la sentencia TOP 1 ya que existe dos modulos con el mismo nombre para la creación de guías en porta Web
		-- Crear guías para usuarios individuales/Express y Crear Guías para corporativos en el flujo normal
		SET @module = (
						SELECT TOP 1 mo.ModIdModule from CatModule mo
						WHERE mo.ModName = (SELECT item FROM dbo.SplitUnlimited(@SystemModule, '/')
						WHERE id = 2)
					   );
  END

	/*********************************************************************************************/
	/******** LLEVA EL CONTROL DE FILAS Y CORRELATIVOS AUTO GENERADOS PARA ESTA SOLICITUD ********/
	/*********************************************************************************************/
	DECLARE @CorrelativeTable AS TABLE(
		[Row_Number][int] IDENTITY(1,1), -- no de fila
		[Guide_Number] [int] NULL -- correlativo autogenerado
	)
	BEGIN TRANSACTION
	BEGIN TRY
		/*********************************************************************************************/
		/******** AUTO GENERACIÓN DE CORRELATIVOS BASADOS EN LA CANTIDAD DE REGISTOS RECIBIDOS *******/
		/*********************************************************************************************/
		DECLARE @noRecords INT = (SELECT COUNT(RowNumber) FROM @TblDeliveryOrdersFD)
		DECLARE @startnum INT = (SELECT MAX([Guide_Number]) + 1 FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] WITH(NOLOCK))
		DECLARE @endnum INT = (@startnum - 1) + @noRecords
		;WITH gen AS (
			SELECT @startnum AS num
			UNION ALL
			SELECT num+1 FROM gen WHERE num+1<=@endnum
		)
		INSERT INTO @CorrelativeTable 
		(
			Guide_Number
		)
		SELECT 
			NEXT VALUE FOR [dbo].[NewGuideNumberSequence]
		FROM gen
		option (maxrecursion 10000)
		/*****************************************************************************************************************************/
		/******** TABLA TEMPORAL #GUIDETABLE PARA UNIR REGISTROS RECIBIDOS DE DELIVERYORDERS Y CORRELATIVOS AUTOGENERADOS ************/
		/*****************************************************************************************************************************/
		SELECT 
			[RowNumber],
			[Ticket_Number],
			[Order_Number],
			[Preparation_Date],
			[Shipping_Date],
			[Pieces_Dry],
			[Pieces_Cold],
			[Consolidated_Number],
			[Recipe_Number],
			[Sender_ID],
			[Sender_FirstName],
			[Sender_LastName],
			[Sender_Address],
			[Sender_Zone],
			[Sender_Town],
			[Sender_Department],
			[Sender_Phone],
			[Receiver_ID],
			[Receiver_FirstName],
			[Receiver_LastName],
			[Receiver_Address],
			[Receiver_Zone],
			[Receiver_Town],
			[Receiver_Department],
			[Receiver_Phone],
			[Receiver_Email],
			[Receiver_SocialSecurity_ID],
			[Receiver_Alternant_ID],
			[Receiver_Alternant_FullName],
			[Receiver_Alternant_Address],
			[Receiver_Alternant_Zone],
			[Receiver_Alternant_Town],
			[Receiver_Alternant_Department],
			[Receiver_Alternant_Phone],
			[Receiver_Alternant_Email],
			[Receiver_Alternant_SocialSecurity_ID],
			[Delivery_Max_Date],
			[printedStatus],
			@GuideSerie AS 'Guide_Serie',
			C.Guide_Number AS 'Guide_Number',
			@ManifestSerie AS Manifest_Serie, 
			@ManifestNumber AS Manifest_Number,
			[StatusOrderId],
			[Receiver_CUI],
			[Package_Description],
			[Sender_Internal_Code],
			[Receiver_Alternant_CUI],
			[Collect_OnDelivery],
			[IsCollect],
			[PriceShippment] ,
			[SenderIdTownship],
			[ReceiverIdTownship],
			[Sender_Lat],
			[Sender_Lng],
			[ReceiverLatitude],
			[ReceiverLongitude]
		INTO #GuideTable
		FROM @TblDeliveryOrdersFD
		LEFT JOIN @CorrelativeTable C ON C.[Row_Number] = RowNumber

		CREATE NONCLUSTERED INDEX IX_TempTest_SerieNumber ON #GuideTable(Guide_Serie, Guide_Number);
		CREATE NONCLUSTERED INDEX IX_TempTest_ReceiverIdTownship ON #GuideTable(ReceiverIdTownship);
			CREATE NONCLUSTERED INDEX IX_TempTest_SenderID ON #GuideTable(Sender_ID);
			CREATE NONCLUSTERED INDEX IX_TempTest_Receiver_ID ON #GuideTable(Receiver_ID);

		/**********************************************************************/
		/******** INSERCIÓN DE ÚNICO REGISTRO PARA TABLA DE MANIFIESTO ********/
		/**********************************************************************/
		SET @ManifestNumber = NEXT VALUE FOR [dbo].[NewGuideManifestSequence]; 

		INSERT INTO DeliveryBackOffice.dbo.ServiceRequest (
			[Messageid], 
			[Receiver_Name], 
			[Receiver_Email], 
			[PathReceivedFile], 
			[PathSticker], 
			[Status], 
			[Receiver_Date], 
			[DateCreated], 
			[Manifest_Serie], 
			[Manifest_Number],
			[CustomerID]
		)
		SELECT 
			[Messageid], 
			[Receiver_Name],
			[Receiver_Email], 
			[PathReceivedFile], 
			[PathSticker], 
			[Status], 
			[Receiver_Date], 
			[DateCreated],
			@ManifestSerie,
			@ManifestNumber,
			[CustomerID]
		FROM @TblServiceRequestFD

		/**********************************************************************/
		/*********** GUARDAR ÓRDENES ASOCIADAS (GUÍAS ELECTRÓNICAS) ***********/
		/**********************************************************************/

		INSERT DeliveryBackOffice.dbo.DeliveryOrder (
			[Ticket_Number],
			[Order_Number],
			[Preparation_Date],
			[Shipping_Date],
			[Pieces_Dry],
			[Pieces_Cold],
			[Consolidated_Number],
			[Recipe_Number],
			[Sender_ID],
			[Sender_FirstName],
			[Sender_LastName],
			[Sender_Address],
			[Sender_Zone],
			[Sender_Town],
			[Sender_Department],
			[Sender_Phone],
			[Receiver_ID],
			[Receiver_FirstName],
			[Receiver_LastName],
			[Receiver_Address],
			[Receiver_Zone],
			[Receiver_Town],
			[Receiver_Department],
			[Receiver_Phone],
			[Receiver_Email],
			[Receiver_SocialSecurity_ID],
			[Receiver_Alternant_ID],
			[Receiver_Alternant_FullName],
			[Receiver_Alternant_Address],
			[Receiver_Alternant_Zone],
			[Receiver_Alternant_Town],
			[Receiver_Alternant_Department],
			[Receiver_Alternant_Phone],
			[Receiver_Alternant_Email],
			[Receiver_Alternant_SocialSecurity_ID],
			[Delivery_Max_Date],
			[printedStatus],
			[Guide_Serie],
			[Guide_Number],
			[Manifest_Serie],
			[Manifest_Number],
			[DateCreated],
			[StatusOrderId],
			[Receiver_CUI],
			[Package_Description],
			[Sender_Internal_Code],
			[Receiver_Alternant_CUI],
			[Courier_Route],
			[Courier_Name],
			[Courier_Vehicle_Plate],
			[Dispatched_Date],
			[Dispatched_Token],
			[Collect_OnDelivery],
			[Guide_Collected],
			[IsCollect],
			[PriceShippment],
			[SenderIdTownship],
			[ReceiverIdTownship],
			[VisitpointClientPortfolioId],
			[UserAddressId],
			[Sender_Lat],
			[Sender_Lng],
			[CatSystemId],
			[CatModuleId],
			[Receiver_Lat],
			[Receiver_Lng],
			[SenderCountryId],
			[ReceiverCountryId],
			[GuideType]
		)
		SELECT 
			GT.[Ticket_Number],
			GT.[Order_Number],
			GT.[Preparation_Date],
			GT.[Shipping_Date],
			GT.[Pieces_Dry],
			GT.[Pieces_Cold],
			GT.[Consolidated_Number],
			GT.[Recipe_Number],
			GT.[Sender_ID],
			GT.[Sender_FirstName],
			GT.[Sender_LastName],
			GT.[Sender_Address],
			GT.[Sender_Zone],
			GT.[Sender_Town],
			GT.[Sender_Department],
			GT.[Sender_Phone],
			GT.[Receiver_ID],
			GT.[Receiver_FirstName],
			GT.[Receiver_LastName],
			GT.[Receiver_Address],
			GT.[Receiver_Zone],
			GT.[Receiver_Town],
			GT.[Receiver_Department],
			GT.[Receiver_Phone],
			GT.[Receiver_Email],
			GT.[Receiver_SocialSecurity_ID],
			GT.[Receiver_Alternant_ID],
			GT.[Receiver_Alternant_FullName],
			GT.[Receiver_Alternant_Address],
			GT.[Receiver_Alternant_Zone],
			GT.[Receiver_Alternant_Town],
			GT.[Receiver_Alternant_Department],
			GT.[Receiver_Alternant_Phone],
			GT.[Receiver_Alternant_Email],
			GT.[Receiver_Alternant_SocialSecurity_ID],
			GT.[Delivery_Max_Date],
			GT.[printedStatus],
			GT.Guide_Serie,
			GT.Guide_Number,
			@ManifestSerie, 
			@ManifestNumber,
			GETDATE(),
			GT.StatusOrderId,
			GT.Receiver_CUI,
			GT.Package_Description,
			GT.Sender_Internal_Code,
			GT.Receiver_Alternant_CUI,
			NULL, -- Courier_Route,
			NULL, -- Courier_Name,
			NULL, -- Courier_Vehicle_Plate,
			NULL, -- Dispatched_Date,
			NULL, -- Dispatched_Token,
			GT.Collect_OnDelivery, -- Collect_OnDelivery
			0, -- Guide_Collected,
			GT.IsCollect,
			GT.PriceShippment,
			GT.SenderIdTownship,
			GT.ReceiverIdTownship,
				
			@VisitPointByClientPortfolioId,
			@UserAddressId,
			GT.Sender_Lat,
			GT.Sender_Lng,
			@system,
			@module,
			GT.ReceiverLatitude,
			GT.ReceiverLongitude,
			ISNULL(P.IdCountry,'GT'),
			ISNULL(P2.IdCountry,'GT'),
			CASE
				WHEN ISNULL(P.IdCountry,'GT') = ISNULL(P2.IdCountry,'GT') THEN 'DOM'
				ELSE 'INT'
			END AS GuideType
		FROM #GuideTable GT
		INNER JOIN DeliveryBackOffice.dbo.Township T ON GT.SenderIdTownship = T.IdTownship
		INNER JOIN DeliveryBackOffice.dbo.Province P ON T.IdProvince = P.IdProvince
		INNER JOIN DeliveryBackOffice.dbo.Township T2 ON GT.ReceiverIdTownship = T2.IdTownship
		INNER JOIN DeliveryBackOffice.dbo.Province P2 ON T2.IdProvince = P2.IdProvince
			
		-- MODIFICACION 17/09/2021 JOSE ANDRES RUIZ PEER
		-- INSERTAR DATA PARA MANEJO DE LANDING PAGE
		INSERT INTO [DeliveryBackOffice].[dbo].[ServiceDataForGuide](
			[GuideSerie],
			[GuideNumber],
			[GuideToken],
			[IsDelivery],
			[RowStatus],
			[TokenCreated],
			[DateCreated])
		SELECT 
			GT.Guide_Serie,
			GT.Guide_Number,
			CONCAT( GT.Guide_Serie, CAST(GT.Guide_Number AS NVARCHAR) , RIGHT ('00000'+CAST( (FLOOR(RAND()*(99999-0+1))+0) AS NVARCHAR),5)),
			1,
			1,
			'SYS-HERMESROUTES',
			GETDATE()
		FROM #GuideTable GT
		WHERE NOT EXISTS (
			SELECT 1
			FROM [DeliveryBackOffice].[dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
			WHERE GT.Guide_Serie = SDFG.GuideSerie
			AND GT.Guide_Number = SDFG.GuideNumber
			AND SDFG.IsDelivery = 1
		);
		-- FIN DE MODIFICACION
			
		-- FDAPI-1418 Oscar Morales 2023-02-23
		-- Insertar data para manejo de inténtos de entrega/devolución
		INSERT INTO [dbo].[DeliveryOrderAttemptData] ([GuideSerie]
		, [GuideNumber]
		, [GuideDeliveryAttemptCount]
		, [GuideDeliveryMaxAttemptCount]
		, [GuideReturnAttemptCount]
		, [GuideReturnMaxAttemptCount]
		, [RowStatus]
		, [DateCreated]
		, [TokenCreated]
		, [DateUptaded]
		, [TokenUpdated])
			SELECT
				GT.Guide_Serie
			   ,GT.Guide_Number
			   ,0
			   ,rh.Attempt
			   ,0
			   ,rh.AttemptReturn
			   ,1
			   ,GETDATE()
			   ,'SYSTEM'
			   ,NULL
			   ,NULL
			FROM #GuideTable GT
			INNER JOIN RateByCustomer rc WITH (NOLOCK)
				ON rc.RbcId = (SELECT TOP 1
							rbc.RbcId
						FROM RatebyCustomer rbc WITH (NOLOCK)
						INNER JOIN VisitPointClient vpc WITH (NOLOCK)
							ON GT.Sender_ID = vpc.CodeOfReference
						WHERE ISNULL(@CustomerID, vpc.CustomerID) = rbc.RbcIdCustomer
						AND rbc.RbcRowStatus = 1
						AND (rbc.RbcCodeOfReference = vpc.CodeOfReference
						OR rbc.RbcCodeOfReference IS NULL)
						ORDER BY rbc.RbcCodeOfReference DESC)
			INNER JOIN RateHeader rh WITH (NOLOCK)
				ON rc.RbcIdRate = rh.RheId
        -- Fin FDAPI-1418 Oscar Morales 2023-02-23


		--INSERTAR DETALLE DE PAGO PARA LAS GUÍAS DE CONCESIONARIO
					DECLARE @TypeClient INT;
					SET @TypeClient = (SELECT TOP 1 IdKindOfVPClient FROM VisitPointClient WITH (NOLOCK) WHERE CustomerID = @CustomerID)

					IF(@TypeClient = 3)
						BEGIN
						DECLARE @IdCost INT;
						DECLARE @IsCollect BIT;
						DECLARE @Token VARCHAR (100);
						DECLARE @IdUser VARCHAR (10);
						DECLARE @Username VARCHAR (50);
						DECLARE @Email VARCHAR(100);

						SET @Email = (SELECT TOP 1 Receiver_Email FROM #GuideTable)
						SELECT TOP 1 @IdUser = USR_IdUser,
									 @Username = USR_Username
						FROM DenariusUser_Dev.dbo.LGN_User WITH (NOLOCK)
								WHERE USR_Email = @Email

						SET @Token = (SELECT TOP 1 SSN_IdToken FROM DenariusUser_Dev.dbo.LGN_LogByToken WITH (NOLOCK)
								WHERE SSN_IdUser = @IdUser
								AND SSN_Username = @Username
								AND SSN_TokenStatus = 1
								ORDER BY SSN_DateLogin desc)

								IF(@Token IS NULL)
									BEGIN
									 SET @Token = 'Concesionario';
									END

							SET @IsCollect =(SELECT TOP 1 IsCollect FROM #GuideTable)
							IF(@IsCollect = 1)
								BEGIN
									INSERT INTO DeliveryOrderPaymentDetail (GuideNumber, GuideSerie, PayTypeId, TypeofInOutMoneyId, TimePlaId, amount, TokenCreated, DateCreated)
									SELECT GIT.Guide_Number,
										   GIT.Guide_Serie,
										   2,
										   1,
										   3,
										   GIT.PriceShippment,
										   @Token,
										   GETDATE()
									FROM #GuideTable GIT

									--INSERT INTO Cost (IdProduct, ProductNumber, IdTypeCharge, TotalAmount, RowStatus, TokenCreated, DateCreated, GuideSerie, GuideNumber )
									--SELECT 1,
									--	   GDT.Guide_Serie+CAST(GDT.Guide_Number AS VARCHAR),
									--	   1,
									--	   GDT.PriceShippment,
									--	   1,
									--	   @Token,
									--	   GETDATE(),
									--	   GDT.Guide_Serie,
									--	   GDT.Guide_Number
									--FROM #GuideTable GDT
									-- SET @IdCost = @@IDENTITY; 

									--INSERT INTO BreakdownOfPayment (IdCost, Description, Amount, RowStatus, TokenCreated, DateCreated)
									--SELECT @IdCost,
									--	   'Servicio',
									--	   GTL.PriceShippment,
									--	   1,
									--		@Token,
									--		GETDATE()
									--FROM #GuideTable GTL

								END
							ELSE
								BEGIN
									INSERT INTO DeliveryOrderPaymentDetail (GuideNumber, GuideSerie, PayTypeId, TypeofInOutMoneyId, TimePlaId, amount, TokenCreated, DateCreated)
									SELECT GIT.Guide_Number,
										   GIT.Guide_Serie,
										   1,
										   1,
										   1,
										   GIT.PriceShippment,
										   @Token,
										   GETDATE()
									FROM #GuideTable GIT

									--INSERT INTO Cost (IdProduct, ProductNumber, IdTypeCharge, TotalAmount, RowStatus, TokenCreated, DateCreated, GuideSerie, GuideNumber )
									--SELECT 1,
									--	   GDT.Guide_Serie+CAST(GDT.Guide_Number AS VARCHAR),
									--	   1,
									--	   GDT.PriceShippment,
									--	   1,
									--	   @Token,
									--	   GETDATE(),
									--	   GDT.Guide_Serie,
									--	   GDT.Guide_Number
									--FROM #GuideTable GDT
									-- SET @IdCost = @@IDENTITY; 

									--INSERT INTO BreakdownOfPayment (IdCost, Description, Amount, RowStatus, TokenCreated, DateCreated)
									--SELECT @IdCost,
									--	   'Servicio',
									--	   GTL.PriceShippment,
									--	   1,
									--		@Token,
									--		GETDATE()
									--FROM #GuideTable GTL
							  END
						END

		---FIN INSERTAR DETALLE DE PAGO PARA LAS GUÍAS DE CONCESIONARIO





		-- INSERTAR CHECKPOINT INICIAL EN TABLA HISTÓRICA
		INSERT [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] (
			[Guide_Serie],
			[Guide_Number],
			[StatusOrderId],
			[UserCreated],
			[DateCreated],
			[DateCreatedInSystem])
		SELECT 
			GT.Guide_Serie,
			GT.Guide_Number,
			GT.StatusOrderId,
			'SYSTEM',
			GETDATE(),
			GETDATE()
		FROM #GuideTable GT

		DECLARE @Route nvarchar(20) = (select  top 1 cov.RouteCode 
		from #GuideTable g
			inner join dbo.Township twn on twn.IdTownship = g.ReceiverIdTownship
			left join dbo.DumpServiceCoverage cov on cov.HeaderCode = twn.HeaderCode
			and cov.RowStatus=1
				)

		--Actualizar registro de guía agregando registro en columna Segment
		UPDATE do
        SET do.Segment = (dbo.fn_get_segment(GT.Guide_Serie,GT.Guide_Number))
        FROM DeliveryOrder do WITH(NOLOCK)
        INNER JOIN #GuideTable GT
        ON GT.Guide_Number = do.Guide_Number
            AND GT.Guide_Serie = do.Guide_Serie;
		-------------------------------------------------------------------
		
		-- Proceso para registro de tiempo estimado de entrega
		-- Andrés Ruíz - 2023-04-18
		UPDATE
			[DO]
		SET
			[DO].[DeliveryETA] = [DeliveryBackOffice].[dbo].[fn_GetGuideDeliveryETA]([DO].[Sender_Department], [DO].[Sender_Town], NULL, [DO].[Receiver_Department], [DO].[Receiver_Town], NULL, NULL)
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
			INNER JOIN
				[#GuideTable] GT
				ON
					[DO].[Guide_Serie] = [GT].[Guide_Serie]
					AND
					[DO].[Guide_Number] = [GT].[Guide_Number]
		------------------------------------------------------

		--Proceso para añadir a carrito de compras
		--Oscar Morales - 2022-08-17

		IF @AddToServiceCart = 1 AND @IdAccount IS NOT NULL
		BEGIN
			DECLARE @AccountServiceCartId INT

			SELECT TOP 1
				@AccountServiceCartId = IdAccountServiceCart
			FROM AccountServiceCart
			WHERE AccountId = @IdAccount
			AND IsPending = 1
			AND RowStatus = 1
			ORDER BY DateCreated DESC

			IF @AccountServiceCartId IS NULL
			BEGIN
				
				INSERT INTO [dbo].[AccountServiceCart] ([AccountId]
				, [IsPending]
				, [RowStatus]
				, [TokenCreated]
				, [DateCreated]
				, [TokenUpdated]
				, [DateUpdated])
					VALUES (@IdAccount, 1, 1, 'SetServiceRequestFD', GETDATE(), NULL, NULL)

				SET @AccountServiceCartId = @@IDENTITY
			END
			ELSE
			BEGIN
				--Desactivar otros carritos
				UPDATE AccountServiceCart
				SET IsPending = 0
				   ,RowStatus = 0
				   ,TokenUpdated = 'SetServiceRequestFD'
				   ,DateUpdated = GETDATE()
				WHERE IsPending = 1
				AND RowStatus = 1
				AND IdAccountServiceCart <> @AccountServiceCartId
				AND AccountId = @IdAccount
			END

			--Agregar guías al carrito
			INSERT INTO [dbo].[AccountServiceCartDetail] ([AccountServiceCartId]
			, [GuideSerie]
			, [GuideNumber]
			, [RowStatus]
			, [TokenCreated]
			, [DateCreated]
			, [TokenUpdated]
			, [DateUpdated])
				SELECT
					@AccountServiceCartId
				   ,Guide_Serie
				   ,Guide_Number
				   ,1
				   ,'SetServiceRequestFD'
				   ,GETDATE()
				   ,NULL
				   ,NULL
				FROM #GuideTable
		END
		--Termina proceso para añadir a carrito de compras

		DROP TABLE #GuideTable
	END TRY
	BEGIN CATCH
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'


		ROLLBACK TRANSACTION
			INSERT INTO dbo.RoutePreparationLogError
			(
				ErrorDescription,
				ErrorNumber,
				ErrorProcedure,
				ErrorLine,
				GuideSerie,
				GuideNumber,
				TokenCreated,
				DateCreated
			)
			VALUES
			 (CAST(ERROR_MESSAGE() AS VARCHAR(300))
					   ,ERROR_NUMBER()
					   ,CAST(ERROR_PROCEDURE() AS VARCHAR(100))
					   ,ERROR_LINE()
					   ,0
					   ,0
					   ,'Error en guía'
					   ,GETDATE())

	END CATCH;
	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION;

		---Nuevos datos para consumir nuevo formato guía
  	DECLARE @FranchiseVisitPointTypeId INT = 
	(
		SELECT 
			TOP (1) 
				[KOVPC].[IdKindOfVPClient] 
		FROM
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  WITH(NOLOCK) 
		WHERE
			[KOVPC].[KindOfVPName] = 'Concesionario'   
	)
	DECLARE @ExpressVisitPointTypeId INT = 
	(
		SELECT 
			TOP (1) 
				[KOVPC].[IdKindOfVPClient] 
		FROM
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  WITH(NOLOCK) 
		WHERE
			[KOVPC].[KindOfVPName] = 'Express Center'   
	)

	DECLARE @IndividualWebSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Hermes Web'   
	)
	DECLARE @ExpressWebSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Hermes Web-ExpressCenter'   
	)
	DECLARE @CorporateWebSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Hermes Web-Corporativo'   
	)
	DECLARE @ParserSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Parser'   
	)


  --Fin Nuevos datos para consumir nuevo formato guía


		DECLARE @IDCatBusinessB2B INT = (SELECT IdBusinessSegment FROM DBO.CatBusinessSegment WHERE BusinessSegmentName='B2B');

		SELECT 
			1 AS 'StatusCode',
			'Registros guardados correctamente' AS 'Description', 
			--@IdTransaction AS 'NumTransferID'
			@ManifestNumber AS 'NumTransferID',
			(Select Segment from DeliveryOrder WITH(NOLOCK) where Manifest_Number = @ManifestNumber) AS 'Segment'
		SELECT 
			Manifest_Serie AS 'ManifestSerie',
			Manifest_Number AS 'ManifestNumber'
		FROM ServiceRequest WITH(NOLOCK)
		WHERE Manifest_Serie = @ManifestSerie AND Manifest_Number = @ManifestNumber
		SELECT 
			C.[Row_Number] AS 'RowNumber',
			D.Guide_Serie AS 'GuideSerie',
			D.Guide_Number AS 'GuideNumber',
			''  as 'Route'
			,D.PriceShippment AS 'Price'
			,D.Ticket_Number AS 'IdInternalOrderRef'
			,D.Order_Number AS 'IdInternalOrderRef2',
			-- MODIFICACION 16/02/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			(SELECT DeliveryBackOffice.dbo.FnGetCustomerAttempts(D.Sender_ID,@CustomerID)) AS 'Attempts',
			--FIN MODIFICACIÓN
			(CASE 
				WHEN MMBSHP.IdMembership IS NOT NULL THEN 'F'
				WHEN ctm.BusinessSegmentID = @IDCatBusinessB2B THEN 'B' 
				ELSE 'E'
				END) 'Priority',
			--IIF(D.SalePipeLineId=@IDCatBusinessB2B,'P','E') 'Priority',
			CONCAT('https://qa.forzadelivery.com/rastreo/',D.Guide_Serie,D.Guide_Number)'QRLink',
			(CASE
				WHEN 
					(D.IsCollect <> 1 AND D.Collect_OnDelivery>0 )
					or ctm.Abbreviation IN ('IGSS','RENAP')

				THEN
					'D'
				ELSE
					''
				END
			)'Icon',
			(FORMAT(ISNULL([D].[DeliveryETA], DATEADD(DAY,5,GETDATE())), 'ddMM'))'DeliveryETA',
				(
					CASE
						WHEN ISNULL([D].[IsCollect], 0) = 1 THEN 'COLLECT'
						WHEN [DOPD].[TimePlaId] = 1 THEN 'PREPAGO'
						WHEN [DOPD].[TimePlaId] = 2 THEN 'PICKUP'
						WHEN [DOPD].[TimePlaId] = 3 THEN 'COLLECT'
						WHEN [DOPD].[TimePlaId] = 4 THEN 'CRÉDITO'
						ELSE 'CRÉDITO'
					END
				)'WayToPayDescription',

			(
					CASE
						WHEN [vpct].[IdKindOfVPClient] = @FranchiseVisitPointTypeId THEN 'CNC'
						WHEN [vpct].[IdKindOfVPClient] = @ExpressVisitPointTypeId THEN 'EXC'
						WHEN [vpcti].[IdKindOfVPClient] = @ExpressVisitPointTypeId THEN 'EXC'
						WHEN [D].[CatSystemId] = @IndividualWebSys THEN 'WEB'
						WHEN [D].[CatSystemId] = @ExpressWebSys THEN 'EXC'
						WHEN [D].[CatSystemId] = @CorporateWebSys THEN 'COR'
						WHEN [D].[CatSystemId] = @ParserSys THEN 'PAR'
						WHEN [D].[CatSystemId] IS NULL THEN 'API'
						ELSE 'API'
					END
			)'GuideOrigin'
		FROM DeliveryOrder D WITH(NOLOCK)
		INNER JOIN @CorrelativeTable C ON C.Guide_Number = D.Guide_Number
										AND D.Guide_Serie = @GuideSerie
		LEFT JOIN DeliveryBackOffice.dbo.Customer ctm WITH (NOLOCK)
			ON ctm.IdCustomer = D.IdCustomer
		LEFT JOIN DeliveryBackOffice.dbo.Membership MMBSHP WITH(NOLOCK)
				ON MMBSHP.CustomerId = ctm.IdCustomer
				AND MMBSHP.CatMembershipStatusId = @StatusPackage
			    AND MMBSHP.ExpirationDate >= GETDATE()
				AND MMBSHP.RowStatus = 1
		LEFT JOIN DeliveryOrderPaymentDetail DOPD WITH (NOLOCK)
			ON dopd.GuideSerie = d.Guide_Serie AND  DOPD.GuideNumber = D.Guide_Number
			
		LEFT JOIN VisitPointClient vpct WITH (NOLOCK)
            ON vpct.CodeOfReference = D.Sender_ID
		LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpcti  WITH(NOLOCK) 
		    ON [vpcti].[CodeOfReference] = [D].[OriginSenderId]
		WHERE D.Guide_Serie = @GuideSerie AND D.Guide_Number IN (SELECT CT.Guide_Number FROM @CorrelativeTable CT)
	END
END
