CREATE PROCEDURE supportUpdateHubDestination
    @HubDestinationId INT
  , @GuideNumber INT
AS
BEGIN TRY
    --VERIFICAR QUE LA GUIA EXISTE
    IF NOT EXISTS
    (
        SELECT 1
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] WITH (NOLOCK)
        WHERE [Guide_Number] = @GuideNumber
    )
    BEGIN
        RAISERROR('No se encontro la guía', 16, 1);
        RETURN;
    END;
    -- si se encuentra realiza el update
    -- GUARDAR EL VALOR ANTIGUO

    DECLARE @OLDHubDestinationId INT;
    DECLARE @OLDGuide_Number INT;


    SELECT @OLDHubDestinationId = HubDestinationId
         , @OLDGuide_Number     = Guide_Number
    FROM DeliveryOrder WITH (NOLOCK)
    WHERE Guide_Number = @GuideNumber;

    --realiza update
    UPDATE DeliveryOrder
    SET HubDestinationId = @HubDestinationId
    WHERE Guide_Number = @GuideNumber;


    -- MOSTRAR EL VALOR ANTIGUO
    SELECT 'Valor Anterior'     AS Descripcion
         , @OLDHubDestinationId AS HubDestinationId
         , @OLDGuide_Number     AS GuideNumber;


    --mostrar el nuevo hubdestination
    SELECT 'Valor ACTUALIZADO' AS Descripcion
         , HubDestinationId
         , Guide_Number
    FROM DeliveryOrder WITH (NOLOCK)
    WHERE Guide_Number = @GuideNumber;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS RESPUESTA;
END CATCH;
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[supportUpdateHubDestination] TO [cvaldes]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[supportUpdateHubDestination] TO [cvaldes]
    AS [dbo];

