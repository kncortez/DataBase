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
-- Author:      <Daniel Ramirez>
-- Create date: <2024-06-11>
-- Description: <Se agrega filtro por pais, por defecto >
-- =============================================
-- =============================================
-- Author:      <Walter Orozco>
-- Create date: <2025-05-21>
-- Description: <Se agrega la opción de búsqueda por medio de número de referencia.>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerByGuide]
	-- Add the parameters for the stored procedure here
	@GuideSerie NVARCHAR(2) = NULL,
	@GuideNumber INT = NULL,
    @IdCountry VARCHAR(2) = 'GT',
	@TicketNumber NVARCHAR(150) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CountGuideByTicketNumber AS INT  = 0;

	--Búsqueda por número de referencia
	IF(@TicketNumber IS NOT NULL AND @TicketNumber != '')
	BEGIN
		SET @CountGuideByTicketNumber = 
			(
				SELECT COUNT(DISTINCT IdCustomer) AS TotalClientes
				FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
				WHERE Ticket_Number = @TicketNumber
			);
		IF(@CountGuideByTicketNumber = 1)
		BEGIN
			SELECT TOP 1
				  @GuideSerie = Guide_Serie
				, @GuideNumber = Guide_Number
			FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
			WHERE Ticket_Number = @TicketNumber
		END
	END;

	--Si existe guía realizar el flujo
	IF (@GuideSerie IS NOT NULL AND @GuideSerie != '' AND @GuideNumber IS NOT NULL AND @GuideNumber > 0)
	BEGIN
		--Table 0 información cliente
		SELECT
			cu.IdCustomer Customer
		   ,vpc.IdVisitPointClient VisitPoint
		FROM DeliveryOrder do WITH (NOLOCK)
		LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
			ON vpc.CodeOfReference = do.Sender_ID
		INNER JOIN Customer cu WITH (NOLOCK)
			ON cu.IdCustomer = COALESCE(do.IdCustomer, vpc.CustomerID)
		WHERE do.Guide_Serie = @GuideSerie
		AND do.Guide_Number = @GuideNumber
		AND IIF(do.SenderCountryId IS NULL, 'GT', do.SenderCountryId) = @IdCountry;

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
		AND dsg.Guide_Number = @GuideNumber
		AND IIF(dsg.SenderCountryId IS NULL, 'GT', dsg.SenderCountryId) = @IdCountry;

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
		   ,ISNULL(do.IsReturn, 0) IsReturn
		FROM DeliveryOrder do WITH (NOLOCK)
		WHERE do.Guide_Serie = @GuideSerie
		AND do.Guide_Number = @GuideNumber
		AND IIF(do.SenderCountryId IS NULL, 'GT', do.SenderCountryId) = @IdCountry;
	END;
END