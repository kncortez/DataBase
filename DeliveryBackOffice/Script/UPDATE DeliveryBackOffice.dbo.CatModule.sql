USE [DeliveryBackOffice]
GO
/****** Object:  Update [dbo].[CatModule]    Script Date: 5/04/2021 10:31:23 ******/

-- =============================================
-- Author:		<Abne,Juarez>
-- Create date: <2020-04-05>
-- Description:	<Modificación del path de "express/cotizacion" a "express/crear-guia">
-- =============================================

UPDATE DeliveryBackOffice.dbo.CatModule SET ModPath = '/express/crear-guia' WHERE ModName = 'Crear Guías'