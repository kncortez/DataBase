-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <20/06/2022>
-- Description:	<Obtiene el listado de Hubs>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <20/06/2022>
-- Description: <Se agrega filtro por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[GetHubs]
 -- Add the parameters for the stored procedure here
(
  @IdCountry   NVARCHAR(2) = 'GT'
)
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
   WHERE IIF(IdCountry IS NULL, 'GT', IdCountry) = @IdCountry
END