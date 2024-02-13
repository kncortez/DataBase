-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-11-17>
-- Description:	<Description,Obtener URL de reporte de historial de incdiencias de control de calidad>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_CCValidationHistory]
	
AS
BEGIN
	
	SET NOCOUNT ON;

     SELECT 200 IdResult,
                   [Name] Message,
                   Value 'URL'
				   FROM ConfigParams
            WHERE Name = 'CCValidationHistory';
END