/* =================================================
   SP:        dbo.Support_UpdateHubInformation
   Propósito: Actualizar nombre, abreviación y descripción de un hub.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-6272
   Fecha:     2026-05-08
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateHubInformation
(
    @IdHubLogistic    INT,
    @HubName          NVARCHAR(50),
    @HubAbbreviation  NVARCHAR(5),
    @DescriptionCC    NVARCHAR(100),
    @TokenUpdated     NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas
        IF @IdHubLogistic IS NULL
        OR ISNULL(@HubName,'') = ''
        OR ISNULL(@HubAbbreviation,'') = ''
        OR ISNULL(@DescriptionCC,'') = ''
        OR ISNULL(@TokenUpdated,'') = ''
        BEGIN
            SELECT 
                'Error' AS Estado,
                'Todos los parámetros son obligatorios.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Validar existencia
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.HubLogistics WITH (NOLOCK)
            WHERE IdHubLogistic = @IdHubLogistic
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El hub logístico no existe.' AS Mensaje,
                @IdHubLogistic AS IdHubLogistic;
            RETURN;
        END

        -- PASO 3: Normalización de longitud
        DECLARE 
            @NormalizedHubName NVARCHAR(50),
            @NormalizedHubAbbreviation NVARCHAR(5),
            @NormalizedDescription NVARCHAR(100);

        SET @NormalizedHubName = LEFT(@HubName, 50);
        SET @NormalizedHubAbbreviation = UPPER(LEFT(@HubAbbreviation, 5));
        SET @NormalizedDescription = LEFT(@DescriptionCC, 100);

        -- PASO 4: Capturar valores ANTES
        DECLARE
            @PrevHubName NVARCHAR(50),
            @PrevHubAbbreviation NVARCHAR(5),
            @PrevDescription NVARCHAR(100);

        SELECT
            @PrevHubName = HubName,
            @PrevHubAbbreviation = HubAbbreviation,
            @PrevDescription = DescriptionCC
        FROM DeliveryBackOffice.dbo.HubLogistics WITH (NOLOCK)
        WHERE IdHubLogistic = @IdHubLogistic;

        -- PASO 5: Validar si ya tiene los mismos valores
        IF @PrevHubName = @NormalizedHubName
        AND @PrevHubAbbreviation = @NormalizedHubAbbreviation
        AND @PrevDescription = @NormalizedDescription
        BEGIN
            SELECT
                'Error' AS Estado,
                'El hub ya cuenta con los mismos valores solicitados.' AS Mensaje,
                @PrevHubName AS HubNameActual,
                @PrevHubAbbreviation AS HubAbbreviationActual,
                @PrevDescription AS DescriptionActual;
            RETURN;
        END

        -- PASO 6: UPDATE
        UPDATE DeliveryBackOffice.dbo.HubLogistics
        SET
            HubName         = @NormalizedHubName,
            HubAbbreviation = @NormalizedHubAbbreviation,
            DescriptionCC   = @NormalizedDescription,
            TokenUpdated    = @TokenUpdated,
            DateUpdated     = GETDATE()
        WHERE IdHubLogistic = @IdHubLogistic;

        -- PASO 7: Resultado final (ANTES / DESPUÉS)
        SELECT
            'Exito' AS Estado,
            'La información del hub fue actualizada correctamente.' AS Mensaje,
            @IdHubLogistic AS IdHubLogistic,

            -- Antes
            @PrevHubName AS HubName_Anterior,
            @PrevHubAbbreviation AS HubAbbreviation_Anterior,
            @PrevDescription AS Description_Anterior,

            -- Después
            @NormalizedHubName AS HubName_Nuevo,
            @NormalizedHubAbbreviation AS HubAbbreviation_Nueva,
            @NormalizedDescription AS Description_Nueva;

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
