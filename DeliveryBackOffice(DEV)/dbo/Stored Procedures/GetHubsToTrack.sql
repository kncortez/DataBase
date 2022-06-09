-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-11-29>
-- Description:	< Retorna los hubs existentes >
-- =============================================
CREATE PROCEDURE [dbo].[GetHubsToTrack]
AS
BEGIN

		SELECT 
		DISTINCT 
			Hub 
		FROM 
			DeliveryBackOffice.dbo.DumpServiceCoverage DSC
		WHERE 
			Hub LIKE '___'
	UNION -- Union con HubLogistics
		SELECT
		DISTINCT
			HL.HubAbbreviation Hub
		FROM
			[DeliveryBackOffice].[dbo].[HubLogistics] HL
		WHERE 
			HL.HubAbbreviation LIKE '___'
	UNION
		SELECT
			'N/A' Hub

END
