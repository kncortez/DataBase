USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[GetConfigurationOfService]    Script Date: 3/10/2022 10:23:06 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Andres Ruiz>
-- Create date: <2022-03-08>
-- Description:	< Obtiene la configuración actual de un servicio configurable desde base de datos >
-- =============================================
CREATE PROCEDURE [dbo].[GetConfigurationOfService]
	@ServiceId INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Config de tiempo de ejecución
	SELECT
		STC.StartingTime 'StartingTime'
		,STC.FinishingTime 'EndingTime'
		,STC.TimeStep 'TimeStep'
	FROM
		[DeliveryBackOffice].[dbo].[ServiceTimeConfiguration] STC
	WHERE
		STC.CatConfigurableServiceId = @ServiceId
		AND
		STC.RowStatus = 1

	-- Config de departamentos
	SELECT
		SPC.ProvinceId 'Province'
	FROM
		[DeliveryBackOffice].[dbo].[ServiceProvinceConfiguration] SPC
	WHERE
		SPC.CatConfigurableServiceId = @ServiceId
		AND
		SPC.RowStatus = 1

	-- Config de municipios
	SELECT
		STC.TownshipId 'Municipio'
	FROM
		[DeliveryBackOffice].[dbo].[ServiceTownshipConfiguration] STC
	WHERE
		STC.CatConfigurableServiceId = @ServiceId
		AND
		STC.RowStatus = 1

	-- Config de municipios bajo zona
	SELECT DISTINCT
		SZC.TownshipId 'Municipio'
		,T.TownshipName 'NombreMunicipio'
		,(SELECT STUFF(( 
							SELECT  
							',' + SZC2.Zone 
							FROM
								[DeliveryBackOffice].[dbo].[ServiceZoneConfiguration] SZC2
							WHERE
								SZC2.TownshipId = SZC.TownshipId
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
							) ) 'Zona'
	FROM
		[DeliveryBackOffice].[dbo].[ServiceZoneConfiguration] SZC
		JOIN
			[DeliveryBackOffice].[dbo].[Township] T
			ON
				SZC.TownshipId = T.IdTownship
	WHERE
		SZC.CatConfigurableServiceId = @ServiceId
		AND
		SZC.RowStatus = 1

END


GO


