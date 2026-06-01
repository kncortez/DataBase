/* =================================================
   SP:        SaveAutoPrepRouteReception
   Propósito: Se inserta o actualiza un estatus asociado al flujo de trabajo
   Autor:     Erick Hernandez
   Historia:  FDAPI-6249
   Fecha:     2026-05-29

=== CHANGELOG ============================
=========================================== */
ALTER PROCEDURE [dbo].[SaveAutoPrepRouteReception]
	@GuidesList NVARCHAR(MAX) = NULL,
	@ReferencesList NVARCHAR(MAX) = NULL,
	@AssistantsList NVARCHAR(MAX) = NULL,
	@CountryID VARCHAR(2),
	@RouteID INT,
	@StationID INT,
	@Token NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		
		IF (@GuidesList IS NULL OR LEN(LTRIM(RTRIM(@GuidesList))) = 0) AND 
		(@ReferencesList IS NULL OR LEN(LTRIM(RTRIM(@ReferencesList))) = 0)
		BEGIN
			SELECT-2 AS RowsAffected;
			RETURN
		END

		DECLARE @Today DATE = CAST(GETDATE() AS DATE)
		DECLARE @RowStatus_Active INT = 1;

		DECLARE @GuidesInRoutePrep TABLE(
			Serie	NCHAR(2),
			Number	NVARCHAR(20),
			Pieces	NVARCHAR(10)
		);

		INSERT INTO @GuidesInRoutePrep (Serie, Number, Pieces)
		SELECT DISTINCT RPD.Guide_Serie, RPD.Guide_Number, RPDP.PieceNumber
		FROM DeliveryBackOffice.dbo.RoutePreparation RP WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.RoutePreparationDetail RPD WITH (NOLOCK)
			ON RP.IdRoutePreparation = RPD.RoutePreparationId
		INNER JOIN DeliveryBackOffice.dbo.RoutePreparationDetailPiece RPDP WITH (NOLOCK)
			ON RPD.IdRoutePreparationDetail = RPDP.RoutePreparationDetailId
		WHERE RP.CatRouteId = @RouteID
		AND RP.DateRoutePreparation = @Today
		AND RP.RowStatus = @RowStatus_Active
		AND RPD.RowStatus = @RowStatus_Active

		IF @GuidesList IS NOT NULL AND LEN(LTRIM(RTRIM(@GuidesList))) > 0
		BEGIN
			DECLARE @Guides TABLE(
				Serie	NCHAR(2),
				Number	NVARCHAR(20),
				Pieces	NVARCHAR(10)
			);

			INSERT INTO @Guides (Serie, Number, Pieces)
			SELECT DISTINCT
				SUBSTRING(Item, 1, 2),
				SUBSTRING(Item, 3, CHARINDEX('-', Item) - 3),
				SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item) - CHARINDEX('-', Item))
			FROM DeliveryBackOffice.dbo.SplitUnlimited(@GuidesList, ',');
		END

		IF @ReferencesList IS NOT NULL AND LEN(LTRIM(RTRIM(@ReferencesList))) > 0
		BEGIN
			DECLARE @References TABLE (ID NVARCHAR(50));
			INSERT INTO @References (ID)
			SELECT DISTINCT Item
			FROM DeliveryBackOffice.dbo.SplitUnlimited(@ReferencesList, ',');

			INSERT INTO @Guides (Serie, Number, Pieces)
			SELECT DOP.GuideSerie, DOP.GuideNumber, DOP.NoPiece
			FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
				ON DOP.GuideSerie = DO.Guide_Serie AND DOP.GuideNumber = DO.Guide_Number
			WHERE DO.Ticket_Number IN (SELECT ID FROM @References);
		END

		-- Check if any guide in @Guides doesn't exist in RoutePrep table
		IF EXISTS (
			SELECT 1 FROM @Guides G
			WHERE NOT EXISTS (
				SELECT 1
				FROM @GuidesInRoutePrep GRP
				WHERE GRP.Serie = G.Serie
				AND GRP.Number = G.Number
				AND GRP.Pieces = G.Pieces
			)
		)
		BEGIN
			-- at least one guide doesn't exist in RoutePrep table
			SELECT-3 AS RowsAffected;
			RETURN 
		END

		-- Check the reverse: RoutePrep table has rows not in @Guides
		IF EXISTS (
			SELECT 1
			FROM @GuidesInRoutePrep GRP
			WHERE NOT EXISTS (
				SELECT 1 FROM @Guides G
				WHERE G.Serie = GRP.Serie
				AND G.Number = GRP.Number
				AND G.Pieces = GRP.Pieces
			)
		)
		BEGIN
			-- at least one guide doesn't exist in @Guides table
			SELECT -3 AS RowsAffected;
			RETURN 
		END

		-- save courier assistants
		IF @AssistantsList IS NOT NULL AND LEN(LTRIM(RTRIM(@AssistantsList))) > 0
		BEGIN
			DECLARE @Assistants TABLE (ID INT);
			INSERT INTO @Assistants (ID)
			SELECT DISTINCT CAST(Item AS INT)
			FROM DeliveryBackOffice.dbo.SplitUnlimited(@AssistantsList, ',');

			DECLARE @RoutePrepID INT = 0;

			SELECT @RoutePrepID = RP.IdRoutePreparation
			FROM DeliveryBackOffice.dbo.RoutePreparation RP WITH (NOLOCK)
			WHERE RP.CatRouteId = @RouteID
			AND RP.DateRoutePreparation = @Today
			AND RP.RowStatus = @RowStatus_Active

			INSERT INTO DeliveryBackOffice.dbo.CourierAssistantAutoPrepRoute
			(RoutePreparationId, CourierAssistantId, DateCreated, TokenCreated, RowStatus)
			SELECT @RoutePrepID, A.ID, GETDATE(), @Token, @RowStatus_Active
			FROM @Assistants A
			WHERE NOT EXISTS
			(
				SELECT 1
				FROM DeliveryBackOffice.dbo.CourierAssistantAutoPrepRoute CA WITH(NOLOCK)
				WHERE CA.RoutePreparationId = @RoutePrepID
				AND CA.CourierAssistantId = A.ID
				AND CA.RowStatus = @RowStatus_Active
			);
		END
		

		--enable flag for the manifest button on HD
		UPDATE DeliveryBackOffice.dbo.RoutePreparation
		SET IsAutoFinished = 1
		WHERE CatRouteId = @RouteID
		AND DateRoutePreparation = @Today
		AND RowStatus = @RowStatus_Active

		SELECT 1 AS RowsAffected;
	END TRY
	BEGIN CATCH
		SELECT -1 AS RowsAffected;
	END CATCH
END