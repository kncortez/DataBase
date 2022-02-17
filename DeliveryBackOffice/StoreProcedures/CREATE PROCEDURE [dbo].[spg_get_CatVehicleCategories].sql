USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_get_CatVehicle]    Script Date: 02/03/2021 15:25:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-02>
-- Description:	<Devuelve todos los vehiculos disponibles>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_CatVehicleCategories]
@value bit = 1
AS
BEGIN
	SELECT IdCatVehicleCategories, Name FROM CatVehicleCategories
	where RowStatus = 1
END