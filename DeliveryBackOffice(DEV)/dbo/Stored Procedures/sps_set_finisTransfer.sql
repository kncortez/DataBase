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
            JOIN #listGuidesEnabled lge
                ON lge.Guide_Number = do.Guide_Number
                   AND lge.Guide_Serie = do.Guide_Serie;

        -- Actualizar registros del detalle de manifiestos de entrega
        UPDATE dsd
        SET RowStatus = 0,
            TokenUpdated = @TokenCreated,
            DateUpdated = GETDATE()
        FROM DeliveryBackOffice.dbo.DeliverySettlementDetail dsd
            JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement dos
                ON dos.ID = dsd.ID_DeliveryOrderBySettlement
            JOIN #listGuidesEnabled lge
                ON dsd.Guide_Serie = lge.Guide_Serie
                   AND lge.Guide_Number = dsd.Guide_Number;
        /*
				 AND ID_DeliveryOrderBySettlement = (
				 SELECT TOP 1 dos.ID FROM DeliveryBackOffice.dbo.DeliverySettlementDetail dsd
				 JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement dos ON dos.ID = dsd.ID_DeliveryOrderBySettlement
				 JOIN #listGuidesEnabled lge ON lge.Guide_Number= dsd.Guide_Number
				 ORDER BY dos.Route_Dispatched DESC
				 )
				 */

        -- Actualizar registros del detalle de servicios de devolución
        UPDATE std
        SET std.RowStatus = 0,
            std.TokenUpdated = @TokenCreated,
            std.DateUpdated = GETDATE()
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
        WHERE stp.IdCourier = @IdCourier
              AND smg.SubTypeServiceManagmentId = 3;

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
