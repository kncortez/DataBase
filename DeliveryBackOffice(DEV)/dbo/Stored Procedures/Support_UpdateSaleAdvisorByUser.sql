/* =================================================
   SP:        DeliveryBackOffice.dbo.Support_UpdateSaleAdvisorByUser
   Propósito: Actualizar el SaleAdvisorId asociado a un usuario en SaleAdvisorbyUser.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5762
   Fecha:     2026-03-05
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateSaleAdvisorByUser
(
    @UserId        BIGINT,
    @SaleAdvisorId INT,
    @TokenUpdated  NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- VALIDAR PARAMETROS OBLIGATORIOS
        IF @UserId IS NULL OR @SaleAdvisorId IS NULL OR @TokenUpdated IS NULL
        BEGIN
            SELECT 
                'Error' AS Estado,
                'Todos los parámetros son obligatorios.' AS Mensaje;
            RETURN;
        END

        -- VALIDAR EXISTENCIA DEL USUARIO EN LA TABLA
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.SaleAdvisorbyUser WITH(NOLOCK)
            WHERE UserId = @UserId
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'El UserId proporcionado no existe en SaleAdvisorbyUser.' AS Mensaje;
            RETURN;
        END

        -- VALIDAR EXISTENCIA DEL SALE ADVISOR
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatSaleAdvisor WITH(NOLOCK)
            WHERE IdSaleAdvisor = @SaleAdvisorId
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'El SaleAdvisorId proporcionado no existe en CatSaleAdvisor.' AS Mensaje;
            RETURN;
        END

        -- CAPTURAR VALORES ANTES DEL CAMBIO
        DECLARE @SaleAdvisorId_ANTES INT;

        SELECT 
            @SaleAdvisorId_ANTES = SaleAdvisorId
        FROM DeliveryBackOffice.dbo.SaleAdvisorbyUser WITH(NOLOCK)
        WHERE UserId = @UserId;

        -- ACTUALIZAR INFORMACIÓN
        UPDATE DeliveryBackOffice.dbo.SaleAdvisorbyUser
        SET 
            SaleAdvisorId = @SaleAdvisorId,
            TokenUpdated  = @TokenUpdated,
            DateUpdated   = GETDATE()
        WHERE UserId = @UserId;

        -- CAPTURAR VALORES DESPUES DEL CAMBIO
        DECLARE @SaleAdvisorId_DESPUES INT;

        SELECT 
            @SaleAdvisorId_DESPUES = SaleAdvisorId
        FROM DeliveryBackOffice.dbo.SaleAdvisorbyUser WITH(NOLOCK)
        WHERE UserId = @UserId;

        -- RESULTADO FINAL ANTES / DESPUES
        SELECT 
            SAU.idSaleAdvisorbyUser,
            SAU.UserId,
            SAU.UserName,
            SAU.RowStatus,
            CA.SaleAdvisorDescription,
            CA.SaleAdvisorStatus,
            @SaleAdvisorId_ANTES   AS SaleAdvisorId_ANTES,
            @SaleAdvisorId_DESPUES AS SaleAdvisorId_DESPUES
        FROM DeliveryBackOffice.dbo.SaleAdvisorbyUser SAU WITH(NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.CatSaleAdvisor CA WITH(NOLOCK)
            ON CA.IdSaleAdvisor = SAU.SaleAdvisorId
        WHERE SAU.UserId = @UserId;

    END TRY
    BEGIN CATCH

        SELECT 
            'Error' AS Estado,
            ERROR_NUMBER()  AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE()    AS ErrorLinea;

        THROW;

    END CATCH

END
GO