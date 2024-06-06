-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <2021-12-08>
-- Description:	<Regresa una lista de los hubs con su abreviatura correspondiente>
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Create date: <2024-05-27>
-- Description:	<Se agrega parametro para filtrar hubs por país>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_getHubs] 
	@IdCountry AS NVARCHAR(2)='GT'
AS
BEGIN
	select IdHubLogistic Id,(HubAbbreviation+'-'+HubName) Name
	from DeliveryBackOffice.dbo.HubLogistics
	WHERE HubStatus = 1
	AND IdCountry = @IdCountry
	UNION
	select '-1' Id,
	'Todos los establecimientos' Name	
END
