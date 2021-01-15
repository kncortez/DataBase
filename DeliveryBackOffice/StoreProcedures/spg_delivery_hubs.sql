USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_get_visitPoints]    Script Date: 15/01/2021 08:26:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Cano,Carlos>
-- Create date: <2021-01-15>
-- Description:	<Obtiene catálogo de sedes Delivery>
-- =============================================
CREATE PROCEDURE [dbo].[spg_delivery_hubs]
	@IdCountry NVARCHAR(2)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [IdHubLogistic]
      ,[HubName]
      ,[HubStatus]
      ,[IdStation]
      ,[IdCountry]
      ,[IsGateway]
	FROM [DeliveryBackOffice].[dbo].[HubLogistics]
	WHERE IdCountry = @IdCountry
	AND HubStatus = 1
	ORDER BY HubName

END
GO


