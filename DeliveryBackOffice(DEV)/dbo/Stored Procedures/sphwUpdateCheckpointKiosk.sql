/* =================================================
   SP:        [dbo].[sphwUpdateCheckpointKiosk]
   Propósito: Kiosko - Registra guia pasa a estado Depositada en buzon
   Autor:     <Brando Pedroza>
   Historia:  <>
   Fecha:     <2024-11-20>
   === CHANGELOG ============================
2025-12-19 | Historia/épica: <FDAPI-4954> | Autor: Tito Garcia |
2025-10-02 | Historia/épica: <> | Autor: Juan Ramirez |
2024-11-21 | Historia/épica: <> | Autor: Brandon Pedroza |
=========================================== */
CREATE PROCEDURE [dbo].[sphwUpdateCheckpointKiosk]
    @GuidesKiosko    AS dbo.GuidesKiosko READONLY,
    @IdCountry       AS NVARCHAR(2),
    @CodeOfReference INT,
    @StationId INT = NULL
AS
BEGIN
    BEGIN TRANSACTION KioskoTran
    BEGIN TRY
        DECLARE @StatusOrderSolicitado AS INT,
                @StatusOrderGenerado AS INT,
                @StatusOrderDepositado AS INT,
                @StatusOrderRecepcionado AS INT,
                @IdStation AS INT;

        SET @StatusOrderDepositado = 51; --'Depositado en buzón' 
        SET @StatusOrderRecepcionado = 21; --'Recibido En Express Center'
		SET @StatusOrderSolicitado = 1; --'Solicitado'
        SET @StatusOrderGenerado = 15; --'Generado'
        		
		IF(@StationId = 0)
		BEGIN
			SET @StationId = NULL;
		END

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
               @StationId
          FROM @GuidesKiosko gk

        -- Actualizar DeliveryOrder
        UPDATE do
           SET do.StatusOrderId = @StatusOrderRecepcionado
          FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
               INNER JOIN @GuidesKiosko gk 
                  ON  do.Guide_Serie = gk.Guide_Serie
                    AND do.Guide_Number = gk.Guide_Number
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
               @StationId
          FROM @GuidesKiosko gk

        -- Actualizar DeliveryOrder
         UPDATE do
            SET do.StatusOrderId = @StatusOrderDepositado
           FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
                INNER JOIN @GuidesKiosko gk 
                    ON do.Guide_Serie = gk.Guide_Serie
                        AND do.Guide_Number = gk.Guide_Number
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