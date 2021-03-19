USE [DeliveryBackOffice]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-03-19>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
CREATE PROCEDURE [dbo].[get_CatTypeRoute]
AS
BEGIN
	SELECT * 
	FROM DeliveryBackOffice.dbo.CatTypeRoute
	WHERE RowStatus = 1
END
