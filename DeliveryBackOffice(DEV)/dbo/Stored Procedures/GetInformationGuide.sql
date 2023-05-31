-- =============================================
-- Author:		<Eduardo López>
-- Create date: <2023-03-13>
-- Description:	<Devuelve dato de estado actual de la guía en cuestión>
-- =============================================
CREATE PROCEDURE [dbo].[GetInformationGuide]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN

  SELECT TOP 1
		dor.StatusOrderId
		,so.OrderDescription
		,dor.DateCreated
 FROM DeliveryOrderDetail dor WITH (NOLOCK) 
 INNER JOIN StatusOrder so
 ON dor.StatusOrderId = so.StatusOrderId
 WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber ORDER BY dor.DateCreated DESC

END