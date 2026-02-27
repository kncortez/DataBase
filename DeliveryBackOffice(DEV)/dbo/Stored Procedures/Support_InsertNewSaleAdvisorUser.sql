/* =================================================
   SP:        Support_InsertNewSaleAdvisorUser
   Propósito: Insertar un nuevo vendedor asociado a usuario en SaleAdvisorbyUser.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5628
   Fecha:     2026-02-06
=========================================== */

CREATE PROCEDURE Support_InsertNewSaleAdvisorUser
(
    @UserId        BIGINT,
    @UserName      NVARCHAR(50),
    @SaleAdvisorId INT,
    @TokenCreated  NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas
        IF @UserId IS NULL
        BEGIN
            SELECT 'Error' AS Estado, 'UserId es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF ISNULL(@UserName,'') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'UserName es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF @SaleAdvisorId IS NULL
        BEGIN
            SELECT 'Error' AS Estado, 'SaleAdvisorId es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF ISNULL(@TokenCreated,'') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'TokenCreated es obligatorio.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Validar que no exista ya la relación
        IF EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.SaleAdvisorbyUser WITH(NOLOCK)
            WHERE UserId = @UserId
              AND SaleAdvisorId = @SaleAdvisorId
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'La relación usuario-vendedor ya existe.' AS Mensaje,
                @UserId AS UserId,
                @SaleAdvisorId AS SaleAdvisorId;
            RETURN;
        END

        -- PASO 3: Insertar registro
        INSERT INTO DeliveryBackOffice.dbo.SaleAdvisorbyUser
        (
            UserId,
            UserName,
            SaleAdvisorId,
            RowStatus,
            TokenCreated,
            DateCreated,
            TokenUpdated,
            DateUpdated
        )
        VALUES 
        (
            @UserId,
            @UserName,
            @SaleAdvisorId,
            1,
            @TokenCreated,
            GETDATE(),
            NULL,
            NULL
        );

        DECLARE @NewId BIGINT = SCOPE_IDENTITY();

        -- PASO 4: Respuesta final
        SELECT
            'Exito' AS Estado,
            'El vendedor fue asociado correctamente al usuario.' AS Mensaje,
            @NewId AS IdSaleAdvisorbyUser,
            @UserId AS UserId,
            @UserName AS UserName,
            @SaleAdvisorId AS SaleAdvisorId;

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
