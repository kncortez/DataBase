-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-27-12>
-- Description:	<Método para obtener el número de guía y la serie utilizando el identificador del usuario y el número de orden>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetGuideInfo]
@OrderNumber INT,
@CustomerId INT
AS
BEGIN
    DECLARE @GuideSerie NVARCHAR(2);
    DECLARE @GuideNumber INT;

    SELECT TOP 1 @GuideSerie = [Guide_Serie],
                    @GuideNumber = [Guide_Number]
    FROM DeliveryOrder WITH(NOLOCK) WHERE Order_Number = @OrderNumber AND IdCustomer = @CustomerId ORDER BY Preparation_Date DESC

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
            'El número de orden ingresado no existe o no está asociado a tu cuenta. Verifica que el número ingresado sea correcto.' AS 'Message'
    END
END;