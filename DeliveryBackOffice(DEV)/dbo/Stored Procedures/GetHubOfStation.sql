-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-12-09>
-- Description:	< Obtiene el Hub de una estación >
-- =============================================
CREATE PROCEDURE [dbo].[GetHubOfStation]
	@IdStation int
AS
BEGIN
        SELECT 
        	HubAbbreviation
        FROM
		(
			SELECT
			DISTINCT
			CS.IdStation
			,CS.StationName
			,HL.HubAbbreviation
			FROM
			[DeliveryBackOffice].[dbo].[CatStation] CS
			JOIN
			[DeliveryBackOffice].[dbo].[HubLogistics] HL
			ON
			CS.HubLogisticId = HL.IdHubLogistic
			UNION
			SELECT
			DISTINCT
			CS.IdStation
			,CS.StationName
			,DSC.Hub
			FROM
			[DeliveryBackOffice].[dbo].[CatStation] CS
			JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPC
			ON
			CS.CodeOfReference = VPC.CodeOfReference
			JOIN
			[DeliveryBackOffice].[dbo].[Settlement] S
			ON
			VPC.IdSettlement = S.IdSettlement
			JOIN
			[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC
			ON
			S.IdSettlement = DSC.IdSettlement
		) SH -- Station Hub
		WHERE
		SH.IdStation = @IdStation

END
