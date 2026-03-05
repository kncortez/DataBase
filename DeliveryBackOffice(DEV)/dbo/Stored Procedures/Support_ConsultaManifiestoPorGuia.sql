/* =================================================
   SP:        dbo.Support_ConsultaManifiestoPorGuia
   Propósito: Consultar el manifiesto de ruta asociado a una guía.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5677
   Fecha:     2026-02-06
================================================= */

CREATE PROCEDURE dbo.Support_ConsultaManifiestoPorGuia
(
    @GuideNumber BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- VALIDACION PARAMETRO OBLIGATORIO 
        IF @GuideNumber IS NULL
        BEGIN
            SELECT 'Error' AS Estado,
                   'El parametro @GuideNumber es obligatorio.' AS Mensaje;
            RETURN;
        END

        -- VALIDAR EXISTENCIA DE LA GUIA EN CONTENEDOR 
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.LinehaulRoutePreparationContainerDetail WITH(NOLOCK)
            WHERE GuideSerie = 'FD'
              AND GuideNumber = @GuideNumber
        )
        BEGIN
            SELECT 'Error' AS Estado,
                   'La guia no esta asociada a ningun contenedor de ruta.' AS Mensaje;
            RETURN;
        END

        -- OBTENER EL ID DEL CONTENEDOR MAS RECIENTE 
        DECLARE @ContainerId BIGINT;

        SELECT TOP 1
            @ContainerId = LinehaulRoutePreparationContainerId
        FROM DeliveryBackOffice.dbo.LinehaulRoutePreparationContainerDetail WITH(NOLOCK)
        WHERE GuideSerie = 'FD'
          AND GuideNumber = @GuideNumber
        ORDER BY DateCreated DESC;

        -- CONSULTA FINAL DEL MANIFIESTO 
        SELECT
            'Exito' AS Estado,
            'FD'                               AS GuideSerie,
            @GuideNumber                       AS GuideNumber,
            LR.IdLinehaulRoutePreparationContainer,
            LR.LinehaulRoutePreparationId      AS NumeroManifiesto,
            LR.DateCreated                     AS FechaCreacionManifiesto,
            CLS.StatusDescription              AS EstadoManifiesto
        FROM DeliveryBackOffice.dbo.LinehaulRoutePreparationContainer LR WITH(NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.CatLinehaulStatus CLS WITH(NOLOCK)
            ON CLS.IdCatLinehaulStatus = LR.CatLinehaulStatusId
        WHERE LR.IdLinehaulRoutePreparationContainer = @ContainerId;

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