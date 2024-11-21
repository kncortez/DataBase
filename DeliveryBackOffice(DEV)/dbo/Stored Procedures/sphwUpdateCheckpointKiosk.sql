-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-11-20>
-- Description:	<Kiosko - Registra guia pasa a estado Depositada en buzon>
-- =============================================
CREATE PROCEDURE [dbo].[sphwUpdateCheckpointKiosk]
    @GuideNumber INT,
    @GuideSerie NVARCHAR(5),
    @IdCountry NVARCHAR(2)
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        DECLARE @StatusOrderDepositado AS INT,
                @StatusOrderSolicitado AS INT,
                @StatusOrderGenerado AS INT;

        -- Obtener valores de los estados
        SET @StatusOrderDepositado =
        (
            SELECT StatusOrderId
            FROM StatusOrder WITH (NOLOCK)
            WHERE OrderDescription = 'Depositado en buzón'
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

        -- Validar existencia de la guía
        IF NOT EXISTS
        (
            SELECT 1
            FROM DeliveryOrder WITH (NOLOCK)
            WHERE Guide_Serie = @GuideSerie
                  AND Guide_Number = @GuideNumber
                  AND SenderCountryId = @IdCountry
                  AND StatusOrderId IN ( @StatusOrderSolicitado, @StatusOrderGenerado )
        )
        BEGIN
            ROLLBACK TRANSACTION
            SELECT 400									AS 'StatusCode',
                   'El estado de la guía no es válido'	AS 'Description'
            RETURN
        END

        -- Insertar en DeliveryOrderDetail
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
            [SystemOrigin]
        )
        VALUES
        (@GuideSerie,
         @GuideNumber,
         @StatusOrderDepositado,
         'SYSTEM-KIOSK',
         GETDATE(),
         GETDATE(),
         'Depositado en buzón',
         NULL,
         NULL,
         1  ,
         NULL,
         NULL
        );

        -- Actualizar DeliveryOrder
        UPDATE DeliveryOrder
        SET StatusOrderId = @StatusOrderDepositado
        WHERE Guide_Number = @GuideNumber
              AND Guide_Serie = @GuideSerie;

        COMMIT TRANSACTION
        SELECT 200															AS 'StatusCode',
               'Informacion actualizada'									AS 'Description',
			   'El paquete ha sido depositado en el buzón correctamente'	AS 'Message',
               @GuideNumber													AS 'GuideNumber',
               @GuideSerie													AS 'GuideSerie';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SELECT 400 AS 'StatusCode',
               'Error al registrar checkpoint' AS 'Description',
               ERROR_MESSAGE() AS 'ErrorMessage'
    END CATCH
END