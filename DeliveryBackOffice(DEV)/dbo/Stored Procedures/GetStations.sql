-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-06-03>
-- Description:	<Obtiene la información de las estaciones>
-- =============================================
-- =============================================
-- Author:		<CRISTIAN SUAZO>
-- Create date: <2024-05-28>
-- Description:	<Se agrega el parametro de Country para el filtrado por pais>
-- =============================================
CREATE PROCEDURE [dbo].[GetStations]
				 @Country NVARCHAR(2) = 'GT'
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IdStation [IdStation]
		, StationName [StationName]
		, CountryId [CountryId]
		, StationType [StationType]
		, HubLogisticId [HubLogisticId]
	FROM CatStation
	WHERE RowStatus = 1 AND StationType = 1
	AND ISNULL(CountryId, 'GT') = @Country
END