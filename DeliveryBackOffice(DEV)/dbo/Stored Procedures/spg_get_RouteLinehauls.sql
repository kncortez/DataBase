-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-21>
-- Description:	<Devuelve información sobre las rutas Linehauls >
-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2022-09-21>
-- Description:	<Se agrega parametro para filtra por pais >
-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2022-09-21>
-- Description:	<Se agrega parametro para filtra por pais >
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RouteLinehauls]
	@IdCountry AS NVARCHAR(2)= 'GT'
AS
BEGIN
	SELECT DISTINCT
	 ctr.IdRoute
	 ,CodeRoute
      ,ctr.IdTypeRoute
      ,ctr.RowStatus	 
	  -- ctr.CodeRoute
   --   ,ctr.IdTypeRoute
   --   ,ctr.RowStatus
	  --,ctr.IdRoute
	FROM [DeliveryBackOffice].[dbo].[CatRoute] ctr WITH (NOLOCK)
	INNER JOIN Township Tw WITH (NOLOCK)
		ON ctr.IdTownship = TW.IdTownship
	INNER JOIN Province PR WITH(NOLOCK)
		ON PR.IdProvince = TW.IdProvince
	Where ctr.RowStatus = 1 AND ctr.IdTypeRoute=2
	AND PR.IdCountry = @IdCountry
	ORDER BY  ctr.CodeRoute
END