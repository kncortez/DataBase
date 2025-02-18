-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-09-01>
-- Description:	<Método para obtener el número de guía y la serie utilizando la referencia de la orden>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_GetGuideInfoHD]
@GuideReference NVARCHAR(150)
AS
BEGIN
    DECLARE @GuideSerie NVARCHAR(2);
    DECLARE @GuideNumber INT;
    DECLARE @CountPieces INT;
    SELECT TOP 1    @GuideSerie = [Guide_Serie],
                    @GuideNumber = [Guide_Number],
                    @CountPieces = [Pieces_Dry] + [Pieces_Cold]
    FROM DeliveryOrder WITH(NOLOCK) WHERE Ticket_Number = @GuideReference ORDER BY Preparation_Date DESC
    IF(@GuideSerie IS NOT NULL AND @GuideNumber IS NOT NULL)
    BEGIN
        SELECT 
                1						AS 'IdResult', 
                'Consulta Exitosa.'		AS 'Message',
                @GuideSerie             AS 'GuideSerie',
                @GuideNumber            AS 'GuideNumber',
                @CountPieces            AS 'CountPieces'
    END 
    ELSE
    BEGIN
        SELECT 
            409 AS 'IdResult', 
            'El número de orden ingresado no existe. Verifica que el número ingresado sea correcto.' AS 'Message'
    END
END;