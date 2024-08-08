CREATE PROCEDURE [dbo].[sps_set_finisTransfer]
    @TblListGuides AS TblListGuidesTransfer READONLY,
    @IdCourier INT,
    @CourierName VARCHAR(50),
    @DPI VARCHAR(15),
    @TokenCreated VARCHAR(100)
AS
BEGIN

    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb.dbo.#listGuidesEnabled', 'U') IS NOT NULL
        DROP TABLE #listGuidesEnabled;


    DECLARE @jsonResult NVARCHAR(MAX) = N'';
    DECLARE @errorMessage NVARCHAR(100);
	--DECLARE @IdManifest INT = (Select TOP 1  ID From [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] A WITH(NOLOCK)
	--											 Where ID_Courier = @IdCourier
	--											 Order By Date_Dispatched Desc)

    BEGIN TRANSACTION;

    BEGIN TRY

        -- INSERT INTO TEMPORARY TABLE
        SELECT [Guide_Serie],
               [Guide_Number],
               [IdIncidence],
               [IncidenceName],
               [Comentary]
        INTO #listGuidesEnabled
        FROM @TblListGuides;


        -- INSERT INTO TRANSFERLOG SO WE CAN MONITOR ALL THE GUIDES THAT WERE TRANSFER TO A EXPRESS CENTER

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
        UPDATE DeliveryBackOffice.dbo.DeliveryOrder
        SET StatusOrderId = 20
        FROM DeliveryBackOffice.dbo.DeliveryOrder do
            INNER JOIN #listGuidesEnabled lge
                ON lge.Guide_Number = do.Guide_Number
                   AND lge.Guide_Serie = do.Guide_Serie;

        -- Actualizar registros del detalle de manifiestos de entrega
        UPDATE dsd
        SET RowStatus = 0,
            TokenUpdated = @TokenCreated,
            DateUpdated = GETDATE(),
			StatusOrderId = 20
        FROM DeliveryBackOffice.dbo.DeliverySettlementDetail dsd
            INNER JOIN #listGuidesEnabled lge
                ON dsd.Guide_Serie = lge.Guide_Serie
                   AND lge.Guide_Number = dsd.Guide_Number
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement dobs
				ON dsd.ID_DeliveryOrderBySettlement = dobs.ID
		WHERE dsd.RowStatus = 1
		AND CAST(dobs.Date_Dispatched AS DATE) = CAST(GETDATE() AS DATE)
		AND dobs.ID_Courier = @IdCourier
		--AND dsd.ID_DeliveryOrderBySettlement IN (Select   ID From [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] A WITH(NOLOCK)
		--										 Where ID_Courier = @IdCourier
		--										 Order By Date_Dispatched Desc ) -- = @IdManifest

		UPDATE rpd 
		SET RowStatus = 0,
			TokenUpdated = @TokenCreated,
			DateUpdated = GETDATE()
		FROM RoutePreparationDetail rpd
		INNER JOIN #listGuidesEnabled lge
			ON rpd.Guide_Serie = lge.Guide_Serie
			AND rpd.Guide_Number = lge.Guide_Number
		INNER JOIN RoutePreparation rp
			ON rpd.RoutePreparationId = rp.IdRoutePreparation
		WHERE rpd.RowStatus = 1
			AND rp.DateRoutePreparation = CAST(GETDATE() AS DATE)

        -- Actualizar registros del detalle de servicios de devolución
        UPDATE std
        SET std.RowStatus = 0,
            std.TokenUpdated = @TokenCreated,
            std.DateUpdated = GETDATE()
        FROM dbo.SettlementByPickup stp WITH (NOLOCK)
            LEFT JOIN dbo.SettlementByPickupDetail std WITH (NOLOCK)
                ON std.SettlementByPickupId = stp.Id
                   AND std.RowStatus = 1
            INNER JOIN #listGuidesEnabled lge
                ON lge.Guide_Serie = std.GuideSerie
                   AND lge.Guide_Number = std.GuideNumber
            LEFT JOIN dbo.DeliveryOrderPiece dpc WITH (NOLOCK)
                ON dpc.GuideSerie = std.GuideSerie
                   AND dpc.GuideNumber = std.GuideNumber
            LEFT JOIN dbo.PieceByService pbs WITH (NOLOCK)
                ON pbs.GuidePieceId = dpc.GuidePiece
            LEFT JOIN dbo.ServiceManagement smg WITH (NOLOCK)
                ON smg.IdServiceManagement = pbs.ServiceManagmentId
        WHERE smg.SubTypeServiceManagmentId = 3;

        UPDATE pbs
        SET pbs.RowStatus = 0,
            pbs.TokenUpdated = @TokenCreated,
            pbs.DateUpdated = GETDATE()
        FROM dbo.SettlementByPickup stp WITH (NOLOCK)
            LEFT JOIN dbo.SettlementByPickupDetail std WITH (NOLOCK)
                ON std.SettlementByPickupId = stp.Id
                   AND std.RowStatus = 1
            JOIN #listGuidesEnabled lge
                ON lge.Guide_Serie = std.GuideSerie
                   AND lge.Guide_Number = std.GuideNumber
            LEFT JOIN dbo.DeliveryOrderPiece dpc WITH (NOLOCK)
                ON dpc.GuideSerie = std.GuideSerie
                   AND dpc.GuideNumber = std.GuideNumber
            LEFT JOIN dbo.PieceByService pbs WITH (NOLOCK)
                ON pbs.GuidePieceId = dpc.GuidePiece
            LEFT JOIN dbo.ServiceManagement smg WITH (NOLOCK)
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
            [RowStatus]
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
               1
        FROM #listGuidesEnabled lge;

    END TRY
    BEGIN CATCH

        SET @errorMessage =
        (
            SELECT CAST(ERROR_MESSAGE() AS VARCHAR(MAX)) AS ResultMessage
        );

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"IdResult": 500,' + '"Message":"' + @errorMessage + '"}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'VARCHAR(max)'),
                            1,
                            1,
                            ''
                        )
        );
        ROLLBACK TRANSACTION;

    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN

        COMMIT TRANSACTION;



        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"IdResult": 200,' + '"Message":"Guías Procesadas exitosamente."}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'VARCHAR(max)'),
                            1,
                            1,
                            ''
                        )
        );


    --- succesfull
    END;

    SELECT ('[' + @jsonResult + ']') jsonResult;

END;
