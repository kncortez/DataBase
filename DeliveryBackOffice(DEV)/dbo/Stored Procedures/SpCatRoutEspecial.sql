

-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-19>
-- Description:	<Description, Catálogo de rutas especiales TSE>
-- =============================================
CREATE PROCEDURE [dbo].[SpCatRoutEspecial]


AS
BEGIN
	

	DECLARE @IdTypeRoute INT = (SELECT IdTypeRoute FROM dbo.CatTypeRoute WHERE [Name] ='Especiales')

	SET NOCOUNT ON;

	SELECT 
		CR.IdRoute,
		UPPER(CR.CodeRoute) CodeRoute,
		CR.[Description],
		CR.IdTownship,	
		CR.IdTypeRoute,
		CR.[Zone]
	FROM [dbo].[CatRoute] CR WITH (NOLOCK)
	WHERE IdTypeRoute = @IdTypeRoute
	ORDER BY
		UPPER([CR].[CodeRoute]) ASC
  
END