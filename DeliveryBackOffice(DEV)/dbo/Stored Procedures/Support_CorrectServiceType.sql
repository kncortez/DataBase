/* =================================================
   SP:        dbo.Support_CorrectServiceType
   Propósito: Corregir el tipo de servicio en guías.
   Autor:     IGONZALEZ
   Historia:  FDAPI-5432
   Fecha:     2026-01-23
=========================================== */
CREATE PROCEDURE dbo.Support_CorrectServiceType
(
    @GuideSerie      NVARCHAR(2),    
    @GuideNumber     NVARCHAR(20),
    @NewTypeService  NVARCHAR(20),     
    @TokenUpdated    NVARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY


        -- PASO 1: Validaciones básicas

        IF ISNULL(@GuideSerie, '') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'La serie de la guía es obligatoria.' AS Mensaje;
            RETURN;
        END

        IF ISNULL(@GuideNumber, '') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'El GuideNumber es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF ISNULL(@NewTypeService, '') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'El TypeService es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF ISNULL(@TokenUpdated, '') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'El TypeService es obligatorio.' AS Mensaje;
            RETURN;
        END


        -- PASO 2: Validar existencia de la guía (SERIE + NÚMERO)

        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
            WHERE Guide_Serie  = @GuideSerie
              AND Guide_Number = @GuideNumber
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'La guía no existe.' AS Mensaje,
                @GuideSerie  AS GuideSerie,
                @GuideNumber AS GuideNumber;
            RETURN;
        END


        -- PASO 3: Obtener valor actual

        DECLARE @OldTypeService NVARCHAR(20);

        SELECT
            @OldTypeService = TypeService
        FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
        WHERE Guide_Serie  = @GuideSerie
          AND Guide_Number = @GuideNumber;


        -- PASO 4: Validar si el cambio es necesario

        IF @OldTypeService = @NewTypeService
        BEGIN
            SELECT
                'Info' AS Estado,
                'La guía ya cuenta con el TypeService solicitado.' AS Mensaje,
                @GuideSerie     AS GuideSerie,
                @GuideNumber    AS GuideNumber,
                @OldTypeService AS TypeServiceActual;
            RETURN;
        END


        -- PASO 5: UPDATE

        UPDATE DeliveryBackOffice.dbo.DeliveryOrder
        SET 
            Guide_Serie  = @GuideSerie,
            TypeService  = @NewTypeService,
            TokenUpdated = @TokenUpdated,
            DateUpdated  = GETDATE()
        WHERE Guide_Serie  = @GuideSerie
          AND Guide_Number = @GuideNumber;


        -- PASO 6: Respuesta final

        SELECT
            'Exito' AS Estado,
            'El tipo de servicio fue corregido correctamente.' AS Mensaje,
            @GuideSerie     AS GuideSerie,
            @GuideNumber    AS GuideNumber,
            @OldTypeService AS TypeService_Anterior,
            @NewTypeService AS TypeService_Nuevo;

    END TRY
    BEGIN CATCH

        SELECT 
            'Error' AS Estado,
            'Ocurrió un error durante la ejecución del procedimiento.' AS Mensaje,
            ERROR_NUMBER()  AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE()    AS ErrorLinea;

        THROW;

    END CATCH
END
GO
