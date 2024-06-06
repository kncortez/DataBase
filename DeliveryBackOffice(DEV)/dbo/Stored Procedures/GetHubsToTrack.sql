-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-11-29>
-- Description:	< Retorna los hubs existentes >
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-06-05>
-- Description:	< Filtra los Hubs por pais>
-- =============================================
CREATE PROCEDURE [dbo].[GetHubsToTrack]
				 @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN

		SELECT 
		DISTINCT 
			Hub 
		FROM 
			DeliveryBackOffice.dbo.DumpServiceCoverage DSC
		INNER JOIN DeliveryBackOffice.dbo.Township TW 
			ON TW.HeaderCode = DSC.HeaderCode
		INNER JOIN DeliveryBackOffice.dbo.Province PR
			ON PR.IdProvince = TW.IdProvince
		WHERE 
			DSC.Hub LIKE '___' AND IIF(PR.IdCountry IS NULL, 'GT', PR.IdCountry) = @IdCountry
	UNION -- Union con HubLogistics
		SELECT
		DISTINCT
			HL.HubAbbreviation Hub
		FROM
			[DeliveryBackOffice].[dbo].[HubLogistics] HL
		WHERE 
			HL.HubAbbreviation LIKE '___' AND IIF(IdCountry IS NULL, 'GT', IdCountry) = @IdCountry
	UNION
		SELECT
			'N/A' Hub

END
