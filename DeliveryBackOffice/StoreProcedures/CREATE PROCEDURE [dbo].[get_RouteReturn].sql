USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[get_CatTypeRoute]    Script Date: 12/04/2021 11:03:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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