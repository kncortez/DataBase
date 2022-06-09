-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-04-12>
-- Description:	<Retorna las rutas de devolución>
-- =============================================
CREATE PROCEDURE [dbo].[get_RouteReturn]
AS
BEGIN

	select IdRoute Id, CodeRoute Name from CatRoute
	where upper(CodeRoute) like 'D%' and RowStatus = 1

END