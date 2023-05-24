-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-19>
-- Description:	<Description, Catálogo de couster de rutas especiales TSE>
-- =============================================
CREATE PROCEDURE [dbo].[SpCatRouteClusterEspecial]


AS
BEGIN	SET NOCOUNT ON;

	Select Distinct
		RC.IdCatRouteCluster,
	    RC.ClusterName
	From [dbo].[CatRouteCluster] RC WITH (NOLOCK)
	Where  RowStatus = 1
  
END