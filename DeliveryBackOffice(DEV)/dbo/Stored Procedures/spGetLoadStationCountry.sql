-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-06-03>
-- Description:	<Login - Método para la carga de estaciones por País.>
-- =============================================

CREATE PROCEDURE [dbo].[spGetLoadStationCountry]
	@pCountryId NVARCHAR(3)
AS
BEGIN

	SELECT IdStation, StationName, CodeOfReference FROM DeliveryBackOffice.dbo.CatStation
	WHERE StationType = 2
	AND CountryId = @pCountryId
	AND RowStatus = 1

END;