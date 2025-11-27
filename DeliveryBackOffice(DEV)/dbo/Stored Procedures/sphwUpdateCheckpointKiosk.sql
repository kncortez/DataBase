-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-11-20>
-- Description:	<Kiosko - Registra guia pasa a estado Depositada en buzon>
-- =============================================
-- Author:      <Brandon Pedroza>
-- Modified:    <2024-11-21>
-- Description: <Se agrega parametro para busqueda de estacion>
-- =============================================
-- Author:      <Juan Ramirez > <2025-10-02>
-- Description: <Se cambia de ser unicamente una guía a procesar, a procesar multiguias>
-- =============================================
CREATE PROCEDURE [dbo].[sphwUpdateCheckpointKiosk]
    @GuidesKiosko    AS dbo.GuidesKiosko READONLY,
    @IdCountry       AS NVARCHAR(2),
    @CodeOfReference INT
AS
BEGIN
    BEGIN TRANSACTION KioskoTran
    BEGIN TRY
        DECLARE @StatusOrderSolicitado AS INT,
                @StatusOrderGenerado AS INT,
                @StatusOrderDepositado AS INT,
                @StatusOrderRecepcionado AS INT,
                @IdStation AS INT;

        -- Obtener valores de los estados
        SET @StatusOrderDepositado =
        (
            SELECT StatusOrderId
            FROM StatusOrder WITH (NOLOCK)
            WHERE OrderDescription = 'Depositado en buzón'
        );
        SET @StatusOrderRecepcionado =
        (
            SELECT StatusOrderId
            FROM StatusOrder WITH (NOLOCK)
            WHERE OrderDescription = 'Recibido En Express Center'
        );
		SET @StatusOrderSolicitado =
        (
            SELECT StatusOrderId
            FROM StatusOrder WITH (NOLOCK)
            WHERE OrderDescription = 'Solicitado'
        );
        SET @StatusOrderGenerado =
        (
            SELECT StatusOrderId
            FROM StatusOrder WITH (NOLOCK)
            WHERE OrderDescription = 'Generado'
        );

        SET @IdStation = (SELECT TOP 1 IdStation FROM CatStation With(NOLOCK) WHERE CodeOfReference = @CodeOfReference)

        INSERT INTO [dbo].[DeliveryOrderDetail]
        (
            [Guide_Serie],
            [Guide_Number],
            [StatusOrderId],
            [UserCreated],
            [DateCreated],
            [DateCreatedInSystem],
            [Observations],
            [Temperature_Celsius],
            [PieceId],
            [RowStatus],
            [DeliveryAttemptId],
            [SystemOrigin],
            [StationId]
        )
        SELECT gk.Guide_Serie,
               gk.Guide_Number,
               @StatusOrderRecepcionado,
               'SYSTEM-KIOSK',
               GETDATE(),
               GETDATE(),
               NULL,
               NULL,
               NULL,
               1  ,
               NULL,
               NULL,
               @IdStation
          FROM @GuidesKiosko gk

        -- Actualizar DeliveryOrder
        UPDATE do
           SET do.StatusOrderId = @StatusOrderRecepcionado
          FROM DeliveryOrder do WITH(NOLOCK)
               INNER JOIN @GuidesKiosko gk 
                  ON do.Guide_Number = gk.Guide_Number
                 AND do.Guide_Serie = gk.Guide_Serie
                 AND do.SenderCountryId = gk.IdCountry;

        -- Insertar en DeliveryOrderDetail estado Depositado en Buzon
        INSERT INTO [dbo].[DeliveryOrderDetail]
        (
            [Guide_Serie],
            [Guide_Number],
            [StatusOrderId],
            [UserCreated],
            [DateCreated],
            [DateCreatedInSystem],
            [Observations],
            [Temperature_Celsius],
            [PieceId],
            [RowStatus],
            [DeliveryAttemptId],
            [SystemOrigin],
            [StationId]
        )
        SELECT gk.Guide_Serie,
               gk.Guide_Number,
               @StatusOrderDepositado,
               'SYSTEM-KIOSK',
               GETDATE(),
               GETDATE(),
               'Depositado en buzón',
               NULL,
               NULL,
               1  ,
               NULL,
               NULL,
               @IdStation
          FROM @GuidesKiosko gk

        -- Actualizar DeliveryOrder
         UPDATE do
            SET do.StatusOrderId = @StatusOrderDepositado
           FROM DeliveryOrder do WITH(NOLOCK)
                INNER JOIN @GuidesKiosko gk 
                   ON do.Guide_Number = gk.Guide_Number
                  AND do.Guide_Serie = gk.Guide_Serie
                  AND do.SenderCountryId = gk.IdCountry;

        COMMIT TRANSACTION KioskoTran

        SELECT 200                                                        AS 'StatusCode',
               'Informacion actualizada'                                  AS 'Description',
               'Hemos validado y recibido tus paquetes con éxito'         AS 'Message'

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION KioskoTran

        SELECT 400 AS 'StatusCode',
               'Error al registrar checkpoint' AS 'Description',
               ERROR_MESSAGE() AS 'ErrorMessage'
    END CATCH
END