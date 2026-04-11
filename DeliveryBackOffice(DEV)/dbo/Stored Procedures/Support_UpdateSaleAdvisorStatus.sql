/* =================================================
   SP:        dbo.Support_UpdateSaleAdvisorStatus
   Propósito: Activar o desactivar un SaleAdvisor mediante su estado
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-6040
   Fecha:     2026-04-10
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateSaleAdvisorStatus
(
    @IdSaleAdvisor    INT,
    @SaleAdvisorStatus BIT,       -- 1 ACTIVO / 0 INACTIVO
    @TokenUpdated     NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- VALIDACIONES
        IF @IdSaleAdvisor IS NULL 
        OR @SaleAdvisorStatus IS NULL
        OR ISNULL(@TokenUpdated,'') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'Todos los parámetros son obligatorios.' AS Mensaje;
            RETURN;
        END

        -- VALIDAR EXISTENCIA
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatSaleAdvisor WITH(NOLOCK)
            WHERE IdSaleAdvisor = @IdSaleAdvisor
        )
        BEGIN
            SELECT 'Error' AS Estado, 'El SaleAdvisor no existe.' AS Mensaje;
            RETURN;
        END

        -- CAPTURA ANTES
        DECLARE @PrevStatus BIT;

        SELECT @PrevStatus = SaleAdvisorStatus
        FROM DeliveryBackOffice.dbo.CatSaleAdvisor WITH(NOLOCK)
        WHERE IdSaleAdvisor = @IdSaleAdvisor;

        -- VALIDACIÓN: EVITAR UPDATE REDUNDANTE
        IF @PrevStatus = @SaleAdvisorStatus
        BEGIN
            SELECT 
                'Info' AS Estado,
                @IdSaleAdvisor AS IdSaleAdvisor,
                @PrevStatus AS Estado_ACTUAL,
                CASE 
                    WHEN @SaleAdvisorStatus = 1 THEN 'El SaleAdvisor ya se encuentra ACTIVO.'
                    ELSE 'El SaleAdvisor ya se encuentra INACTIVO.'
                END AS Mensaje;
            RETURN;
        END

        -- UPDATE
        UPDATE DeliveryBackOffice.dbo.CatSaleAdvisor
        SET 
            SaleAdvisorStatus = @SaleAdvisorStatus,
            TokenUpdated      = @TokenUpdated,
            DateUpdated       = GETDATE()
        WHERE IdSaleAdvisor = @IdSaleAdvisor;

        -- RESULTADO FINAL
        SELECT
            'Exito' AS Estado,
            @IdSaleAdvisor AS IdSaleAdvisor,
            @PrevStatus AS Estado_ANTES,
            @SaleAdvisorStatus AS Estado_DESPUES,
            CASE 
                WHEN @SaleAdvisorStatus = 1 THEN 'ACTIVO'
                ELSE 'INACTIVO'
            END AS EstadoDescripcion;

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