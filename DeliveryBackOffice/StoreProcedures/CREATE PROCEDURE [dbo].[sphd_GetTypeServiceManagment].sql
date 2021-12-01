USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sphd_GetCatTypeAlerts]    Script Date: 30/11/2021 09:02:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <2021-11-29>
-- Description:	<Devuelve el catalogo de los tipos de gestion de servicio>
-- =============================================
--
ALTER PROCEDURE [dbo].[sphd_GetTypeServiceManagment]
AS
BEGIN	
	select 
		IdTypeServiceManagment id,
		Name Name 
	from dbo.TypeServiceManagment
	where RowStatus='TRUE'
END
