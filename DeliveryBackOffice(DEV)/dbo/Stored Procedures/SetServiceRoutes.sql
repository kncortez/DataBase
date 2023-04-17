-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-09-01>
-- Description:	<Genera guías y las asigna a una ruta (Fresh Delivery)>
-- ============================================= 
CREATE PROCEDURE [dbo].[SetServiceRoutes]
	-- Add the parameters for the stored procedure here
	@CodeApp NVARCHAR(100),
	@Route NVARCHAR(50), 
	@Country nvarchar(2),
	@SystemModule NVARCHAR(200) = NULL,
	@ServiceRoutes TblServiceRoutes READONLY,
	@ServiceRoutesContent TblServiceRoutesContent READONLY,
	@ServiceRoutesParcel TblServiceRoutesParcel READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ManifestNumber int = 0
	DECLARE @ManifestSerie varchar(2) = 'FM'
	DECLARE @GuideSerie varchar(2) = 'FD'

	DECLARE @CodeOfReference int
	DECLARE @SenderId int
	DECLARE @SenderFirstName nvarchar(100)
	DECLARE @SenderLastName nvarchar(100) = ''
	DECLARE @SenderAddress nvarchar(200)
	DECLARE @SenderZone nvarchar(100)
	DECLARE @SenderTown nvarchar(100)
	DECLARE @SenderDepartment nvarchar(100)
	DECLARE @SenderPhone nvarchar(50)
	DECLARE @CustomerId int

	DECLARE @RowNumber int
	DECLARE @GuideNumber int

	DECLARE @StatusOrderId int

	DECLARE @system INT = NULL;
	DECLARE @module INT = NULL;

	DECLARE @TableResponse AS TABLE(
		GuideSerie nvarchar(2) NOT NULL,
		GuideNumber int NOT NULL,
		Ticket_Number nvarchar(150) NOT NULL
	)

	DECLARE @IsInsurance  bit = 0
	DECLARE @InsuranceAmount decimal(12,2)

	/*********************************************************************************************/
	/******** LLEVA EL CONTROL DE FILAS Y CORRELATIVOS AUTO GENERADOS PARA ESTA SOLICITUD ********/
	/*********************************************************************************************/
	DECLARE @CorrelativeTable AS TABLE(
		[Row_Number][int] IDENTITY(1,1), -- no de fila
		[Guide_Number] [int] NULL -- correlativo autogenerado
	)
	BEGIN TRANSACTION
	BEGIN TRY

		SET @StatusOrderId = (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription = 'Solicitado')
		
		IF (@SystemModule != '') 
		BEGIN
		--Se almacena el sistema y modulo desde donde se crea una guía
		SET @system = (
						SELECT SysIdSystem from CatSystem ca  WITH(NOLOCK) 
						WHERE ca.SysNameSystem = (SELECT item FROM dbo.SplitUnlimited(@SystemModule, '/') 
						WHERE id = 1)
						);

		-- Se deja la sentencia TOP 1 ya que existe dos modulos con el mismo nombre para la creación de guías en porta Web
		-- Crear guías para usuarios individuales/Express y Crear Guías para corporativos en el flujo normal
		SET @module = (
						SELECT TOP 1 mo.ModIdModule from CatModule mo  WITH(NOLOCK) 
						WHERE mo.ModName = (SELECT item FROM dbo.SplitUnlimited(@SystemModule, '/')
						WHERE id = 2)
						);
		END

		/*********************************************************************************************/
		/******** AUTO GENERACIÓN DE CORRELATIVOS BASADOS EN LA CANTIDAD DE REGISTOS RECIBIDOS *******/
		/*********************************************************************************************/
		DECLARE @noRecords INT = (SELECT COUNT(1) FROM @ServiceRoutes)
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
		
		WHILE EXISTS(SELECT TOP 1 1 FROM @CorrelativeTable)
		BEGIN
			
			SELECT TOP 1 
				@RowNumber = [Row_Number]
				,@GuideNumber = [Guide_Number]
			FROM @CorrelativeTable

			/*****************************************************************************/
			/* REALIZA LA BÚSQUEDA DE LA INFORMACIÓN DEL SENDER							 */
			/*****************************************************************************/
			IF(@SenderId IS NULL OR @SenderId <> (SELECT OriginCode FROM @ServiceRoutes WHERE IdTblServiceRoutes = @RowNumber))
			BEGIN 
				SET @SenderId = NULL
				SELECT
					@SenderId = vpc.CodeOfReference
					,@SenderFirstName = cu.Name
					,@SenderAddress = vpc.Address
					,@SenderZone = vpc.Zone
					,@SenderTown = vpc.Town
					,@SenderDepartment = vpc.Department
					,@SenderPhone = vpc.Phone
					,@CustomerId = vpc.CustomerID
				FROM VisitPointClient vpc  WITH(NOLOCK) 
				INNER JOIN Customer cu  WITH(NOLOCK) 
				ON cu.IdCustomer = vpc.CustomerID
				WHERE vpc.CodeOfReference = (SELECT OriginCode FROM @ServiceRoutes WHERE IdTblServiceRoutes = @RowNumber)
			END

			-- Si no se encuentra el VP se detiene el proceso
			IF (@SenderId IS NULL)
			BEGIN
				SELECT
					0 AS 'StatusCode'
				   ,CONCAT('No se encontró información del OriginCode ', (SELECT OriginCode FROM @ServiceRoutes WHERE IdTblServiceRoutes = @RowNumber),'.') AS 'Description'
				   ,@@TRANCOUNT AS 'NumTransferID'

				DELETE FROM @TableResponse
				BREAK;
			END

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
				'Web Service API Forza Delivery', 
				name,
				email, 
				NULL, 
				NULL, 
				'Requested', 
				GETDATE(), 
				GETDATE(),
				@ManifestSerie,
				@ManifestNumber,
				(SELECT CustomerID FROM VisitPointClient  WITH(NOLOCK)  WHERE CodeOfReference = OriginCode)
			FROM @ServiceRoutes 
			WHERE IdTblServiceRoutes = @RowNumber

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
				[IsCollect],
				[Guide_Collected],
				[PriceShippment],
				[SenderIdTownship],
				[ReceiverIdTownship],
				[CatSystemId],
				[CatModuleId],
				[TypeService],
				[OrderUserCreated],
				[IdCustomer]
				
			)
			SELECT 
				sr.[Ticket_Number],
				sr.[IdTblServiceRoutes],
				GETDATE(),
				GETDATE(),
				0,
				sr.[CountPieces],
				0,
				NULL,
				@SenderId,
				@SenderFirstName,
				@SenderLastName,
				@SenderAddress,
				@SenderZone,
				@SenderTown,
				@SenderDepartment,
				@SenderPhone,
				NULL,
				sr.[name],
				'',
				sr.[address1],
				0,
				NULL,
				NULL,
				sr.[phone],
				sr.[email],
				NULL,
				0,
				@GuideSerie,
				@GuideNumber,
				@ManifestSerie, 
				@ManifestNumber,
				GETDATE(),
				@StatusOrderId,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL, -- Courier_Route,
				NULL, -- Courier_Name,
				NULL, -- Courier_Vehicle_Plate,
				NULL, -- Dispatched_Date,
				NULL, -- Dispatched_Token,
				sr.AmmountCashOnDelivery, -- Collect_OnDelivery
				0, -- IsCollect
				0, -- Guide_Collected,
				0,
				NULL, --SenderIdTownship
				(SELECT IdTownship FROM Township  WITH(NOLOCK)  WHERE HeaderCode = sr.HeaderCodeTownship), --ReceiverIdTownship
				@system,
				@module,
				'FDD',
				sr.Username,
				@CustomerId
			FROM @ServiceRoutes sr
			WHERE sr.IdTblServiceRoutes = @RowNumber

			-- INSERTA PIEZAS
			INSERT INTO [dbo].[DeliveryOrderPiece] ([GuideSerie]
			, [GuideNumber]
			, [PiecePhysicalWeight]
			, [PieceHeight]
			, [PieceWidth]
			, [PieceLength]
			, [PieceWeight]
			, [Detail]
			, [Currency]
			, [Amount]
			, [DateCreated]
			, [fragile]
			, [NoPiece]
			, [IsDry]
			, [StatusOrderId])
				SELECT
					@GuideSerie
				   ,@GuideNumber
				   ,ROUND((srp.length * srp.height * srp.width) / 2272, 2)
				   ,srp.height
				   ,srp.width
				   ,srp.length
				   ,srp.weight
				   ,srp.description
				   ,srp.currency
				   ,srp.amount
				   ,GETDATE()
				   ,srp.fragil
				   ,ROW_NUMBER() OVER(ORDER BY srp.IdTblServiceRoutesParcel ASC)
				   ,0
				   ,@StatusOrderId
				FROM @ServiceRoutesParcel srp
				WHERE srp.TblServiceRoutesId = @RowNumber


			-- INSERTAR DATA PARA MANEJO DE LANDING PAGE
			INSERT INTO [DeliveryBackOffice].[dbo].[ServiceDataForGuide](
				[GuideSerie],
				[GuideNumber],
				[GuideToken],
				[IsDelivery],
				[Latitude],
				[Longitude],
				[Accuracy],
				[RowStatus],
				[TokenCreated],
				[DateCreated])
			SELECT 
				@GuideSerie,
				@GuideNumber,
				CONCAT(@GuideSerie, CAST(@GuideNumber AS NVARCHAR) , RIGHT ('00000'+CAST( (FLOOR(RAND()*(99999-0+1))+0) AS NVARCHAR),5)),
				1,
				sr.Latitude,
				sr.Longitude,
				sr.Accuracy,
				1,
				'SYS-HERMESROUTES',
				GETDATE()
			FROM @ServiceRoutes sr
			WHERE NOT EXISTS (
				SELECT 1
				FROM [DeliveryBackOffice].[dbo].[ServiceDataForGuide] SDFG  WITH(NOLOCK) 
				WHERE @GuideSerie = SDFG.GuideSerie
				AND @GuideNumber = SDFG.GuideNumber
				AND SDFG.IsDelivery = 1
			) AND sr.IdTblServiceRoutes = @RowNumber;

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
				SELECT TOP 1
					@GuideSerie
					,@GuideNumber
					,0
					,rh.Attempt
					,0
					,rh.AttemptReturn
					,1
					,GETDATE()
					,'SYSTEM'
					,NULL
					,NULL
				FROM RateHeader rh WITH (NOLOCK)
				LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
					ON @SenderId = vpc.CodeOfReference
				INNER JOIN RatebyCustomer rbc WITH (NOLOCK)
					ON ISNULL(@CustomerID, vpc.CustomerID) = rbc.RbcIdCustomer
						AND rbc.RbcRowStatus = 1
						AND (rbc.RbcCodeOfReference = vpc.CodeOfReference
							OR rbc.RbcCodeOfReference IS NULL)
				WHERE rbc.RbcIdRate = rh.RheId
				ORDER BY rbc.RbcCodeOfReference DESC
			-- Fin FDAPI-1418 Oscar Morales 2023-02-23

			-- INSERTAR CHECKPOINT INICIAL EN TABLA HISTÓRICA
			INSERT [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] (
				[Guide_Serie],
				[Guide_Number],
				[StatusOrderId],
				[UserCreated],
				[DateCreated],
				[DateCreatedInSystem])
			SELECT 
				@GuideSerie,
				@GuideNumber,
				@StatusOrderId,
				'SYSTEM',
				GETDATE(),
				GETDATE()

			-- INSERTAR CONTENIDO DE GUÍA 
			INSERT INTO [dbo].[DeliveryOrderContent] ([GuideSerie]
			, [GuideNumber]
			, [ContentCode]
			, [ContentDescription]
			, [ContentPrice]
			, [RowStatus]
			, [TokenCreated]
			, [DateCreated]
			, [TokenUpdated]
			, [DateUpdated])
				SELECT
					@GuideSerie
				   ,@GuideNumber
				   ,src.Code
				   ,src.Description
				   ,src.Price
				   ,1
				   ,@CodeApp
				   ,GETDATE()
				   ,NULL
				   ,NULL
				FROM @ServiceRoutesContent src
				WHERE src.TblServiceRoutesId = @RowNumber

			-- INSERTA EN TABLA DE RUTAS
			INSERT INTO [dbo].[DeliveryOrderRoute] ([GuideSerie]
			, [GuideNumber]
			, [Route]
			, [IsPendingTransfer]
			, [RowStatus]
			, [TokenCreated]
			, [DateCreated]
			, [TokenUpdated]
			, [DateUpdated])
				SELECT
					@GuideSerie
				   ,@GuideNumber
				   ,@Route
				   ,1
				   ,1
				   ,@CodeApp
				   ,GETDATE()
				   ,NULL
				   ,NULL


			SELECT
				@IsInsurance = sr.IsInsuarance
			   ,@InsuranceAmount = sr.ProductInsuranceAmount
			FROM @ServiceRoutes sr
			WHERE sr.IdTblServiceRoutes = @RowNumber

			--REVALORIZA LA GUÍA
			EXEC [dbo].[spws_revalue_guide] @GuideSerie = @GuideSerie
										   ,@GuideNumber = @GuideNumber
										   ,@CodeApp = @CodeApp -- CodeApp generico de forza
										   ,@Format = 'Non'
										   ,@CalculateTaxes = 'false' -- Dado a nuevas tarifas, no cálcular impuestos
										   ,@IdModule = 1
										   ,@SetUpdate = 'true' -- Actualizar registros
										   ,@Token = @CodeApp
										   ,@IsReturn = 'false'
										   ,@ParIsInsurance = @IsInsurance
										   ,@ParInsuranceAmount = @InsuranceAmount

			-- INSERTAR EN TABLA PARA RESPUESTA
			INSERT INTO @TableResponse (GuideSerie, GuideNumber, Ticket_Number)
			VALUES (@GuideSerie, @GuideNumber, (SELECT Ticket_Number FROM @ServiceRoutes WHERE IdTblServiceRoutes = @RowNumber))

			-- ELIMINAR FILA EN TABLA ITERADA
			DELETE FROM @CorrelativeTable
			WHERE Guide_Number = @GuideNumber
		END

		IF EXISTS (SELECT TOP 1 1 FROM @TableResponse)
		BEGIN

			SELECT
				1 AS 'StatusCode'
			   ,'Success' AS 'Description'
			   ,@@TRANCOUNT AS 'NumTransferID'

			SELECT
				CONCAT(GuideSerie, GuideNumber) Guide
			   ,Ticket_Number Ticket_Number
			FROM @TableResponse

			IF (@@TRANCOUNT > 0)
					COMMIT TRANSACTION
		END
		ELSE
		BEGIN 
			SELECT
				0 AS 'StatusCode'
			   ,'Ocurrió un error.' AS 'Description'
			   ,@@TRANCOUNT AS 'NumTransferID'

			ROLLBACK TRANSACTION
		END
	END TRY
	BEGIN CATCH

		SELECT
			0 AS 'StatusCode'
		   ,ERROR_MESSAGE() AS 'Description'
		   ,CONVERT(BIGINT, 0) AS 'NumTransferID'

		ROLLBACK TRANSACTION
	END CATCH
END