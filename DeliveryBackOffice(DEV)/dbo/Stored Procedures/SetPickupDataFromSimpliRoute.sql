
-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <2023-04-13>
-- Description:	<Retorno de datos desde Simpliroute para Recolecciones programadas, cambiando de estado los servicios procesados y generando el manifiesto del servicio y la asociación correspondiente>
-- =============================================
CREATE PROCEDURE [dbo].[SetPickupDataFromSimpliRoute]
		@ServicesTable TblExtPlatSimpliroutePickup READONLY,
		@ExternalPlatform INT,
		@RoutePlatform NVARCHAR(50),
		@CouriermanDPI NVARCHAR(50) = '',
		@VehicleCode NVARCHAR(50), -- De lado de Simpliroute proviene el codigo de una ruta "virtual"
		@RouteDispatched NVARCHAR(50) = '',
		@ServicesQuantity INT,
		@DateOfEvent DATETIME = NULL,
		@Token NVARCHAR(50) = 'SYS-HERMESROUTES',
		@StationId INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IdRoute INT = NULL;
	DECLARE @RouteAssigmentId INT = NULL;
	DECLARE @SenderReceiverId INT = NULL;

	IF (@DateOfEvent IS NULL)
	BEGIN
		SET @DateOfEvent = CAST(GETDATE() AS date)
	END

	SET @IdRoute = (SELECT TOP 1 CR.IdRoute 
					FROM [DeliveryBackOffice].[dbo].[CatRoute] CR 
					WHERE [CR].[CodeRoute] = @VehicleCode);

	BEGIN TRANSACTION
		BEGIN TRY
			-- REVISAR POR EXISTENCIA DE RUTA O GENERARLA
			SET @RouteAssigmentId = (	SELECT	[RA].[IdRouteAssigment]
										FROM	[dbo].[RouteAssigment] RA
										WHERE	[RA].[IdRoute] = @IdRoute
											AND	[RA].[DateOfRoute] = @DateOfEvent
											AND [RA].[RowStatus] = 1);

			SET @SenderReceiverId = (	SELECT	TOP 1 [SR].[ID]
										FROM	[dbo].[SenderReceiver] SR
										WHERE	[SR].[CUI] = @CouriermanDPI);

			IF (@RouteAssigmentId IS NULL) 
				BEGIN
					-- CREA LA RUTA EN LA TABLA ROUTEASSIGMENT
					INSERT INTO [dbo].[RouteAssigment]( [IdRoute],
														[IdCurrierMan],
														[IdVehicle],
														[DateOfRoute],
														[RowStatus],
														[TokenCreated],
														[DateCreated])
					VALUES							(	@IdRoute,
														@SenderReceiverId,
														NULL,
														@DateOfEvent,
														1,
														@Token,
														SYSDATETIME());

					SET @RouteAssigmentId = SCOPE_IDENTITY();
				END

			-- ASIGNA SERVICIOS EN LA TABLA SERVICEMANAGEMENT A LA RUTA GENERADA
			UPDATE		[SM]
			SET			[SM].[IdPuRouteAssigment] = @RouteAssigmentId,
						[SM].[TokenUpdated] = @Token,
						[SM].[DateUpdated] = SYSDATETIME(),
						[SM].[Order] = [ST].[OrderNo]
			FROM		[dbo].[ServiceManagement] SM
			INNER JOIN	@ServicesTable ST
				ON [SM].[IdServiceManagement] = [ST].[ServiceId];

			-- MARCA COMO ASIGNADOS LOS REGISTROS EN LA TABLA SCHEDULE PICKUP ASOCIADOS AL LISTADO DE SERVICIOS 
			UPDATE		[SP]
			SET			[AssigmentStatus] = 1,
						[DateUpdated] = SYSDATETIME(),
						[TokenUpdated] = @Token
			FROM		[dbo].[SchedulePickup] SP
			INNER JOIN	[dbo].[ServiceManagement] SM
				ON		[SP].[SchedulePickupId] = [SM].[IdSchedulePickup]
			INNER JOIN	@ServicesTable ST
				ON		[SM].[IdServiceManagement] = [ST].[ServiceId];

			IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;
			
			SELECT	@RouteAssigmentId AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID'
		END TRY
		BEGIN CATCH

        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

        ROLLBACK TRANSACTION;
    END CATCH;
END