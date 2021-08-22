USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetServiceRequest]    Script Date: 16/08/2021 13:37:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--DROP procedure [dbo].[SetServiceRequest]
ALTER PROCEDURE [dbo].[SetServiceRequest]
@TblServiceRequest AS TblServiceRequest READONLY,	
@TblDeliveryOrders AS TblDeliveryOrders READONLY
AS
BEGIN

	DECLARE @IdTransaction bigint = NULL
	DECLARE @ManifestNumber int = 0
	DECLARE @ManifestSerie varchar(2) = 'FM'
	DECLARE @GuideSerie varchar(2) = 'FD'

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
		DECLARE @noRecords INT = (SELECT COUNT(RowNumber) FROM @TblDeliveryOrders)
		DECLARE @startnum INT = (SELECT MAX([Guide_Number]) + 1 FROM [DeliveryBackOffice].[dbo].[DeliveryOrder])
		DECLARE @endnum INT = (@startnum - 1) + @noRecords

		;WITH gen AS (
			SELECT @startnum AS num
			UNION ALL
			SELECT num+1 FROM gen WHERE num+1<=@endnum
		)
		INSERT INTO @CorrelativeTable (Guide_Number)
		SELECT * FROM gen
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

			[Collect_OnDelivery]
		INTO #GuideTable
		FROM @TblDeliveryOrders
		LEFT JOIN @CorrelativeTable C ON C.[Row_Number] = RowNumber

		/**********************************************************************/
		/******** INSERCIÓN DE ÚNICO REGISTRO PARA TABLA DE MANIFIESTO ********/
		/**********************************************************************/
		SET @ManifestNumber = (SELECT MAX([Manifest_Number]) + 1 FROM [DeliveryBackOffice].[dbo].[ServiceRequest])
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
		FROM @TblServiceRequest

		--SET @IdTransaction = SCOPE_IDENTITY();

		--IF (@IdTransaction IS NOT NULL)
		--BEGIN

			/**********************************************************************/
			/*********** GUARDAR ÓRDENES ASOCIADAS (GUÍAS ELECTRÓNICAS) ***********/
			/**********************************************************************/
			--PRINT 'Guardar órdenes asociadas'
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
				[Guide_Collected]
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
				0 -- Guide_Collected
			FROM #GuideTable GT

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
				NEWID(),
				1,
				1,
				'SYS-HERMESROUTES',
				GETDATE()
			FROM #GuideTable GT;

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


	DECLARE @Guides AS TABLE(
		[RowNumber][int] IDENTITY(1,1),
		[Guide_Serie] nvarchar(2) NULL, 		
		[Guide_Number] [int] NULL, 
		[CountDry] int,
		[CountCold] int
	)

	DECLARE @Pieces AS TABLE(
		[Guide_Serie] nvarchar(2) NULL,
		[Guide_Number] [int] NULL,
		[PartNumber] int,
		[IsDry] bit
	)

	insert into @Guides
	select Guide_Serie,Guide_Number,Pieces_Dry,Pieces_Cold 
	from #GuideTable

			DECLARE @i int = 0
			DECLARE @elements int = (select count(1) from @Guides ) 
			if (@elements > 0) --insertar piezas
			BEGIN
			 WHILE @i < @elements 
			 BEGIN	
			   --piezas secas
			 	DECLARE @j int = 0
				DECLARE @PiecesCount int = (select CountDry from @Guides where RowNumber = @i+1) 				
			 	WHILE @j < @PiecesCount 
			 		BEGIN
			 		 insert into @Pieces
					 select Guide_Serie,Guide_Number,@j+1,1 from @Guides where RowNumber = @i+1
					 SET @j = @j + 1
			 		END
				
				--piezas frías
				DECLARE @k int = 0
				SET @PiecesCount = (select CountCold from @Guides where RowNumber = @i+1) 				
			 	WHILE @k < @PiecesCount 
			 		BEGIN
			 		 insert into @Pieces
					 select Guide_Serie,Guide_Number,@k+1+@j,0 from @Guides where RowNumber = @i+1
					 SET @k = @k + 1
			 		END
								
			 SET @i = @i + 1
			 END
			END

			insert into DeliveryBackOffice.dbo.DeliveryOrderPiece
			([GuideSerie], [GuideNumber], [PiecePhysicalWeight], [PieceHeight], [PieceWidth]
			, [PieceLength], [PieceWeight], [Detail], [Currency], [Amount], [DateCreated]
			, [PieceUpdated], [DateUpdated], [fragile], [IsPickup], [NoPiece], [PieceHeightCheck]
			, [PieceWidthCheck], [PieceLengthCheck], [MassWeight], [volumetricWeight]
			, [CategoryCheck], [StatusOrderId], [IsDry]
			)
			select PIC.Guide_Serie,PIC.Guide_Number,0,0,0
			,0,0,NULL,'GTQ',0,getdate()
			,null,null,null,null,PIC.PartNumber,null
			,null,null,null,null
			,null,1,PIC.IsDry			
			from @Pieces PIC
			join #GuideTable GTB
			ON PIC.Guide_Serie = GTB.Guide_Serie
			and PIC.Guide_Number = GTB.Guide_Number

			DROP TABLE #GuideTable

		--END
	END TRY
	
	BEGIN CATCH
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
		ROLLBACK TRANSACTION
	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION;
		SELECT 
			1 AS 'StatusCode',
			'Registros guardados correctamente' AS 'Description', 
			--@IdTransaction AS 'NumTransferID'
			@ManifestNumber AS 'NumTransferID'
		SELECT 
			Manifest_Serie AS 'ManifestSerie',
			Manifest_Number AS 'ManifestNumber'
		FROM ServiceRequest 
		WHERE Manifest_Serie = @ManifestSerie AND Manifest_Number = @ManifestNumber
		
		SELECT 
			C.[Row_Number] AS 'RowNumber',
			D.Guide_Serie AS 'GuideSerie',
			D.Guide_Number AS 'GuideNumber'
		FROM DeliveryOrder D
		JOIN @CorrelativeTable C ON C.Guide_Number = D.Guide_Number
		WHERE D.Guide_Serie = @GuideSerie AND D.Guide_Number IN (SELECT CT.Guide_Number FROM @CorrelativeTable CT)
	END
END

