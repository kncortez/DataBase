-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-12-01>
-- Description:	< Retorna las alertas de una guía >
-- =============================================
CREATE PROCEDURE [dbo].[GetAlertsOfGuide]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@ServiceType BIGINT = 2
AS
BEGIN

	SELECT TOP 1
		CONVERT(nvarchar, DOA.DateCreated,103) 'DateAlert',
		CTA.AlertName 'TypeAlert',
		DOA.AlertDescription 'DetailAlert'
	FROM
	[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA
	JOIN
	[DeliveryBackOffice].[dbo].[CatTypeAlert] CTA
	ON
	DOA.AlertTypeId = CTA.IdCatTypeAlert
	WHERE
	DOA.GuideNumber = @GuideNumber
	AND
	DOA.GuideSerie = @GuideSerie
	AND
	DOA.ServiceTypeId = @ServiceType
	AND
	DOA.RowStatus = 1
	ORDER BY 
	DOA.DateCreated DESC;

END
