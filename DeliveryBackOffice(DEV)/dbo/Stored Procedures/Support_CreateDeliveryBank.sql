/* =================================================
   SP:        dbo.Support_CreateDeliveryBank
   Propósito: Agregar un nuevo banco al catálogo DeliveryBank de Hermes.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5352
   Fecha:     2026-01-10
============================================
=== CHANGELOG ================================
2026-01-10 | Historia: FDAPI-5352 | Autor: IRVIN GONZALEZ |
=========================================== */

CREATE PROCEDURE dbo.Support_CreateDeliveryBank
(
    @Name        NVARCHAR(150),     
    @Acronym     NVARCHAR(50),      
    @Description NVARCHAR(250),     
    @IdCountry   NVARCHAR(10),      
    @PayingBank  INT,               

    @URL_logo    TEXT        = NULL,  
    @CardCode    NVARCHAR(50)= NULL,  
    @ACHCode     INT         = NULL   
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas de entrada
        IF ISNULL(@Name, '') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'El nombre del banco es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF ISNULL(@Acronym, '') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'El acrónimo del banco es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF ISNULL(@IdCountry, '') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'El país es obligatorio.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Validar no existencia previa del banco
        IF EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.DeliveryBank WITH (NOLOCK)
            WHERE [Name] = @Name
               OR Acronym = @Acronym
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El banco ya existe en el catálogo.' AS Mensaje,
                @Name AS Banco;
            RETURN;
        END

        -- PASO 3: Insertar banco en DeliveryBank
        INSERT INTO DeliveryBackOffice.dbo.DeliveryBank
        (
            [Name],
            Acronym,
            [Description],
            create_date,
            Id_status,
            Id_country,
            URL_logo,
            CardCode,
            ACHCode,
            PayingBank
        )
        VALUES
        (
            @Name,
            @Acronym,
            @Description,
            GETDATE(),
            1,             
            @IdCountry,
            @URL_logo,
            @CardCode,
            @ACHCode,
            @PayingBank
        );

        -- PASO 4: Respuesta final
        SELECT
            'Éxito' AS Estado,
            'El banco fue creado correctamente.' AS Mensaje,
            @Name       AS Banco,
            @Acronym    AS Acrónimo,
            @IdCountry  AS País,
            @URL_logo   AS URL_Logo,
            @CardCode   AS CardCode,
            @ACHCode    AS ACHCode,
            1           AS EstadoRegistro;

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


/* =================================================
EJEMPLO DE EJECUCIÓN
====================================================
EXEC dbo.Support_CreateDeliveryBank
     @Name        = 'BANCO ATLANTIDA',
     @Acronym     = 'BA',
     @Description = 'BANCO ATLANTIDA EL SALVADOR, S.A.',
     @IdCountry   = 'SV',
     @PayingBank  = 123,
     @URL_logo    = NULL,
     @CardCode    = NULL,
     @ACHCode     = NULL;
==================================================== */
