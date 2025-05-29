-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-27-12>
-- Description:	<Método para obtener el número de guía y la serie utilizando el identificador del usuario y el número de orden>
-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-02-04>
-- Description:	<Modificación para validar el número de telefono de la guía>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetGuideInfo]
@OrderNumber NVARCHAR(150),
@CustomerId INT,
@Phone NVARCHAR(15)
AS
BEGIN
    DECLARE @GuideSerie NVARCHAR(2);
    DECLARE @GuideNumber INT;
    SELECT TOP 1
    @GuideSerie = [Guide_Serie],
    @GuideNumber = [Guide_Number]
    FROM DeliveryOrder WITH(NOLOCK)
    WHERE Ticket_Number = @OrderNumber AND IdCustomer = @CustomerId AND LEN(Receiver_Phone) < 15 AND Receiver_Phone LIKE '%' + @Phone ORDER BY DateCreated DESC

    IF(@GuideSerie IS NOT NULL AND @GuideNumber IS NOT NULL)
    BEGIN
        SELECT 
                200						AS 'IdResult', 
                'Consulta Exitosa.'		AS 'Message',
                @GuideSerie               AS 'GuideSerie',
                @GuideNumber              AS 'GuideNumber'
    END 
    ELSE
    BEGIN
        SELECT 
            409 AS 'IdResult', 
            'El número de orden ingresado no existe, no está asociado a tu cuenta o el número de teléfono no es válido. Verifica que el número ingresado sea correcto.' AS 'Message'
    END
END;