USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-06-03>
-- Description:	<Obtiene la información de las estaciones>
-- =============================================
CREATE PROCEDURE [dbo].[GetStations]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IdStation [IdStation]
		, StationName [StationName]
		, CountryId [CountryId]
		, StationType [StationType]
		, HubLogisticId [HubLogisticId]
	FROM CatStation
	WHERE RowStatus = 1
END
GO
