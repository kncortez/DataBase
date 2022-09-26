-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <26/09/26>
-- Description:	<>
-- =============================================
CREATE PROCEDURE [dbo].[StateCatalogforServices] 

AS
BEGIN
	
	SET NOCOUNT ON;

   SELECT IdServiceStatus,
          Name 
   FROM dbo.CatServiceStatus
END