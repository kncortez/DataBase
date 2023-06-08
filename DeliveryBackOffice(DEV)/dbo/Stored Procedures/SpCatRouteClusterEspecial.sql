
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-19>
-- Description:	<Description, Catálogo de couster de rutas especiales TSE>
-- =============================================
CREATE PROCEDURE [dbo].[SpCatRouteClusterEspecial]


AS
BEGIN	SET NOCOUNT ON;

	SELECT DISTINCT
		RC.IdCatRouteCluster,
	    UPPER(RC.ClusterName) ClusterName
	FROM [dbo].[CatRouteCluster] RC WITH (NOLOCK)
	WHERE  RowStatus = 1
  
END