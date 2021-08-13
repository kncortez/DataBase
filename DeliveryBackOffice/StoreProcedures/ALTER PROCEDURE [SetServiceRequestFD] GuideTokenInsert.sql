USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetServiceRequestFD]    Script Date: 12/08/2021 8:40:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SetServiceRequestFD]
@TblServiceRequestFD AS TblServiceRequest READONLY,	
@TblDeliveryOrdersFD AS TblDeliveryOrdersFD READONLY
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
		DECLARE @noRecords INT = (SELECT COUNT(RowNumber) FROM @TblDeliveryOrdersFD)
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
			[Collect_OnDelivery],
			[IsCollect],
			[PriceShippment] ,
			[SenderIdTownship],
			[ReceiverIdTownship]
		INTO #GuideTable
		FROM @TblDeliveryOrdersFD
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
		FROM @TblServiceRequestFD
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
				[Guide_Collected],
				[IsCollect],
				[PriceShippment],
				[SenderIdTownship],
				[ReceiverIdTownship]
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
				GT.ReceiverIdTownship
			FROM #GuideTable GT

			-- Modificacion 11/08/2021 Jose Andres Ruiz Peer
			INSERT INTO ServiceDataForGuide(Guide_Serie, Guide_Number, DateCreated, Guide_Token, IsDelivery)
			SELECT GT.Guide_Serie, GT.Guide_Number, GETDATE(), NEWID(), 1
			FROM #GuideTable GT;
			-- Fin Modificacion

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
			D.Guide_Number AS 'GuideNumber',
			isnull(@Route,'')  as 'Route'
		FROM DeliveryOrder D
		JOIN @CorrelativeTable C ON C.Guide_Number = D.Guide_Number
		WHERE D.Guide_Serie = @GuideSerie AND D.Guide_Number IN (SELECT CT.Guide_Number FROM @CorrelativeTable CT)
	END
END