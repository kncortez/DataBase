/* =================================================
   SP:        [dbo].[NullifyPieceOfRoutePreparation]
   Propósito: Extracción de pieza de RoutePreparation
   Autor:     Andres Ruiz
   Historia:  ---
   Fecha:     2022-01-19

=== CHANGELOG ============================

2026-05-25 | Historia/épica: FDAPI-6115   | Autor: Caleb Loarca    | Hacer actualización de estado de guía a Inventario y registro en Warehouse.

=========================================== */

CREATE PROCEDURE [dbo].[NullifyPieceOfRoutePreparation]
	@IdRoutePreparation INT,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@Token NVARCHAR(50),
	@StationId INT
AS
BEGIN
    --- Conteo para verificar cantidad correcta de validaciones
    DECLARE @RModified INT = 0

    --- Variables para manejo de preparación de ruta
    DECLARE @IdRoutePreparationDetail INT;
    
    --- Variables para manejo de piezas
    DECLARE @GuidePieceExists BIT;
    DECLARE @PieceCount INT = 0;

    --- Variables para despliegue de errores
    DECLARE @FatalError INT = 0;

    --- Variable para warehouse
    DECLARE @RackPositionDefault NVARCHAR(20);
    DECLARE @MaxGuidePiece INT;                  -- ← NUEVO

    BEGIN TRANSACTION

        BEGIN TRY

            SELECT
                @IdRoutePreparationDetail = RPD.IdRoutePreparationDetail
            FROM
                [DeliveryBackOffice].[dbo].[RoutePreparation] RP
                JOIN
                    [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
                    ON
                        RP.IdRoutePreparation = RPD.RoutePreparationId
                        AND
                        RPD.RowStatus = 1
            WHERE
                RPD.Guide_Serie = @GuideSerie
                AND
                RPD.Guide_Number = @GuideNumber
                AND
                RP.IdRoutePreparation = @IdRoutePreparation
                AND
                RP.RowStatus = 1

            ---Asignación de Rack según la estación
            SELECT 
                @RackPositionDefault = RackPositionDefault 
            FROM DeliveryBackOffice.dbo.CatStation 
                WHERE idstation = @StationId;

            --- Verificar si se obtuvo el detalle referente a la guía de la preparación de ruta
            IF(@IdRoutePreparationDetail > 0)
            BEGIN
                
                --- Anular todas las piezas ya registradas de la preparación de ruta
                UPDATE [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece]
                SET
                    RowStatus = 0
                    ,TokenUpdated = @Token
                    ,DateUpdated = GETDATE()
                WHERE
                    RoutePreparationDetailId = @IdRoutePreparationDetail

                SET @PieceCount = COALESCE(@@ROWCOUNT, 0)
                IF @PieceCount > 0
                    SET @RModified = @RModified + 1

                --- Actualizar el detalle de la preparación de ruta
                UPDATE [DeliveryBackOffice].[dbo].[RoutePreparationDetail]
                SET
                    RowStatus = 0
                    ,TokenUpdated = @Token
                    ,DateUpdated = GETDATE()
                WHERE
                    IdRoutePreparationDetail = @IdRoutePreparationDetail
                    
                IF COALESCE(@@ROWCOUNT,0) > 0
                    SET @RModified = @RModified + 1

                --- Actualiza la guia para volver a inventario
                UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder]
                SET StatusOrderId = 10	---En Inventario
                WHERE Guide_Serie = @GuideSerie
                AND Guide_Number = @GuideNumber;

                IF COALESCE(@@ROWCOUNT,0) > 0
                    SET @RModified = @RModified + 1

                --- Insertar el nuevo estado a bitácora (una fila por cada pieza anulada)
                ;WITH Tally (n) AS (
                    SELECT 1
                    UNION ALL
                    SELECT n + 1 FROM Tally WHERE n < @PieceCount
                )
                INSERT [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
                (
                    [Guide_Serie],
                    [Guide_Number],
                    [StatusOrderId],
                    [UserCreated],
                    [DateCreated],
                    [DateCreatedInSystem],
                    [StationId]
                )
                SELECT @GuideSerie,
                       @GuideNumber,
                       10, --En Inventario
                       @Token,
                       GETDATE(),
                       GETDATE(),
                       @StationId
                FROM Tally
                WHERE EXISTS
                (
                    SELECT 1
                    FROM RoutePreparationDetail WITH (NOLOCK)
                    WHERE RoutePreparationId = @IdRoutePreparation
                          AND Guide_Serie = @GuideSerie
                          AND Guide_Number = @GuideNumber
                          AND CAST(DateCreated AS DATE) = CAST(GETDATE() AS DATE)
                )
                OPTION (MAXRECURSION 1000);

                        SET @RModified = @RModified + COALESCE(@@ROWCOUNT, 0)

                        --- Actualziar el estado de las piezas
                        UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
                        SET StatusOrderId = 10	---En Inventario
                        WHERE GuideSerie = @GuideSerie
                              AND GuideNumber = @GuideNumber;

                        IF COALESCE(@@ROWCOUNT,0) > 0
                        SET @RModified = @RModified + 1 

                --- Obtener el número máximo de piezas de la guía   ← NUEVO
                SELECT @MaxGuidePiece = DO.Pieces_Dry
                FROM   [DeliveryBackOffice].[dbo].[DeliveryOrder] AS DO
                WHERE  DO.Guide_Serie  = @GuideSerie
                       AND DO.Guide_Number = @GuideNumber;

                --- Insertar registros en almacén (una fila por cada pieza de la guía)   ← REEMPLAZADO
                ;WITH Tally (n) AS (
                    SELECT 1
                    UNION ALL
                    SELECT n + 1 FROM Tally WHERE n < @MaxGuidePiece
                )
                INSERT INTO [DeliveryBackOffice].[dbo].[Warehouse]
                (
                    Rack_Position,
                    Guide_Serie,
                    Guide_Number,
                    Dry,
                    Cold,
                    Active,
                    UserCreated,
                    DateCreated,
                    Guide_Piece,
                    StatusOrderId,
                    StationId
                )
                SELECT
                    @RackPositionDefault,
                    @GuideSerie,
                    @GuideNumber,
                    1,
                    0,
                    1,
                    @Token,
                    GETDATE(),
                    t.n,        -- número de pieza: 1, 2, 3 ... @MaxGuidePiece
                    10,         -- EN INVENTARIO
                    @StationId
                FROM Tally AS t
                OPTION (MAXRECURSION 1000);

                SET @RModified = @RModified + COALESCE(@@ROWCOUNT, 0);

            END
            ELSE
            BEGIN

                --- No se pudo recuperar el detalle de la preparación de ruta correspondiente a la guía a extraer
                SET @FatalError = 1;
            END

        END TRY
        BEGIN CATCH
            SELECT 
                0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description', 
                CONVERT(BIGINT, 0) AS 'NumTransferID'
            ROLLBACK TRANSACTION
        END CATCH;
    --- END TRANSACTION

    IF (@@TRANCOUNT > 0)
    BEGIN
        IF (@FatalError > 0)
        BEGIN
            IF (@FatalError = 1)
            BEGIN
                SELECT			  
                    0 AS 'StatusCode',
                    'Error al obtener la información de la preparación de ruta' AS 'Description', 
                    0 AS 'NumTransferID'
            END
            ROLLBACK TRANSACTION
        END
        ELSE IF (@RModified > 0)
        BEGIN
            SELECT			  
                200 AS 'StatusCode',
                'Registros guardados correctamente' AS 'Description', 
                @@TRANCOUNT AS 'NumTransferID'
            COMMIT TRANSACTION;
        END
        ELSE
        BEGIN
            SELECT			  
                0 AS 'StatusCode',
                'Registros no guardados' AS 'Description', 
                0 AS 'NumTransferID'
            ROLLBACK TRANSACTION
        END
    END
    ELSE
    BEGIN
        SELECT 
            0 AS 'StatusCode', 
            ERROR_MESSAGE() AS 'Description', 
            CONVERT(BIGINT, 0) AS 'NumTransferID'
    END
END;