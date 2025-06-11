
-- =============================================
-- Author:		<Eduardo López>
-- Create date: <08-06-2023>
-- Description:	< Proceso para finalizar proceso de recolección de rutas especiales >
-- =============================================
CREATE PROCEDURE [dbo].[Set_FinishProcesRecolect]

	@TblListGuides AS TblGuides READONLY,
	@IdRoute INT,
	@DateRoute DATE,
	@Token VARCHAR (50),
	@UrlSignature VARCHAR(500)

AS
BEGIN

	DECLARE @IdCourier INT;
	DECLARE @IdVehicle INT;
	DECLARE @SchedulePickup INT;
	DECLARE @RouteAssignment INT;
	DECLARE @ServiceManagementId INT;
	DECLARE @UpdatedGuides TABLE
	(
		IdUpdated INT
	);
	DECLARE @UpdatedRoute TABLE
	(
		IdUpdated INT
	);

	BEGIN TRANSACTION 
	BEGIN TRY

		-- Obtener datos generales de la ruta especial del TSE
		SELECT 
			TOP (1) 
				@IdCourier = [TSERPH].[SenderReceiverId]
				,@IdVehicle = [TSERPH].[IdCatVehicle]
		FROM 
			[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] TSERPH  WITH(NOLOCK) 
		WHERE
			[TSERPH].[IdCatRoute] = @IdRoute
			AND
			[TSERPH].[RowStatus] = 1
		ORDER BY
			[TSERPH].[DateCreated] DESC

		-- Obtener asignación de ruta
		SELECT
			@RouteAssignment = [RA].[IdRouteAssigment]
		FROM 
			[DeliveryBackOffice].[dbo].[RouteAssigment] RA  WITH(NOLOCK) 
		WHERE 
			[RA].[IdRoute] = @IdRoute
			AND 
			[RA].[DateOfRoute] = @DateRoute
			AND 
			[RA].[RowStatus] = 1

		-- Verificar asignación de ruta
		IF 
		(
			ISNULL(@RouteAssignment, 0) = 0
		)
		BEGIN
			-- Ingresar nueva asignación de ruta
			INSERT INTO  [DeliveryBackOffice].[dbo].[RouteAssigment] 
			(
				IdRoute
				, DateOfRoute
				, RowStatus
				, TokenCreated
				, DateCreated
			)
			VALUES 
			(
				@IdRoute
				, @DateRoute
				, 1
				, @Token
				, GETDATE()
			)

			-- Obtener identificador de ruta generada
			SET @RouteAssignment = SCOPE_IDENTITY()
		END

		-- No se identifica asignación de ruta para proceso
		IF ( ISNULL(@RouteAssignment,0) = 0 )
		BEGIN
			;THROW 50000, 'No se pudo generar asignación de ruta para el proceso de recolección', 1;
		END

		-- Ingresar información de recolección
		INSERT INTO  [DeliveryBackOffice].[dbo].[SchedulePickup] 
		(
			StartDate
			, EndDate
			, RowStatus
			, TokenCreated
			, DateCreated
			, SenderId
			, SenderName
			, SenderPhone
			, AddressPickup
			, TownshipId
		)
		SELECT
			TOP 1
				GETDATE()
				,GETDATE()
				,1
				,@token
				,GETDATE()
				,[DO].[Sender_ID]
				,CONCAT([car].[CodeRoute], ' - ', [vpc].[DescriptionOfClient])
				,[vpc].[Phone]
				,[vpc].[Address]
				,[vpc].[IdTownship]
		FROM
			[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] tse
			INNER JOIN
				[DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] tsed
				ON
					tse.[IDTSERoutePreparationHeader] = [tsed].[TSERoutePreparationHeaderID]
			LEFT JOIN 
				[DeliveryBackOffice].[dbo].[CatRoute] car
				ON 
					car.IdRoute = tse.IdCatRoute		
			INNER JOIN
				[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
				ON
					[DO].[Guide_Serie] = [tsed].[GuideSerie] AND [DO].[Guide_Number] = [tsed].[GuideNumber]
			INNER JOIN
				[dbo].[VisitPointClient] vpc
				ON
					[vpc].[CodeOfReference] = [DO].[Sender_ID]
		WHERE
			[tse].[IdCatRoute] = @idRoute
			AND
            [tse].[RowStatus] = 1

		-- Obetener identificador de recolección
		SET @SchedulePickup = SCOPE_IDENTITY()

		IF ( ISNULL(@SchedulePickup,0) = 0 )
		BEGIN
			;THROW 50000, 'No se pudo generar servicio de recolección para el proceso', 1;
		END

		-- Único servicio de recolección por origen compartido en proceso
		INSERT INTO [dbo].[ServiceManagement]
		(
			[IdPuCourrier],
			[CiPuDate],
			[CoPuDate],
			[IdPuRouteAssigment],
			[IdSchedulePickup],
			[RowStatus],
			[TokenCreated],
			[DateCreated],
			[ServiceStatusId],
			[PuSignaturePath],
			[SubTypeServiceManagmentId]
		)
		VALUES
		(   
			@IdCourier,      -- IdPuCourrier - int
			GETDATE(),      -- CiPuDate - datetime
			GETDATE(),      -- CoPuDate - datetime
			@RouteAssignment,      -- IdPuRouteAssigment - int
			@SchedulePickup,      -- IdSchedulePickup - bigint
			1,      -- RowStatus - bit
			@token,        -- TokenCreated - varchar(50)
			GETDATE(), -- DateCreated - datetime
			3,      -- ServiceStatusId - int
			@UrlSignature,      -- PuSignaturePath - nvarchar(250)
			1      -- SubTypeServiceManagmentId - int
		)
			
		-- Obtener servicio ingresado
		SET @ServiceManagementId = SCOPE_IDENTITY();

		IF ( ISNULL(@ServiceManagementId, 0) = 0 )
		BEGIN
			;THROW 50000, 'Encabezado de servicio de recolección no pudo ser ingresado', 1;
		END

		-- Actalizar guías recolectadas de proceso
		UPDATE
			[DOPD]
		set
			[DOPD].[IdHeaderRecolection] = @SchedulePickup
			,[DOPD].[TokenUpdated] = @Token
			,[DOPD].[DateUpdated] = GETDATE()
		OUTPUT [Inserted].[GuideNumber] INTO @UpdatedGuides ([IdUpdated])
		FROM
			[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] TSERPH  WITH(NOLOCK) 
			INNER JOIN
				[DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] TSERPD  WITH(NOLOCK) 
				ON
					[TSERPH].[IDTSERoutePreparationHeader] = [TSERPD].[TSERoutePreparationHeaderID]
					--AND
					--[TSERPD].[RowStatus] = 1
			INNER JOIN 
				@TblListGuides TLG
				ON
					[TSERPD].[GuideSerie] = [TLG].[Guide_Serie]
					AND
					[TSERPD].[GuideNumber] = [TLG].[Guide_Number]
			INNER JOIN
				[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD
				ON
					DOPD.[GuideSerie] = [TSERPD].[GuideSerie]
					AND
					[DOPD].[GuideNumber] = [TSERPD].[GuideNumber]
		WHERE
			TSERPH.[IdCatRoute] = @IdRoute
			AND
					[TSERPD].[RowStatus] = 1

		IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @UpdatedGuides ) )
		BEGIN
			;THROW 50000, 'No se actualizaron las guías con la recolección', 1;
		END

		UPDATE 
			[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader]
		SET
			[HasFirstPickupProcess] = 1
			,[TokenUpdated] = @Token
			,[DateUpdated] = GETDATE()
		OUTPUT [Inserted].[IDTSERoutePreparationHeader] INTO @UpdatedRoute ([IdUpdated])
		WHERE
			[IdCatRoute] = @IdRoute
			AND
			[RowStatus] = 1

		IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @UpdatedRoute ) )
		BEGIN
		    ;THROW 50000, 'Indicador de ruta procesada en recolección no actualizado', 1;
		END

		COMMIT TRANSACTION;

		IF 
		( 
			(
				SELECT 
					COUNT([TSERPH].[HasFirstPickupProcess]) 
				FROM
					[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] TSERPH  WITH(NOLOCK) 
				WHERE
					ISNULL([TSERPH].[HasFirstPickupProcess], 0) = 1
					AND
                    [TSERPH].[RowStatus] = 1
			)
			=
			(
				SELECT 
					COUNT([TSERPH].[HasFirstPickupProcess]) 
				FROM
					[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] TSERPH  WITH(NOLOCK)
				WHERE
					[TSERPH].[RowStatus] = 1
			)

		)
		BEGIN

			SELECT
				200 [responseCode],
				'Proceso finalizado exitosamente' [responseMessage],
				CAST(1 AS BIT) [activeGlobalManifest]
		END
		ELSE
        BEGIN

			SELECT
				200 [responseCode],
				'Proceso finalizado exitosamente' [responseMessage],
				CAST(0 AS BIT ) [activeGlobalManifest]
        END

	END TRY
	BEGIN CATCH
	    
		ROLLBACK TRANSACTION;

		SELECT 
			500 [responseCode],
			ERROR_MESSAGE() [responseMessage]

	END CATCH
	
END