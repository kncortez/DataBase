USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[get_CatTypeRoute]    Script Date: 19/03/2021 13:01:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-19>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
CREATE PROCEDURE [dbo].[get_Township]
AS
BEGIN


	select IdTownship, TownshipName, IdProvince from Township
	where TownshipStatus = 1


END
