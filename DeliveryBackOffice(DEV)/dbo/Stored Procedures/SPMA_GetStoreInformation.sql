-- =============================================
-- Author:		<Oscar Rodriguez>
-- Create date: <2024-10-14>
-- Description:	<Obtener informacion de todos los puntos de ventas disponibles>
-- nombre, dirección, horarios, latitud, longitud
-- =============================================

CREATE PROCEDURE [dbo].[SPMA_GetStoreInformation]
@IdCountry	NVARCHAR(2) = 'GT'
AS
BEGIN
BEGIN TRY

	SELECT
		VPC.DescriptionOfClient					AS 'Name',
		VPC.Address								AS 'Address',
		ISNULL(VPC.Latitude,0)					AS 'Latitude',
		ISNULL(VPC.Longitude,0)					AS 'Longitude',
		ISNULL(VPC.AttentionSchedule,'')		AS 'AttentionSchedule'
	FROM DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
	WHERE VPC.CountryId = @IdCountry
		AND VPC.idkindofvpclient = 1
		AND VPC.StatusClient = 1

END TRY
BEGIN CATCH
	SELECT
	400 AS 'StatusCode',
	'Error al Obtener Tiendas' AS 'Description'
END CATCH;
END;
