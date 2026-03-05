/* =================================================
   SP:        dbo.Support_ConsultarSedePorFicha
   Propósito: Consultar a qué sede pertenece una ficha
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5678
   Fecha:     2026-02-06
================================================= */

CREATE PROCEDURE dbo.Support_ConsultarSedePorFicha
(
    @Ficha BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        --VALIDACION 1: Parametro obligatorio
        IF @Ficha IS NULL
        BEGIN
            SELECT 'Error' AS Estado,
                   'El parametro @Ficha es obligatorio.' AS Mensaje;
            RETURN;
        END

        -- VALIDACION 2: Existencia de la ficha 
        IF NOT EXISTS (
            SELECT 1 
            FROM DeliveryBackOffice.dbo.InternalUser WITH(NOLOCK)
            WHERE IdUser = @Ficha
        )
        BEGIN
            SELECT 'Error' AS Estado,
                   'La ficha ingresada no existe.' AS Mensaje;
            RETURN;
        END

        -- CONSULTA PRINCIPAL 
        SELECT
            'Exito' AS Estado,
            IU.IdUser           AS FICHA,
            IU.Username         AS USUARIO,
            IU.RegisterUserID   AS REGISTERID,
            RBUBS.RusRowStatus,
            RBUBS.StationId,
            CS.StationName      AS SEDE
        FROM DeliveryBackOffice.dbo.InternalUser IU WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.RolByUserBySystem RBUBS WITH (NOLOCK)
            ON IU.RegisterUserID = RBUBS.RusIdUser
        INNER JOIN DeliveryBackOffice.dbo.CatStation CS WITH (NOLOCK)
            ON CS.IdStation = RBUBS.StationId
        WHERE IU.IdUser = @Ficha;

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