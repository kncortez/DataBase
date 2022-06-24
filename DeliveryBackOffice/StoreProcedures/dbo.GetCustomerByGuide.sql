USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetCustomerByGuide]    Script Date: 23/06/2022 18:10:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <10/06/2022>
-- Description:	<Obtiene el cliente y visitpoint de una guía>
-- =============================================
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <21/06/2022>
-- Description:	<Se agrega otra trabla en donde se obtiene información de recolección de la guía>
-- =============================================
ALTER PROCEDURE [dbo].[GetCustomerByGuide]
	-- Add the parameters for the stored procedure here
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Table 0 información cliente
	SELECT
		cu.IdCustomer Customer
	   ,vpc.IdVisitPointClient VisitPoint
	FROM DeliveryOrder do WITH (NOLOCK)
	LEFT JOIN VisitPointClient vpc
		ON vpc.CodeOfReference = do.Sender_ID
	INNER JOIN Customer cu
		ON cu.IdCustomer = COALESCE(do.IdCustomer, vpc.CustomerID)
	WHERE do.Guide_Serie = @GuideSerie
	AND do.Guide_Number = @GuideNumber

	--Obtener hub origen
	DECLARE @Hub VARCHAR(5)
	DECLARE @HubId INT
	SELECT TOP 1
		@Hub = hub.HubAbbreviation
	   ,@HubId = hub.IdHubLogistic
	FROM dbo.DeliveryOrder dsg WITH (NOLOCK)
	LEFT JOIN dbo.Township twn WITH (NOLOCK)
		ON twn.IdTownship = dsg.SenderIdTownship
	LEFT JOIN dbo.Township twc WITH (NOLOCK)
		ON twc.TownshipName = dsg.Sender_Town
	LEFT JOIN (SELECT
			CV.HeaderCode
		   ,MAX(CV.Hub) HUB
		FROM dbo.DumpServiceCoverage CV WITH (NOLOCK)
		GROUP BY CV.HeaderCode) HB
		ON HB.HeaderCode = ISNULL(twn.HeaderCode, twc.HeaderCode)
	LEFT JOIN dbo.HubLogistics hub WITH (NOLOCK)
		ON hub.HubAbbreviation = HB.HUB

	WHERE dsg.Guide_Serie = @GuideSerie
	AND dsg.Guide_Number = @GuideNumber;

	--Table 1 Información de la guía
	SELECT
		CONCAT(ISNULL(do.Sender_FirstName, ''), IIF(do.Sender_FirstName IS NULL, '', IIF(do.Sender_LastName IS NULL, '', ' ')), ISNULL(do.Sender_LastName, '')) SenderName
	   ,do.Sender_Address SenderAddress
	   ,do.Sender_Phone SenderPhone
	   ,@Hub SenderHub
	   ,@HubId SenderHubId
	   ,do.SenderIdTownship SenderTownship
	   ,do.Sender_Lat SenderLatitude
	   ,do.Sender_Lng SenderLongitude

	FROM DeliveryOrder do WITH (NOLOCK)
	WHERE do.Guide_Serie = @GuideSerie
	AND do.Guide_Number = @GuideNumber

END
