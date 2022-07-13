-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <20/06/2022>
-- Description:	<Obtiene el listado de Hubs>
-- =============================================
CREATE PROCEDURE [dbo].[GetHubs]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		IdHubLogistic Id
	   ,HubAbbreviation Hub
	FROM HubLogistics
END