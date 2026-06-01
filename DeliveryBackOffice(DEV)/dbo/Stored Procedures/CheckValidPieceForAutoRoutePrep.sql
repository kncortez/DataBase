/* =================================================
   SP:        [dbo].[CheckValidPieceForAutoRoutePrep]
   Propósito: Se verifica que el HUB este habilitado para estados predecesores, el estado de la guia pertenezca al proceso
   y devuelve la cantidad de piezas de la guia para el frontend. Todo esto antes de finalizar la recepción de la ruta con preparacion automatica.
   Autor:     Erick Hernandez
   Historia:  FDAPI-6247
   Fecha:     2026-05-28
   === CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[CheckValidPieceForAutoRoutePrep]
	@GuideSeries NVARCHAR(2) = NULL,
    @GuideNumber INT = NULL,
	@Reference NVARCHAR(30) = NULL,
	@RouteID INT,
	@StationID INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		
		DECLARE @DryPieces INT = 0;
		DECLARE @Serie NVARCHAR(2) = NULL;
		DECLARE @Number INT = 0;
		DECLARE @RowStatus_Active INT = 1;

		IF @Reference IS NOT NULL AND LEN(LTRIM(RTRIM(@Reference))) > 0
		BEGIN
			SELECT @Serie = DO.Guide_Serie,
			@Number = DO.Guide_Number,
			@DryPieces = DO.Pieces_Dry
			FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
			WHERE DO.Ticket_Number = @Reference
		END
		ELSE
		BEGIN
			SELECT @Serie = DO.Guide_Serie,
			@Number = DO.Guide_Number,
			@DryPieces = DO.Pieces_Dry
			FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
			WHERE DO.Guide_Serie = @GuideSeries
			AND DO.Guide_Number = @GuideNumber
		END

        IF @Serie IS NULL
        BEGIN
            SELECT 2 AS StatusCode, 'La guía no existe' AS Message, 1 AS NoPiece, 0 AS TotalPiecesDry;
            RETURN
        END

		--CHECK THE HUB
        DECLARE @Enabled TABLE (IsEnabled BIT)

		INSERT INTO @Enabled
		EXEC dbo.APIForzaDeliveryCourier_SetValidCheckpointToHub @StationID
		
		DECLARE @IsHubEnabledToCheckStatus BIT = (SELECT IsEnabled FROM @Enabled);

		IF @IsHubEnabledToCheckStatus = 1
		BEGIN
            --CHECK IF THE STATUS OF THE GUIDE BELONGS TO THE WORKFLOW
			DECLARE @Allowed TABLE (IsAllowed INT, CurrentStatus VARCHAR(50))
            DECLARE @CONFIRMCOURIERDISPATCH_WORKFLOWID INT = 72;

			INSERT INTO @Allowed
			EXEC dbo.CheckStatusForWorkflow @CONFIRMCOURIERDISPATCH_WORKFLOWID, @Serie, @Number;

			DECLARE @IsAllowed     INT         = (SELECT IsAllowed     FROM @Allowed)
			DECLARE @CurrentStatus VARCHAR(50) = (SELECT CurrentStatus FROM @Allowed)

			IF @IsAllowed < 1
			BEGIN
				SELECT 2 AS StatusCode, CONCAT('Guía en estado ', @CurrentStatus, ', no pertenece al flujo de trabajo.') AS Message, 1 AS NoPiece, 0 AS TotalPiecesDry
				RETURN
			END
		END

		DECLARE @Today DATE = CAST(GETDATE() AS DATE)
		IF NOT EXISTS(
			SELECT 1
			FROM DeliveryBackOffice.dbo.RoutePreparation RP WITH (NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.RoutePreparationDetail RPD WITH (NOLOCK)
				ON RP.IdRoutePreparation = RPD.RoutePreparationId
			WHERE RP.CatRouteId = @RouteID
			AND RP.DateRoutePreparation = @Today
			AND RP.RowStatus = @RowStatus_Active
			AND RPD.Guide_Serie = @Serie
			AND RPD.Guide_Number = @Number
			AND RPD.RowStatus = @RowStatus_Active
		)
		BEGIN
			SELECT 2 AS StatusCode, 'La guía no pertenece a esta ruta.' AS Message, 1 AS NoPiece, 0 AS TotalPiecesDry;
            RETURN
		END
		
        DECLARE @TotalPieces INT = 0;

		SELECT @TotalPieces = COUNT(RPDP.PieceNumber)
		FROM DeliveryBackOffice.dbo.RoutePreparationDetail RPD WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.RoutePreparationDetailPiece RPDP WITH (NOLOCK)
			ON RPD.IdRoutePreparationDetail = RPDP.RoutePreparationDetailId
		WHERE RPD.Guide_Serie = @Serie
		AND RPD.Guide_Number = @Number
		AND RPD.RowStatus = @RowStatus_Active
		AND RPDP.RowStatus = @RowStatus_Active

		SELECT 4 AS StatusCode, CONCAT('Faltan: ', @TotalPieces - 1, ' piezas por escanear') AS Message, @DryPieces AS TotalPiecesDry
	END TRY
	BEGIN CATCH
		SELECT -1 AS StatusCode, NULL AS Message, 0 AS NoPiece, 0 AS TotalPiecesDry
	END CATCH	
END