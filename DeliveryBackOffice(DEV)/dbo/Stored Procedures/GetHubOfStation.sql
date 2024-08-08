
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-12-09>
-- Description:	< Obtiene el Hub de una estación >
-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2024-06-27>
-- Description:	<Se agrega parametro para filtrar por pais >
-- =============================================
CREATE PROCEDURE [dbo].[GetHubOfStation]
	@IdStation int,
	@IdCountry AS NVARCHAR(2) = 'GT'
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
			WHERE ISNULL(CS.CountryId, 'GT') = @IdCountry 
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
			WHERE ISNULL(CS.CountryId, 'GT')= @IdCountry
		) SH -- Station Hub
		WHERE
		SH.IdStation = @IdStation

END
