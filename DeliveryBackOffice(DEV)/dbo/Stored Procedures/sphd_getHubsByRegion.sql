-- =============================================
-- Author:		<Ixchop,Alberto>
-- Create date: <2022-01-28>
-- Description:	<Obtiene el catalogo de hubs por region;lista de  hubs y lista de  regiones>
-- =============================================
CREATE PROCEDURE sphd_getHubsByRegion
AS
BEGIN
	--Hubs y Regiones relacionados
	SELECT  
		HubLogisticId HubId,
		HBR.RegionId RegionID
	FROM DBO.HubByRegion HBR
	LEFT JOIN DBO.HubLogistics HL ON  HBR.HubLogisticId=HL.IdHubLogistic  AND HL.HubStatus=1 
	LEFT JOIN DBO.CatRegion CR ON  CR.IdCatRegion=HBR.RegionId AND CR.RowStatus=1
	WHERE HBR.RowStatus=1;
	--Catalogo de HUBs
	SELECT 
		IdHubLogistic IdValue,
		HubAbbreviation+'-'+HubName NameValue
	FROM DBO.HubLogistics WHERE HubStatus=1;
	--Catalogo de Regiones
	SELECT 
		IdCatRegion IdValue,
		RegionName NameValue
	FROM DBO.CatRegion WHERE RowStatus=1;

END
