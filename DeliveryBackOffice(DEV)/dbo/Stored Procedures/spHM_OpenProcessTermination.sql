
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-09>
-- Description:	<SP Finalización de procesos abiertos en preparación de entrega de hermes mobile>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_OpenProcessTermination]
@GuideSerie  AS NVARCHAR(2),
@GuideNumber AS INT,
@DateRoute AS DATETIME,
@IdRoute AS INT,
@Token AS NVARCHAR(50)

AS  
BEGIN

	DECLARE @IsReturn AS BIT = 0--bandera de dvolución
	DECLARE @AmountToPay AS DECIMAL (18,2) = 0;
	DECLARE @AmountToPayExtra AS DECIMAL (18,2) = 0;
	DECLARE @RouteAssigmentId AS INT = NULL
	DECLARE @ServiceManagementDetailId AS INT  = NULL
	DECLARE @subtypeservicemanagment AS INT  = NULL
	DECLARE @StatusOrder AS INT

	DECLARE @InsertedServiceManagement AS TABLE (
		IdServiceManagement INT
	);
	DECLARE @InsertedServiceManagementDetail AS TABLE (
		IdServiceManagementDetail INT
	);
	
	SET NOCOUNT ON;
	
	DECLARE @Result AS INT = 0; 

	BEGIN TRANSACTION
	BEGIN TRY
	
	SELECT TOP 1 @IsReturn = 1
	FROM dbo.DeliveryOrder do WITH (NOLOCK)
	WHERE do.IsLastMileReturn = 1 AND
    do.Guide_Serie = @GuideSerie AND 
	do.Guide_Number = @GuideNumber ;  

	SELECT TOP 1 @StatusOrder = so.StatusOrderId
	FROM [DeliveryBackOffice].[dbo].[StatusOrder] so WITH(NOLOCK) 
	WHERE so.OrderDescription = 'Programado para entrega' COLLATE Latin1_General_CI_AI
	
	-- Obtener asignación de ruta
	SET @RouteAssigmentId = (SELECT TOP 1 IdRouteAssigment FROM DeliveryBackOffice.dbo.RouteAssigment RA WITH(NOLOCK) WHERE RA.IdRoute = @IdRoute AND RA.DateOfRoute = @DateRoute AND RA.RowStatus = 1);
	IF (ISNULL(@RouteAssigmentId,0) = 0)
	BEGIN

		DECLARE @InsertRouteAssignment AS TABLE (
			IdRouteAssignment INT
		);
		-- Generar asignación de ruta para futuro proceso
		INSERT INTO [DeliveryBackOffice].[dbo].[RouteAssigment]
		(
			[IdRoute]
			,[IdCurrierMan]
			,[IdVehicle]
			,[DateOfRoute]
			,[RowStatus]
			,[TokenCreated]
			,[DateCreated]
		)
		OUTPUT inserted.IdRouteAssigment INTO @InsertRouteAssignment (IdRouteAssignment)
		VALUES
		(
			@IdRoute
			,NULL
			,NULL
			,@DateRoute
			,1
			,@Token
			,GETDATE()
		);
						
		SET @RouteAssigmentId = (SELECT TOP 1 IRA.IdRouteAssignment FROM @InsertRouteAssignment IRA);

	END

	IF (@IsReturn = 1)
	BEGIN

		--- Es devolución
		SET @subtypeservicemanagment = (SELECT TOP 1 STSM.IdSubTypeServiceManagment FROM DeliveryBackOffice.dbo.SubTypeServiceManagment STSM WITH(NOLOCK) WHERE STSM.[Name] = 'Devolución' COLLATE Latin1_General_CI_AI)

		-- Obtener servicio activo de la guía
		SELECT 
			TOP 1 
				@ServiceManagementDetailId = SMD.IdServiceManagementDetail
		FROM 
			DeliveryBackOffice.dbo.ServiceManagementDetail SMD WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
				ON
					DO.Guide_Serie = @GuideSerie
					AND
					DO.Guide_Number = @GuideNumber
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
				ON
					DO.SenderIdTownship = Twn.IdTownship
		WHERE 
			CAST(SMD.ServiceStartDate AS DATE) = CAST(GETDATE() AS DATE)
			AND ISNULL(SMD.ServiceVisitPointId, 0) = DO.Sender_ID
			AND LTRIM(RTRIM(SMD.ServiceAddress)) = LTRIM(RTRIM(DO.Sender_Address))
			AND SMD.SubTypeServiceManagmentId = @subtypeservicemanagment
			AND SMD.RowStatus=1;
			
		DECLARE @BrainProcessedGuides AS TABLE
		(
			GuideSerie NVARCHAR(2),
			GuideNumber INT,
			IsCollect BIT,
			Price DECIMAL(18, 2),
			COD DECIMAL(18, 2),
			AmountPaid DECIMAL(18, 2),
			CODPaid DECIMAL(18, 2),
			CODIsPaid BIT,
			PaymentTime INT,
			TimeSequence INT,
			FelNumber NVARCHAR(50),
			IsPaid BIT,
			IsCustomer INT,
			ConditionPayment NVARCHAR(200),
			HaveCredit BIT,
			CollectCOD BIT,
			ReturnRate DECIMAL(5, 2),
			AmountToPay DECIMAL(18, 2),
			CODAmount DECIMAL(18, 2),
			ReturnRates DECIMAL(5, 2)
		);

		DECLARE @GUIDECONCAT NVARCHAR(MAX) = CONCAT(@GuideSerie, CONVERT(NVARCHAR(MAX), @GuideNumber));

		INSERT INTO @BrainProcessedGuides
		EXEC [dbo].[spws_get_guide_pending_payment] 
			@GUIDECONCAT, -- Guías recibidas
			3,            -- Tiempo de pago 3 - En devolución
			1,            -- Si es devolución
			'',           -- Codeapp
			1,            -- Identificador de modulo donde proviene
			@Token;       -- Token de courier

		SELECT 
			TOP 1 
				@AmountToPay  = bpg.AmountToPay
		FROM  
			@BrainProcessedGuides bpg

		IF(ISNULL(@ServiceManagementDetailId, 0) = 0)
		BEGIN
			--- Se debe generar ServiceManagement y ServiceManagementDetail

			INSERT INTO [DeliveryBackOffice].[dbo].[ServiceManagement]
			(
				[IdPuRouteAssigment]
				,[RowStatus]
				,[TokenCreated]
				,[DateCreated]
				,[ServiceStatusId]
				,[SubTypeServiceManagmentId]
				,[Order]
				,[Amount]
			)
			OUTPUT inserted.IdServiceManagement INTO @InsertedServiceManagement (IdServiceManagement)
			VALUES
			(
				@RouteAssigmentId
				,1
				,@Token
				,GETDATE()
				,(SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].dbo.CatServiceStatus CSS WHERE CSS.[Name] = 'Creado' COLLATE Latin1_General_CI_AI)
				,@subtypeservicemanagment
				,1
				,0
			);

			INSERT INTO [DeliveryBackOffice].[dbo].[EventService]
				(
					ServiceManagementId
					,ServiceStatusId
					,RowStauts
					,TokenCreated
					,DateCreated
				)
			VALUES
				(
					(SELECT TOP 1 ISM.IdServiceManagement FROM @InsertedServiceManagement ISM)
					,(SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].dbo.CatServiceStatus CSS WHERE CSS.[Name] = 'Creado' COLLATE Latin1_General_CI_AI)
					,1
					,@Token
					,GETDATE()
				)

			INSERT INTO [DeliveryBackOffice].[dbo].[ServiceManagementDetail]
			(
				[ServiceManagement]
				,[ServiceStartDate]
				,[ServiceEndDate]
				,[ServiceVisitPointId]
				,[ServiceCustomerName]
				,[ProvinceId]
				,[TownshipId]
				,[ServiceAddress]
				,[ServicePhone]
				,[HubLogisticsId]
				,[ServiceAmount]
				,[ServiceExtraAmount]
				,[SubTypeServiceManagmentId]
				,[RowStatus]
				,[TokenCreated]
				,[DateCreated]
			)
			OUTPUT inserted.IdServiceManagementDetail INTO @InsertedServiceManagementDetail (IdServiceManagementDetail)
			SELECT
				TOP 1
			
				(SELECT TOP 1 ISM.IdServiceManagement FROM @InsertedServiceManagement ISM)
				,GETDATE()
				,DATEADD(HOUR,20,CAST(CAST(GETDATE() AS DATE) AS DATETIME))--HORA FIN 8PM
				,DO.Sender_ID
				,LTRIM(RTRIM(CONCAT(DO.Sender_FirstName, ' ', DO.Sender_LastName)))
				,Twn.IdProvince
				,Twn.IdTownship
				,DO.Sender_Address
				,DO.Sender_Phone
				,HL.IdHubLogistic
				,@AmountToPay
				,0
				,@subtypeservicemanagment--<SubTypeServiceManagmentId, bigint,>
				,1
				,@Token
				,GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
					ON
						DO.SenderIdTownship = Twn.IdTownship
				INNER JOIN
					(
						SELECT
							DSC.HeaderCode,
							MAX(DSC.Hub) 'Hub'
						FROM
							[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
						GROUP BY
							DSC.HeaderCode
					) DSC
					ON
						Twn.HeaderCode = DSC.HeaderCode
				INNER JOIN
					[DeliveryBackOffice].[dbo].[HubLogistics] HL WITH(NOLOCK)
					ON
						DSC.Hub = HL.HubAbbreviation COLLATE Latin1_General_CI_AI
			WHERE
				DO.Guide_Serie = @GuideSerie
				AND
				DO.Guide_Number = @GuideNumber
			;

			SET @ServiceManagementDetailId = (SELECT TOP 1 ISMD.IdServiceManagementDetail FROM @InsertedServiceManagementDetail ISMD);

		END
		ELSE
		BEGIN
			--- YA existe servicio para la fecha
			UPDATE
				SMD
			SET
				SMD.ServiceAmount = SMD.ServiceAmount + @AmountToPay
				,SMD.TokenUpdated = @Token
				,SMD.DateUpdated = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[ServiceManagementDetail] SMD WITH(NOLOCK)
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
					ON
						SMD.IdServiceManagementDetail = RPD.ServiceManagementDetailId
						AND
						RPD.Guide_Serie = @GuideSerie
						AND
						RPD.Guide_Number = @GuideNumber
			WHERE
				SMD.IdServiceManagementDetail = @ServiceManagementDetailId
				AND
				RPD.IdRoutePreparationDetail IS NULL

		END

	END
	ELSE
	BEGIN

		--- Es entrega
		SET @subtypeservicemanagment = (SELECT TOP 1 STSM.IdSubTypeServiceManagment FROM DeliveryBackOffice.dbo.SubTypeServiceManagment STSM WITH(NOLOCK) WHERE STSM.[Name] = 'Entrega' COLLATE Latin1_General_CI_AI)
		
		SELECT 
			TOP 1 
				@ServiceManagementDetailId = SMD.IdServiceManagementDetail,
				@AmountToPay = ISNULL((CASE WHEN DO.IsCollect = 1 THEN DO.PriceShippment ELSE 0 END ),0),
				@AmountToPayExtra = ISNULL(DO.Collect_OnDelivery,0)
		FROM 
			DeliveryBackOffice.dbo.ServiceManagementDetail SMD WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
				ON
					DO.Guide_Serie = @GuideSerie
					AND
					DO.Guide_Number = @GuideNumber
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
				ON
					DO.ReceiverIdTownship = Twn.IdTownship
		WHERE 
			CAST(SMD.ServiceStartDate AS DATE) = CAST(GETDATE() AS DATE)
			AND SMD.ProvinceId = Twn.IdProvince
			AND SMD.TownshipId = Twn.IdTownship
			AND SMD.ServicePhone = DO.Receiver_Phone
			AND LTRIM(RTRIM(SMD.ServiceAddress)) = LTRIM(RTRIM(DO.Receiver_Address))
			AND SMD.SubTypeServiceManagmentId = @subtypeservicemanagment
			AND SMD.RowStatus=1;
			
		IF(ISNULL(@ServiceManagementDetailId, 0) = 0)
		BEGIN
			--- Se debe generar ServiceManagement y ServiceManagementDetail
			INSERT INTO [DeliveryBackOffice].[dbo].[ServiceManagement]
			(
				[IdPuRouteAssigment]
				,[RowStatus]
				,[TokenCreated]
				,[DateCreated]
				,[ServiceStatusId]
				,[SubTypeServiceManagmentId]
				,[Order]
				,[Amount]
			)
			OUTPUT inserted.IdServiceManagement INTO @InsertedServiceManagement (IdServiceManagement)
			VALUES
			(
				@RouteAssigmentId
				,1
				,@Token
				,GETDATE()
				,(SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].dbo.CatServiceStatus CSS WHERE CSS.[Name] = 'Creado' COLLATE Latin1_General_CI_AI)
				,@subtypeservicemanagment
				,1
				,0
			);

			INSERT INTO [DeliveryBackOffice].[dbo].[EventService]
				(
					ServiceManagementId
					,ServiceStatusId
					,RowStauts
					,TokenCreated
					,DateCreated
				)
			VALUES
				(
					(SELECT TOP 1 ISM.IdServiceManagement FROM @InsertedServiceManagement ISM)
					,(SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].dbo.CatServiceStatus CSS WHERE CSS.[Name] = 'Creado' COLLATE Latin1_General_CI_AI)
					,1
					,@Token
					,GETDATE()
				)

			INSERT INTO [DeliveryBackOffice].[dbo].[ServiceManagementDetail]
			(
				[ServiceManagement]
				,[ServiceStartDate]
				,[ServiceEndDate]
				,[ServiceVisitPointId]
				,[ServiceCustomerName]
				,[ProvinceId]
				,[TownshipId]
				,[ServiceAddress]
				,[ServicePhone]
				,[HubLogisticsId]
				,[ServiceAmount]
				,[ServiceExtraAmount]
				,[SubTypeServiceManagmentId]
				,[RowStatus]
				,[TokenCreated]
				,[DateCreated]
			)
			OUTPUT inserted.IdServiceManagementDetail INTO @InsertedServiceManagementDetail (IdServiceManagementDetail)
			SELECT
				TOP 1
			
				(SELECT TOP 1 ISM.IdServiceManagement FROM @InsertedServiceManagement ISM)
				,GETDATE()
				,DATEADD(HOUR,20,CAST(CAST(GETDATE() AS DATE) AS DATETIME))--HORA FIN 8PM
				,DO.Receiver_ID
				,LTRIM(RTRIM(CONCAT(DO.Receiver_FirstName, ' ', DO.Receiver_LastName)))
				,Twn.IdProvince
				,Twn.IdTownship
				,DO.Receiver_Address
				,DO.Receiver_Phone
				,HL.IdHubLogistic
				,@AmountToPay
				,@AmountToPayExtra
				,@subtypeservicemanagment--<SubTypeServiceManagmentId, bigint,>
				,1
				,@Token
				,GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
					ON
						DO.ReceiverIdTownship = Twn.IdTownship
				INNER JOIN
					(
						SELECT
							DSC.HeaderCode,
							MAX(DSC.Hub) 'Hub'
						FROM
							[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
						GROUP BY
							DSC.HeaderCode
					) DSC
					ON
						Twn.HeaderCode = DSC.HeaderCode
				INNER JOIN
					[DeliveryBackOffice].[dbo].[HubLogistics] HL WITH(NOLOCK)
					ON
						DSC.Hub = HL.HubAbbreviation COLLATE Latin1_General_CI_AI
			WHERE
				DO.Guide_Serie = @GuideSerie
				AND
				DO.Guide_Number = @GuideNumber
			;

			SET @ServiceManagementDetailId = (SELECT TOP 1 ISMD.IdServiceManagementDetail FROM @InsertedServiceManagementDetail ISMD);

		END
		ELSE
		BEGIN
			--- YA existe servicio para la fecha
			UPDATE
				SMD
			SET
				SMD.ServiceAmount = SMD.ServiceAmount + @AmountToPay
				,SMD.ServiceExtraAmount = SMD.ServiceExtraAmount + @AmountToPayExtra
				,SMD.TokenUpdated = @Token
				,SMD.DateUpdated = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[ServiceManagementDetail] SMD WITH(NOLOCK)
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
					ON
						SMD.IdServiceManagementDetail = RPD.ServiceManagementDetailId
						AND
						RPD.Guide_Serie = @GuideSerie
						AND
						RPD.Guide_Number = @GuideNumber
			WHERE
				SMD.IdServiceManagementDetail = @ServiceManagementDetailId
				AND
				RPD.IdRoutePreparationDetail IS NULL

		END

	END

	----------actualizar estado de piezas piezas 
    UPDATE  RPDP
	SET     
			RPDP.RowStatus= 1,
			RPDP.TokenUpdated= @Token,
			RPDP.DateUpdated=GETDATE()
	FROM [DeliveryBackOffice].[dbo].[RoutePreparation]  RP WITH (NOLOCK)
	INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
	ON RP.IdRoutePreparation =RPD.RoutePreparationId
	INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH(NOLOCK)
	ON RPD.IdRoutePreparationDetail =RPDP.RoutePreparationDetailId
	WHERE  RPD.Guide_Serie  = @GuideSerie AND 
	       RPD.Guide_Number = @GuideNumber AND
		   RP.CatRouteId = @IdRoute AND
		   FORMAT(RP.DateRoutePreparation, 'yyyy-mm-dd' ) = FORMAT(@DateRoute, 'yyyy-mm-dd')
		   AND RPD.IsOpenProcess = 1

	------------------------------- Actualizar estado del detalle de la guia
	UPDATE  RPD
	SET     RPD.UserProcess   = NULL, 
	        RPD.IsOpenProcess = 0,
			RPD.ServiceManagementDetailId = @ServiceManagementDetailId,
			RPD.RowStatus= 1,
			RPD.TokenUpdated= @Token,
			RPD.DateUpdated=GETDATE()
			FROM [DeliveryBackOffice].[dbo].[RoutePreparation]  RP WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
			ON RP.IdRoutePreparation =RPD.RoutePreparationId
	WHERE  RPD.Guide_Serie  = @GuideSerie AND 
	       RPD.Guide_Number = @GuideNumber AND
		   RP.CatRouteId = @IdRoute AND
		   FORMAT(RP.DateRoutePreparation, 'yyyy-mm-dd' ) = FORMAT(@DateRoute, 'yyyy-mm-dd')
		   AND RPD.IsOpenProcess = 1
		   
			--- Actualizar los tipos de pieza del detalle de la preparación de ruta segun lo almacenado
			UPDATE RPDP
			SET RPDP.PieceType = (CASE WHEN DOP.IsDry = 1 THEN 1 ELSE 0 END)
			FROM
				[DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH(NOLOCK)
				inner JOIN
					[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
					ON
						RPDP.RoutePreparationDetailId = RPD.IdRoutePreparationDetail
						AND
						RPD.RowStatus = 1
				inner JOIN
					[DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH(NOLOCK)
					ON
						RPD.RoutePreparationId = RP.IdRoutePreparation
						AND
						RP.RowStatus = 1
				inner JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
					ON
						RPD.Guide_Serie = DOP.GuideSerie
						AND
						RPD.Guide_Number = DOP.GuideNumber
					
			WHERE
				RP.CatRouteId = @IdRoute
				AND
				RP.DateRoutePreparation = CAST(@DateRoute AS DATE)
				AND
				RPDP.RowStatus = 1

			--- Actualizar la preparación de ruta en base a los datos almacenados
			UPDATE RP
			SET
				RP.GuidesQuantity = ISNULL(RPA.RealGuideQuantity,0),
				RP.PiecesDry = ISNULL(RPA.RealPiecesDry,0),
				RP.PiecesCold = ISNULL(RealPiecesCold,0)
			FROM 
				[DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH(NOLOCK)
				LEFT JOIN
				(
					SELECT
						RPA.IdRoutePreparation,
						COUNT (DISTINCT RPD.IdRoutePreparationDetail) 'RealGuideQuantity',
						SUM (CASE WHEN RPDP.PieceType = 1 THEN 1 ELSE 0 END) 'RealPiecesDry',
						SUM (CASE WHEN RPDP.PieceType = 0 THEN 1 ELSE 0 END) 'RealPiecesCold'
					FROM
						[DeliveryBackOffice].[dbo].[RoutePreparation] RPA WITH(NOLOCK)
						inner JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
							ON
								RPA.IdRoutePreparation = RPD.RoutePreparationId
								AND
								RPD.RowStatus = 1
						inner JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH(NOLOCK)
							ON
								RPD.IdRoutePreparationDetail = RPDP.RoutePreparationDetailId
								AND
								RPDP.RowStatus = 1
					WHERE
						RPA.CatRouteId = @IdRoute
						AND
						RPA.DateRoutePreparation = CAST(@DateRoute AS DATE)
						AND
						RPA.RowStatus = 1
					GROUP BY
						RPA.IdRoutePreparation
				) RPA
					ON 
						RP.IdRoutePreparation = RPA.IdRoutePreparation
			WHERE
				RP.CatRouteId = @IdRoute
				AND
				RP.DateRoutePreparation = CAST(@DateRoute AS DATE)
				AND
				RP.RowStatus = 1

		UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder] SET StatusOrderId = @StatusOrder
		WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber 

		UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] SET StatusOrderId = @StatusOrder
		WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber

		INSERT INTO dbo.DeliveryOrderDetail 
				   (Guide_Serie, 
					Guide_Number,
					StatusOrderId, 
					UserCreated,
					DateCreated,
					DateCreatedInSystem,
					RowStatus
					) 
			 VALUES (@GuideSerie,
					 @GuideNumber,
					 @StatusOrder,
					 @Token,
					 GETDATE(),
					 GETDATE(),
					 1
					 )

 			SET @RESULT = 1; /* PROCESESO EXITOSO */

			COMMIT TRANSACTION
		 
	        SELECT @Result AS Result;

    END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION
		SET @RESULT = 2; /* PROCESESO FALLIDO */
				 				 
		SELECT @Result AS Result
					
	END  CATCH

END 
GO


