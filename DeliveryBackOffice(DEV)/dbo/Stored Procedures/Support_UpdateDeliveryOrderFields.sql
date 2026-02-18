/* =================================================
   SP:        DeliveryBackOffice.dbo.Support_UpdateDeliveryOrderFields
   Propósito: Actualizar campos especificos de DeliveryOrder.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5483
   Fecha:     2026-01-31
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateDeliveryOrderFields
(
    @GuideSerie  NVARCHAR(2),
    @GuideNumber INT,

    @Ticket_Number                   NVARCHAR(150) = NULL,
    @Sender_FirstName                NVARCHAR(100) = NULL,
    @Sender_LastName                 NVARCHAR(100) = NULL,
    @Sender_Address                  NVARCHAR(200) = NULL,
    @Sender_Internal_Code            NVARCHAR(50) = NULL,

    @Receiver_FirstName              NVARCHAR(100) = NULL,
    @Receiver_LastName               NVARCHAR(100) = NULL,
    @Receiver_Address                NVARCHAR(600) = NULL,
    @Receiver_Alternant_FullName     NVARCHAR(200) = NULL,
    @Receiver_Alternant_Address      NVARCHAR(200) = NULL,

    @NameOfReceiver                  NVARCHAR(200) = NULL,
    @Contact_Instructions            NVARCHAR(200) = NULL,
    @IndicationsToSendOrigin         NVARCHAR(1500) = NULL,
    @IndicationsToSendDestination    NVARCHAR(1500) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY


        -- PASO 1: Validaciones básicas

        IF ISNULL(@GuideSerie, '') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'GuideSerie es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF @GuideNumber IS NULL
        BEGIN
            SELECT 'Error' AS Estado, 'GuideNumber es obligatorio.' AS Mensaje;
            RETURN;
        END


        -- PASO 2: Validar existencia de la guía

        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
            WHERE Guide_Serie = @GuideSerie
              AND Guide_Number = @GuideNumber
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'La guía no existe.' AS Mensaje,
                @GuideSerie AS GuideSerie,
                @GuideNumber AS GuideNumber;
            RETURN;
        END


        -- PASO 3: Actualización condicional
        --          SOLO se actualizan los campos enviados (NO se modifica el contenido)

        UPDATE DeliveryBackOffice.dbo.DeliveryOrder
        SET
            Ticket_Number = COALESCE(@Ticket_Number, Ticket_Number),
            Sender_FirstName = COALESCE(@Sender_FirstName, Sender_FirstName),
            Sender_LastName = COALESCE(@Sender_LastName, Sender_LastName),
            Sender_Address = COALESCE(@Sender_Address, Sender_Address),
            Sender_Internal_Code = COALESCE(@Sender_Internal_Code, Sender_Internal_Code),

            Receiver_FirstName = COALESCE(@Receiver_FirstName, Receiver_FirstName),
            Receiver_LastName = COALESCE(@Receiver_LastName, Receiver_LastName),
            Receiver_Address = COALESCE(@Receiver_Address, Receiver_Address),
            Receiver_Alternant_FullName = COALESCE(@Receiver_Alternant_FullName, Receiver_Alternant_FullName),
            Receiver_Alternant_Address = COALESCE(@Receiver_Alternant_Address, Receiver_Alternant_Address),

            NameOfReceiver = COALESCE(@NameOfReceiver, NameOfReceiver),
            Contact_Instructions = COALESCE(@Contact_Instructions, Contact_Instructions),
            IndicationsToSendOrigin = COALESCE(@IndicationsToSendOrigin, IndicationsToSendOrigin),
            IndicationsToSendDestination = COALESCE(@IndicationsToSendDestination, IndicationsToSendDestination)

        WHERE Guide_Serie = @GuideSerie
          AND Guide_Number = @GuideNumber;


        -- PASO 4: Respuesta final

        SELECT
            'Exito' AS Estado,
            'Los campos fueron actualizados correctamente.' AS Mensaje,
            @GuideSerie AS GuideSerie,
            @GuideNumber AS GuideNumber;

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
