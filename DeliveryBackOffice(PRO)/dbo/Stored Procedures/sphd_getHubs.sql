-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <2021-12-08>
-- Description:	<Regresa una lista de los hubs con su abreviatura correspondiente>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_getHubs] 
AS
BEGIN
	select IdHubLogistic Id,(HubAbbreviation+'-'+HubName) Name
	from DeliveryBackOffice.dbo.HubLogistics
	WHERE HubStatus = 1
	UNION
	select '-1' Id,
	'Todos los establecimientos' Name	
END
