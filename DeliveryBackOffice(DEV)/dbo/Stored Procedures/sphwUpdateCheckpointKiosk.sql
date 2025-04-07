-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-11-20>
-- Description:	<Kiosko - Registra guia pasa a estado Depositada en buzon>
-- =============================================
-- Author:      <Brandon Pedroza>
-- Modified:    <2024-11-21>
-- Description: <Se agrega parametro para busqueda de estacion>
-- =============================================
CREATE PROCEDURE [dbo].[sphwUpdateCheckpointKiosk]
    @GuideNumber INT,
    @GuideSerie NVARCHAR(5),
    @IdCountry NVARCHAR(2),
	@CodeOfReference INT
AS
BEGIN
    BEGIN TRANSACTION
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

		-- Insertar en DeliveryOrderDetail estado Recepcionado en Express center
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
        VALUES
        (@GuideSerie,
         @GuideNumber,
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
        );

		-- Actualizar DeliveryOrder
        UPDATE DeliveryOrder
        SET StatusOrderId = @StatusOrderRecepcionado
        WHERE Guide_Number = @GuideNumber
              AND Guide_Serie = @GuideSerie;

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
         NULL,
		 @IdStation
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