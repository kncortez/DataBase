/* =================================================
   SP:        [dbo].[sps_set_finisTransfer]
   Propósito: <>
   Autor:     <>
   Historia:  <>
   Fecha:     <>
============================================
=== CHANGELOG ================================
-- 2025-12-22 | Historia/épica: FDAPI-4784 | Autor: Tito Garcia |
=========================================== */
CREATE PROCEDURE [dbo].[sps_set_finisTransfer]
    @TblListGuides AS TblListGuidesTransfer READONLY,
    @IdCourier INT,
    @CourierName VARCHAR(50),
    @DPI VARCHAR(15),
    @TokenCreated VARCHAR(100),
    @StationId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb.dbo.#listGuidesEnabled', 'U') IS NOT NULL
        DROP TABLE #listGuidesEnabled;

    DECLARE @jsonResult NVARCHAR(MAX) = N'';
    DECLARE @errorMessage NVARCHAR(100);
    DECLARE @Today DATE = GETDATE();
    		
    IF(@StationId = 0)
    BEGIN
        SET @StationId = NULL;
    END
   
    BEGIN TRANSACTION;

    BEGIN TRY

        SELECT [Guide_Serie],
               [Guide_Number],
               [IdIncidence],
               [IncidenceName],
               [Comentary]
        INTO #listGuidesEnabled
        FROM @TblListGuides;

        INSERT INTO DeliveryBackOffice.dbo.TransferLog
        (
            [IdCourier],
            [CourierName],
            [DPI],
            [IdIncidence],
            [IncidenceName],
            [Comentary],
            [GuideSerie],
            [GuideNumber],
            [TokenCreated],
            [DateCreated]
        )
        SELECT @IdCourier,
               @CourierName,
               @DPI,
               IIF(lge.IdIncidence = -1, NULL, lge.IdIncidence),
               IIF(lge.IdIncidence = -1, NULL, lge.IncidenceName),
               lge.Comentary,
               lge.Guide_Serie,
               lge.Guide_Number,
               @TokenCreated,
               GETDATE()
        FROM #listGuidesEnabled lge;

        --UPDATE ON DELIVERY ORDER TO STATUS "Traslado a Express Center"
        UPDATE do
        SET StatusOrderId = 20
        FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
            INNER JOIN #listGuidesEnabled lge
                ON lge.Guide_Serie = do.Guide_Serie
                    AND lge.Guide_Number = do.Guide_Number;

        -- Actualizar registros del detalle de manifiestos de entrega
        UPDATE dsd
        SET RowStatus = 0,
            TokenUpdated = @TokenCreated,
            DateUpdated = GETDATE(),
			StatusOrderId = 20
        FROM DeliveryBackOffice.dbo.DeliverySettlementDetail dsd WITH(NOLOCK)
            INNER JOIN #listGuidesEnabled lge
                ON dsd.Guide_Serie = lge.Guide_Serie
                   AND lge.Guide_Number = dsd.Guide_Number
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement dobs WITH(NOLOCK)
				ON dsd.ID_DeliveryOrderBySettlement = dobs.ID
		WHERE dsd.RowStatus = 1
            AND dobs.Date_Dispatched >= @Today
            AND dobs.Date_Dispatched < DATEADD(DAY, 1, @Today)
            AND dobs.ID_Courier = @IdCourier;

		UPDATE rpd 
		SET RowStatus = 0,
			TokenUpdated = @TokenCreated,
			DateUpdated = GETDATE()
		FROM DeliveryBackOffice.dbo.RoutePreparationDetail rpd WITH(NOLOCK)
		INNER JOIN #listGuidesEnabled lge
			ON rpd.Guide_Serie = lge.Guide_Serie
			    AND rpd.Guide_Number = lge.Guide_Number
		INNER JOIN DeliveryBackOffice.dbo.RoutePreparation rp WITH(NOLOCK)
			ON rpd.RoutePreparationId = rp.IdRoutePreparation
		WHERE rpd.RowStatus = 1
            AND rp.DateRoutePreparation >= @Today
            AND rp.DateRoutePreparation < DATEADD(DAY, 1, @Today);

        -- Actualizar registros del detalle de servicios de devolución
        UPDATE std
        SET std.RowStatus = 0,
            std.TokenUpdated = @TokenCreated,
            std.DateUpdated = GETDATE()
        FROM DeliveryBackOffice.dbo.SettlementByPickup stp WITH (NOLOCK)
            LEFT JOIN DeliveryBackOffice.dbo.SettlementByPickupDetail std WITH (NOLOCK)
                ON std.SettlementByPickupId = stp.Id
                   AND std.RowStatus = 1
            INNER JOIN #listGuidesEnabled lge
                ON lge.Guide_Serie = std.GuideSerie
                   AND lge.Guide_Number = std.GuideNumber
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dpc WITH (NOLOCK)
                ON dpc.GuideSerie = std.GuideSerie
                   AND dpc.GuideNumber = std.GuideNumber
            LEFT JOIN DeliveryBackOffice.dbo.PieceByService pbs WITH (NOLOCK)
                ON pbs.GuidePieceId = dpc.GuidePiece
            LEFT JOIN DeliveryBackOffice.dbo.ServiceManagement smg WITH (NOLOCK)
                ON smg.IdServiceManagement = pbs.ServiceManagmentId
        WHERE smg.SubTypeServiceManagmentId = 3;

        UPDATE pbs
        SET pbs.RowStatus = 0,
            pbs.TokenUpdated = @TokenCreated,
            pbs.DateUpdated = GETDATE()
        FROM DeliveryBackOffice.dbo.SettlementByPickup stp WITH (NOLOCK)
            LEFT JOIN DeliveryBackOffice.dbo.SettlementByPickupDetail std WITH (NOLOCK)
                ON std.SettlementByPickupId = stp.Id
                   AND std.RowStatus = 1
            INNER JOIN #listGuidesEnabled lge
                ON lge.Guide_Serie = std.GuideSerie
                   AND lge.Guide_Number = std.GuideNumber
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dpc WITH (NOLOCK)
                ON dpc.GuideSerie = std.GuideSerie
                   AND dpc.GuideNumber = std.GuideNumber
            LEFT JOIN DeliveryBackOffice.dbo.PieceByService pbs WITH (NOLOCK)
                ON pbs.GuidePieceId = dpc.GuidePiece
            LEFT JOIN DeliveryBackOffice.dbo.ServiceManagement smg WITH (NOLOCK)
                ON smg.IdServiceManagement = pbs.ServiceManagmentId
        WHERE smg.SubTypeServiceManagmentId = 3;

        --INSERT INTO TABLE DELIVERYORDERDETAIL SO WE CAN SETUP A NEW CHECKPOINT FOR TRACKING PURPOSES. 
        INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
        (
            [Guide_Serie],
            [Guide_Number],
            [StatusOrderId],
            [UserCreated],
            [DateCreated],
            [DateCreatedInSystem],
            [Observations],
            [Temperature_Celsius],
            [PieceId],
            [RowStatus],
            [StationId]
        )
        SELECT lge.Guide_Serie,
               lge.Guide_Number,
               20,
               @TokenCreated,
               GETDATE(),
               GETDATE(),
               NULL,
               NULL,
               NULL,
               1,
               @StationId
        FROM #listGuidesEnabled lge;

        DROP TABLE #listGuidesEnabled;

    END TRY
    BEGIN CATCH

        SET @errorMessage =
        (
            SELECT CAST(ERROR_MESSAGE() AS VARCHAR(MAX)) AS ResultMessage
        );

        SELECT
        500				    AS 'IdResult'
        , @errorMessage		AS 'Message'

        ROLLBACK TRANSACTION;

    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN

        COMMIT TRANSACTION;

        SELECT
        200				                        AS 'IdResult'
        , 'Guías Procesadas exitosamente.'		AS 'Message'

    END;

END;
