
-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2021-12-23>
-- Description:	<Obtiene información de la preparación de entregas para una guía.>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-04>
-- Description:	<Cambio para uso de id de vehículo en vez de id de ruta.>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-19>
-- Description:	<Cambio para revisión de datos a nivel de pieza.>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-02-02>
-- Description:	< Cambio para uso de Ruta sobre Unidad .>
-- =============================================
CREATE PROCEDURE [dbo].[GetRoutePreparationDetail]
	@IdRoute INT,
	@Date DATE,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@GuidePiece SMALLINT
AS
BEGIN

	DECLARE @StatusOrderId TINYINT

	BEGIN TRY

		--TABLE 0 para saber si ya está asignado a una ruta
		SELECT TOP 1
			rp.IdRoutePreparation
		   ,rpd.IdRoutePreparationDetail
		   ,rpd.DateCreated
		   ,cr.CodeRoute 'CodeRoute'
		   ,rp.IsSimpliRoute
		   ,rp.CatRouteId 'IdRoute'
		   ,rp.DateRoutePreparation
		   ,rpd.IsCustomerReschedule
		FROM DeliveryBackOffice.dbo.RoutePreparationDetail rpd WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.RoutePreparation rp WITH(NOLOCK)
			ON rpd.RoutePreparationId = rp.IdRoutePreparation
		INNER JOIN DeliveryBackOffice.dbo.CatRoute cr WITH(NOLOCK)
			ON rp.CatRouteId = cr.IdRoute
		WHERE rp.DateRoutePreparation >= @Date
		AND rpd.RowStatus = 1
		AND Guide_Serie = @GuideSerie
		AND Guide_Number = @GuideNumber
		AND rp.RowStatus = 1
		ORDER BY rpd.DateCreated DESC

		--TABLE 1 para obtener el total de piezas e información de la guía
		SELECT
			@GuideSerie Guide_Serie
		   ,@GuideNumber Guide_Number
		   ,@GuidePiece Guide_Piece
		   ,COALESCE(do.Pieces_Dry, 0) + COALESCE(do.Pieces_Cold, 0) Pieces
		   ,(CASE WHEN do.[IsLastMileReturn] = 1 THEN do.[Sender_Department] ELSE do.[Receiver_Department] END) Department
		   ,(CASE WHEN do.[IsLastMileReturn] = 1 THEN do.[Sender_Town] ELSE do.[Receiver_Town] END) Town
		   ,(CASE WHEN do.[IsLastMileReturn] = 1 THEN do.[Sender_Address] ELSE do.[Receiver_Address] END) Address
		   ,Pieces_Dry Pieces_Dry
		   ,Pieces_Cold Pieces_Cold
		   ,(CASE WHEN dop.IsDry = 1 THEN 1 ELSE 0 END) Piece_Type
		FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
		ON do.Guide_Serie = dop.GuideSerie and do.Guide_Number = dop.GuideNumber
		WHERE do.Guide_Serie = @GuideSerie
		AND do.Guide_Number = @GuideNumber
		AND dop.NoPiece = @GuidePiece
		--AND do.StatusOrderId NOT IN (5,7,14,20,22,23,24,25)

		--TABLE 2 Validar que la guía no este en un estado no permitido 
		SET @StatusOrderId = (SELECT TOP 1
				dod.StatusOrderId
			FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WITH(NOLOCK)
			WHERE dod.Guide_Serie = @GuideSerie
			AND dod.Guide_Number = @GuideNumber
			ORDER BY dod.DateCreated DESC)

		IF (SELECT
					COUNT(1)
				FROM DeliveryBackOffice.dbo.StatusOrder SO WITH(NOLOCK)
				WHERE SO.StatusOrderId = @StatusOrderId
				AND SO.CatCheckpointTypeId = 3)
			= 0
		BEGIN
			--ES VALIDO
			SELECT
				1 StatusCode
			   ,'' Description
		END
		ELSE
		BEGIN
			--NO ES VALIDO
			SELECT
				0 StatusCode
			   ,so.OrderDescription Description
			FROM DeliveryBackOffice.dbo.StatusOrder so WITH(NOLOCK)
			WHERE so.StatusOrderId = @StatusOrderId
		END
	END TRY
	BEGIN CATCH

		--Insert en tabla de log
		INSERT INTO DeliveryBackOffice.dbo.[RoutePreparationLogError]
					([ErrorDescription]
					,[ErrorNumber]
					,[ErrorProcedure]
					,[ErrorLine]
					,[GuideSerie]
					,[GuideNumber]
					,[TokenCreated]
					,[DateCreated])
				VALUES
					(CAST(ERROR_MESSAGE() AS VARCHAR(300))
					,ERROR_NUMBER()
					,CAST(ERROR_PROCEDURE() AS VARCHAR(100))
					,ERROR_LINE()
					,@GuideSerie
					,@GuideNumber
					,'SYSTEM'
					,GETDATE())

		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
	END CATCH;
END