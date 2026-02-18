/* =================================================
   SP:        DeliveryBackOffice.dbo.Support_ConsultaLinehaulRoute
   Propósito: Consultar información operativa de una ruta LH incluyendo preparación, contenedores y marchamos.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5578
   Fecha:     2026-02-14
=========================================== */

CREATE PROCEDURE Support_ConsultaLinehaulRoute
(
    @CodeRoute NVARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas
        IF ISNULL(@CodeRoute,'') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'CodeRoute es obligatorio.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Validar existencia de la ruta y obtener IdRoute
        DECLARE @IdRoute INT;

        SELECT 
            @IdRoute = CR.IdRoute
        FROM DeliveryBackOffice.dbo.CatRoute CR WITH(NOLOCK)
        WHERE CR.CodeRoute = @CodeRoute;

        IF @IdRoute IS NULL
        BEGIN
            SELECT 
                'Error' AS Estado,
                'La ruta proporcionada no existe.' AS Mensaje,
                @CodeRoute AS CodeRoute;
            RETURN;
        END


        -- CTEs COMUNES

        ;WITH UltimosPreparativos AS (
            -- Últimos 2 preparativos de la ruta
            SELECT TOP 2
                IdLinehaulRoutePreparation,
                CatRouteId,
                StationDispatchedId,
                CatLinehaulStatusId,
                DateLinehaulRoutePreparation,
                DateCreated,
                EndDateLinehaulRoutePreparation,
                TokenCreated
            FROM DeliveryBackOffice.dbo.LinehaulRoutePreparation WITH(NOLOCK)
            WHERE CatRouteId = @IdRoute
            ORDER BY DateCreated DESC
        ),
        UsuariosPorToken AS (
            -- Mapeo de tokens a usuarios
            SELECT 
                TL.TknIdToken, 
                IU.Username
            FROM DeliveryBackOffice.dbo.TokenLog TL WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.InternalUser IU WITH(NOLOCK)
                ON IU.RegisterUserID = TL.TknIdUser
        )

        -- PASO 3: Información de CatRoute
        SELECT 
            'CatRoute' AS Tabla,
            CR.IdRoute,
            CR.CodeRoute,
            CR.RowStatus,
            CR.CountryId,
            CT.IdTypeRoute,
            CT.Description
        FROM DeliveryBackOffice.dbo.CatRoute CR WITH(NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.CatTypeRoute CT WITH(NOLOCK)
            ON CT.IdTypeRoute = CR.IdTypeRoute
        WHERE CR.IdRoute = @IdRoute;


        -- PASO 4: Preparativos 

        ;WITH UltimosPreparativos AS (
            SELECT TOP 2
                IdLinehaulRoutePreparation,
                CatRouteId,
                StationDispatchedId,
                CatLinehaulStatusId,
                DateLinehaulRoutePreparation,
                DateCreated,
                EndDateLinehaulRoutePreparation,
                TokenCreated,
                DriverName
            FROM DeliveryBackOffice.dbo.LinehaulRoutePreparation WITH(NOLOCK)
            WHERE CatRouteId = @IdRoute
            ORDER BY DateCreated DESC
        ),
        UsuariosPorToken AS (
            SELECT 
                TL.TknIdToken, 
                IU.Username
            FROM DeliveryBackOffice.dbo.TokenLog TL WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.InternalUser IU WITH(NOLOCK)
                ON IU.RegisterUserID = TL.TknIdUser
        )
        SELECT 
            'LinehaulRoutePreparation' AS Tabla,
            UP.IdLinehaulRoutePreparation,
            UT.Username,
            CS.StationName, 
            CLS.StatusName, 
            UP.CatRouteId, 
            UP.DateLinehaulRoutePreparation, 
            UP.DateCreated, 
            UP.EndDateLinehaulRoutePreparation,
            UP.DriverName
        FROM UltimosPreparativos UP
        INNER JOIN UsuariosPorToken UT
            ON UT.TknIdToken = UP.TokenCreated
        INNER JOIN DeliveryBackOffice.dbo.CatStation CS WITH(NOLOCK)
            ON CS.IdStation = UP.StationDispatchedId
        INNER JOIN DeliveryBackOffice.dbo.CatLinehaulStatus CLS WITH(NOLOCK)
            ON CLS.IdCatLinehaulStatus = UP.CatLinehaulStatusId
        ORDER BY UP.DateCreated DESC;


        -- PASO 5: Contenedores 

        ;WITH UltimosPreparativos AS (
            SELECT TOP 2 IdLinehaulRoutePreparation
            FROM DeliveryBackOffice.dbo.LinehaulRoutePreparation WITH(NOLOCK)
            WHERE CatRouteId = @IdRoute
            ORDER BY DateCreated DESC
        ),
        UsuariosPorToken AS (
            SELECT 
                TL.TknIdToken, 
                IU.Username
            FROM DeliveryBackOffice.dbo.TokenLog TL WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.InternalUser IU WITH(NOLOCK)
                ON IU.RegisterUserID = TL.TknIdUser
        )
        SELECT 
            'LinehaulRoutePreparationContainer' AS Tabla,
            LRC.IdLinehaulRoutePreparationContainer,
            LRC.LinehaulRoutePreparationId,
            UT.Username,
            C.ContainerDescription,
            HL.HubAbbreviation,
            LRC.GuideQuantity,
            LRC.DryPieceQuantity,
            LRC.ColdPieceQuantity,
            LRC.RowStatus,
            LRC.DateCreated,
            CLS.StatusName
        FROM DeliveryBackOffice.dbo.LinehaulRoutePreparationContainer LRC WITH(NOLOCK)
        INNER JOIN UltimosPreparativos UP
            ON UP.IdLinehaulRoutePreparation = LRC.LinehaulRoutePreparationId
        INNER JOIN UsuariosPorToken UT
            ON UT.TknIdToken = LRC.TokenCreated
        INNER JOIN DeliveryBackOffice.dbo.Container C WITH(NOLOCK)
            ON C.IdContainer = LRC.ContainerId
        INNER JOIN DeliveryBackOffice.dbo.HubLogistics HL WITH(NOLOCK)
            ON HL.IdHubLogistic = LRC.HubDestinyId
        INNER JOIN DeliveryBackOffice.dbo.CatLinehaulStatus CLS WITH(NOLOCK)
            ON CLS.IdCatLinehaulStatus = LRC.CatLinehaulStatusId
        ORDER BY LRC.DateCreated, LRC.LinehaulRoutePreparationId;


        -- PASO 6: Marchamos 

        ;WITH UltimosPreparativos AS (
            SELECT TOP 2 IdLinehaulRoutePreparation
            FROM DeliveryBackOffice.dbo.LinehaulRoutePreparation WITH(NOLOCK)
            WHERE CatRouteId = @IdRoute
            ORDER BY DateCreated DESC
        ),
        UsuariosPorToken AS (
            SELECT 
                TL.TknIdToken, 
                IU.Username
            FROM DeliveryBackOffice.dbo.TokenLog TL WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.InternalUser IU WITH(NOLOCK)
                ON IU.RegisterUserID = TL.TknIdUser
        )
        SELECT 
            'LinehaulRoutePreparationCustomsMark' AS Tabla,
            LRM.LinehaulRoutePreparationId,
            LRM.CustomsMarkSerie,
            UT.Username,
            LRM.RowStatus,
            LRM.DateCreated
        FROM DeliveryBackOffice.dbo.LinehaulRoutePreparationCustomsMark LRM WITH(NOLOCK)
        INNER JOIN UltimosPreparativos UP
            ON UP.IdLinehaulRoutePreparation = LRM.LinehaulRoutePreparationId
        INNER JOIN UsuariosPorToken UT
            ON UT.TknIdToken = LRM.TokenCreated
        ORDER BY LRM.DateCreated DESC;

    END TRY

    BEGIN CATCH

        SELECT 
            'Error' AS Estado,
            'Ocurrio un error durante la ejecucion del procedimiento.' AS Mensaje,
            ERROR_NUMBER() AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE() AS ErrorLinea;

        THROW;

    END CATCH
END
GO