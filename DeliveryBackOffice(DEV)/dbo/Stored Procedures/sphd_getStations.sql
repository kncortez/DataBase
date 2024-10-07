
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-06>
-- Description: <Obtener informacion para el mostrar los Hub, para eventualmente generar el Reporte Liquidaciones Última Milla>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getStations]

@Country NVARCHAR(2) = 'GT'
AS
BEGIN
	SELECT
		cs.IdStation
	   ,cs.StationName
	FROM DeliveryBackOffice.dbo.CatStation cs
	INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb
	ON hb.IdHubLogistic = cs.HubLogisticId
	WHERE cs.RowStatus ='true' 
    AND cs.StationType =1 
    AND cs.CountryId = @Country
    AND hb.HubStatus = 1;
END