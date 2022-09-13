

CREATE PROCEDURE [dbo].[SetServiceRequestFD]
@TblServiceRequestFD AS TblServiceRequest READONLY,	
@TblDeliveryOrdersFD AS TblDeliveryOrdersFD READONLY,
@VisitPointByClientPortfolioId BIGINT = 0,
@UserAddressId BIGINT = 0,
@SystemModule NVARCHAR(200) = NULL
AS
BEGIN
	DECLARE @IdTransaction bigint = NULL
	DECLARE @ManifestNumber int = 0
	DECLARE @ManifestSerie varchar(2) = 'FM'
	DECLARE @GuideSerie varchar(2) = 'FD'

	-- MODIFICACION 16/02/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	DECLARE @CustomerID int = (SELECT [CustomerID] FROM @TblServiceRequestFD)
	--FIN MODIFICACIÓN

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
			[Sender_Lng]
		INTO #GuideTable
		FROM @TblDeliveryOrdersFD
		LEFT JOIN @CorrelativeTable C ON C.[Row_Number] = RowNumber

		CREATE NONCLUSTERED INDEX IX_TempTest_SerieNumber ON #GuideTable(Guide_Serie, Guide_Number);
		CREATE NONCLUSTERED INDEX IX_TempTest_ReceiverIdTownship ON #GuideTable(ReceiverIdTownship);

		/**********************************************************************/
		/******** INSERCIÓN DE ÚNICO REGISTRO PARA TABLA DE MANIFIESTO ********/
		/**********************************************************************/
		SET @ManifestNumber = NEXT VALUE FOR [dbo].[NewGuideManifestSequence]; 
		--(
		--	SELECT MAX([Manifest_Number]) + 1 
		--	FROM [DeliveryBackOffice].[dbo].[ServiceRequest] 
		--)
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
		--SET @IdTransaction = SCOPE_IDENTITY();
		--IF (@IdTransaction IS NOT NULL)
		--BEGIN
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
				[CatModuleId]
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
				@module
			FROM #GuideTable GT
			
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


			DROP TABLE #GuideTable
		--END
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
			isnull(@Route,'')  as 'Route'
			,D.PriceShippment AS 'Price',
			-- MODIFICACION 16/02/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			(SELECT DeliveryBackOffice.dbo.FnGetCustomerAttempts(D.Sender_ID,@CustomerID)) AS 'Attempts'
			--FIN MODIFICACIÓN
		FROM DeliveryOrder D WITH(NOLOCK)
		JOIN @CorrelativeTable C ON C.Guide_Number = D.Guide_Number
		WHERE D.Guide_Serie = @GuideSerie AND D.Guide_Number IN (SELECT CT.Guide_Number FROM @CorrelativeTable CT)
	END
END
