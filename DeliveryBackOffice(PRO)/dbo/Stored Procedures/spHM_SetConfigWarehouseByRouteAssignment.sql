-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-09-30>
-- Description:	<Guarda o actualiza las configuración de liquidación de ruta unificada en proceso>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_SetConfigWarehouseByRouteAssignment]
	-- Add the parameters for the stored procedure here
	@Token NVARCHAR(50),
	@TblConfig TblConfigWarehouseByRouteAssignment READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRANSACTION;

	BEGIN TRY

		-- Validar si existen cambios
		IF EXISTS (SELECT
					1
				FROM ConfigWarehouseByRouteAssignment cwbra
				INNER JOIN @TblConfig tc
					ON tc.RouteAssignmentId = cwbra.RouteAssignmentId
				WHERE cwbra.RowStatus = 1
				AND cwbra.WarehouseLocationServiceType = tc.WarehouseLocationServiceType
				AND cwbra.WarehouseLocation <> tc.WarehouseLocation)
			OR (SELECT
					COUNT(1)
				FROM @TblConfig tc
				INNER JOIN ConfigWarehouseByRouteAssignment cwbra
					ON cwbra.RouteAssignmentId = tc.RouteAssignmentId
				WHERE tc.WarehouseLocationServiceType = cwbra.WarehouseLocationServiceType
				AND cwbra.RowStatus = 1)
			<> (SELECT
					COUNT(1)
				FROM @TblConfig tc)
		BEGIN

			-- Validar que no haya sido liquidada una ruta
			IF NOT EXISTS (SELECT
						1
					FROM UnifiedRouteSettlement urs
					INNER JOIN UnifiedRouteSettlementDetail ursd
						ON ursd.UnifiedRouteSettlementId = urs.IdUnifiedRouteSettlement
					WHERE urs.RouteAssignmentId IN (SELECT
							DISTINCT tc.RouteAssignmentId
						FROM @TblConfig tc)
					AND urs.RowStatus = 1
					AND (ursd.RowStatus = 1
					OR ursd.IsOpenProcess = 1))
			BEGIN

				DECLARE @Date DATETIME = GETDATE()

				-- Inserción de las configuraciones a modificar
				INSERT INTO ConfigWarehouseByRouteAssignment (RouteAssignmentId
				, WarehouseLocation
				, WarehouseLocationServiceType
				, RowStatus
				, TokenCreated
				, DateCreated)
					SELECT
						tc.RouteAssignmentId
					   ,tc.WarehouseLocation
					   ,tc.WarehouseLocationServiceType
					   ,1
					   ,@Token
					   ,@Date
					FROM ConfigWarehouseByRouteAssignment cwbra
					INNER JOIN @TblConfig tc
						ON tc.RouteAssignmentId = cwbra.RouteAssignmentId
					WHERE cwbra.RowStatus = 1
					AND cwbra.WarehouseLocationServiceType = tc.WarehouseLocationServiceType
					AND cwbra.WarehouseLocation <> tc.WarehouseLocation

				-- Desactivar las configuraciones a modificar
				UPDATE cwbra
				SET RowStatus = 0
				   ,TokenUpdated = @Token
				   ,DateUpdated = GETDATE()
				FROM ConfigWarehouseByRouteAssignment cwbra
				INNER JOIN @TblConfig tc
					ON tc.RouteAssignmentId = cwbra.RouteAssignmentId
				WHERE cwbra.RowStatus = 1
				AND cwbra.WarehouseLocationServiceType = tc.WarehouseLocationServiceType
				AND cwbra.WarehouseLocation <> tc.WarehouseLocation
				AND cwbra.DateCreated <> @Date

				-- Inserción de las nuevas configuraciones
				INSERT INTO ConfigWarehouseByRouteAssignment (RouteAssignmentId
				, WarehouseLocation
				, WarehouseLocationServiceType
				, RowStatus
				, TokenCreated
				, DateCreated)
					SELECT
						tc.RouteAssignmentId
					   ,tc.WarehouseLocation
					   ,tc.WarehouseLocationServiceType
					   ,1
					   ,@Token
					   ,@Date
					FROM @TblConfig tc
					LEFT JOIN ConfigWarehouseByRouteAssignment cwbra
						ON tc.RouteAssignmentId = cwbra.RouteAssignmentId
						AND cwbra.WarehouseLocationServiceType = tc.WarehouseLocationServiceType
					WHERE cwbra.IdConfigWarehouseByRouteAssignment IS NULL


				COMMIT TRANSACTION;

				SELECT
					1 'StatusCode'
				   ,'Registros guardados con éxito.' 'Description'
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION;

				SELECT
					0 'StatusCode'
				   ,'Ya se han liquidado rutas, no se pueden cambiar las configuraciones.' 'Description'
			END
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION;

			SELECT
				1 'StatusCode'
			   ,'No existen cambios que realizar.' 'Description'
		END
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		SELECT
			0 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH
END