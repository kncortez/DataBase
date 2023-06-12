-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-19>
-- Description:	<Description, Catálogo de rutas especiales TSE>
-- =============================================
CREATE PROCEDURE [dbo].[SpCatRoutEspecial]


AS
BEGIN
	

	DECLARE @IdTypeRoute Int = (Select IdTypeRoute From dbo.CatTypeRoute Where [Name] ='Especiales')

	SET NOCOUNT ON;

	Select 
		CR.IdRoute,
		UPPER(CR.CodeRoute) CodeRoute,
		CR.[Description],
		CR.IdTownship,	
		CR.IdTypeRoute,
		CR.[Zone]
	From [dbo].[CatRoute] CR WITH (NOLOCK)
	Where IdTypeRoute = @IdTypeRoute
  
END