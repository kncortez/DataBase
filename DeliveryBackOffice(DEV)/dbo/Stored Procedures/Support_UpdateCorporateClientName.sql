/* =================================================
   SP:        DeliveryBackOffice.dbo.Support_UpdateCorporateClientName
   Propósito: Actualizar nombre de un cliente corporativo en todas sus entidades relacionadas.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5484
   Fecha:     2026-01-31
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateCorporateClientName
(
    @CodeOfReference        INT,
    @NewClientName          NVARCHAR(100),
    @TokenUpdated           NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY


        -- PASO 1: Validaciones básicas

        IF @CodeOfReference IS NULL
        BEGIN
            SELECT 'Error' AS Estado, 'CodeOfReference es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF @NewClientName IS NULL 
        BEGIN
            SELECT 'Error' AS Estado, 'El nuevo nombre del cliente es obligatorio.' AS Mensaje;
            RETURN;
        END


        -- PASO 2: Validar existencia en VisitPointClient

        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.VisitPointClient WITH (NOLOCK)
            WHERE CodeOfReference = @CodeOfReference
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'No existe el cliente con el CodeOfReference indicado.' AS Mensaje,
                @CodeOfReference AS CodeOfReference;
            RETURN;
        END


        -- PASO 3: Obtener relaciones (VisitPoint → User → Person)

        DECLARE 
            @IdVisitPointClient INT,
            @UsrIdUser INT,
            @PerIdPerson INT;

        SELECT 
            @IdVisitPointClient = vpc.IdVisitPointClient,
            @UsrIdUser = rus.UsrIdUser,
            @PerIdPerson = per.PerIdPerson
        FROM DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.VisitPointByUser vpu WITH (NOLOCK)
            ON vpu.IdVisitPointClient = vpc.IdVisitPointClient
        INNER JOIN DeliveryBackOffice.dbo.RegisterUser rus WITH (NOLOCK)
            ON rus.UsrIdUser = vpu.RegisterUserID
        INNER JOIN DeliveryBackOffice.dbo.Person per WITH (NOLOCK)
            ON per.PerIdPerson = rus.UsrIdPerson
        WHERE vpc.CodeOfReference = @CodeOfReference;

        IF @UsrIdUser IS NULL OR @PerIdPerson IS NULL
        BEGIN
            SELECT
                'Error' AS Estado,
                'No fue posible resolver la relación completa VisitPoint → RegisterUser → Person.' AS Mensaje,
                @CodeOfReference AS CodeOfReference;
            RETURN;
        END


        -- PASO 4: Capturar valores ANTES

        DECLARE
            @PrevVPC_Name NVARCHAR(300),
            @PrevUsrNickName NVARCHAR(300),
            @PrevPerFirstName NVARCHAR(300);

        SELECT
            @PrevVPC_Name = DescriptionOfClient,
            @PrevVPC_Address = [Address]
        FROM DeliveryBackOffice.dbo.VisitPointClient WITH (NOLOCK)
        WHERE IdVisitPointClient = @IdVisitPointClient;

        SELECT
            @PrevUsrNickName = UsrNickName
        FROM DeliveryBackOffice.dbo.RegisterUser WITH (NOLOCK)
        WHERE UsrIdUser = @UsrIdUser;

        SELECT
            @PrevPerFirstName = PerFirstName
        FROM DeliveryBackOffice.dbo.Person WITH (NOLOCK)
        WHERE PerIdPerson = @PerIdPerson;


        -- PASO 5: UPDATE VisitPointClient

        UPDATE DeliveryBackOffice.dbo.VisitPointClient
        SET
            DescriptionOfClient = @NewClientName
        WHERE IdVisitPointClient = @IdVisitPointClient;


        -- PASO 6: UPDATE RegisterUser

        UPDATE DeliveryBackOffice.dbo.RegisterUser
        SET
            UsrNickName = @NewClientName,
            UsrTokenUpdated = @TokenUpdated,
            UsrDateUpdated = GETDATE()
        WHERE UsrIdUser = @UsrIdUser;


        -- PASO 7: UPDATE Person

        UPDATE DeliveryBackOffice.dbo.Person
        SET
            PerFirstName = @NewClientName,
            PerTokenUpdated = @TokenUpdated,
            PerDateUpdated = GETDATE()
        WHERE PerIdPerson = @PerIdPerson;


        -- PASO 8: Respuesta final

        SELECT
            'Exito' AS Estado,
            'El cliente corporativo fue actualizado correctamente.' AS Mensaje,
            @CodeOfReference AS CodeOfReference,

            -- Antes
            @PrevVPC_Name AS VisitPoint_Nombre_Anterior,
            @PrevUsrNickName AS RegisterUser_Nombre_Anterior,
            @PrevPerFirstName AS Person_Nombre_Anterior,

            -- Después
            @NewClientName AS Nombre_Nuevo;

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
