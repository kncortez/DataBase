-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-02-16>
-- Description:	<Obtiene el listado de guías procesados en el día con simpliroute que este en estado terminal>
-- =============================================
-- =============================================
-- Author:		<Andres Ruiz>
-- Create date: <2022-04-23>
-- Description:	<Mejor manejo de datos por extraer de plataforma de Simpliroute>
-- =============================================
CREATE PROCEDURE [dbo].[GetExternalPlatformServicesToNullify]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Manejo de configuraciones
	DECLARE @AreProvincesConfigurated BIT = 0;
	DECLARE @AreTownshipsConfigurated BIT = 0;
	DECLARE @AreZonesConfigurated BIT = 0;

	-- Revisar existencia de configuración
	SET @AreProvincesConfigurated = ISNULL((
		SELECT
			TOP 1
				1
		FROM
			[DeliveryBackOffice].[dbo].[ServiceProvinceConfiguration] SPC
		WHERE
			SPC.CatConfigurableServiceId = 1
			AND
			SPC.RowStatus = 1
	),0)
	SET @AreTownshipsConfigurated = ISNULL((
		SELECT
			TOP 1
				1
		FROM
			[DeliveryBackOffice].[dbo].[ServiceTownshipConfiguration] STC
		WHERE
			STC.CatConfigurableServiceId = 1
			AND
			STC.RowStatus = 1
	),0)
	SET @AreZonesConfigurated = ISNULL((
		SELECT
			TOP 1
				1
		FROM
			[DeliveryBackOffice].[dbo].[ServiceZoneConfiguration] SZC
		WHERE
			SZC.CatConfigurableServiceId = 1
			AND
			SZC.RowStatus = 1
	),0)

	SELECT
		CONCAT(eps.GuideSerie
	   ,eps.GuideNumber) Guide
	   ,COUNT(1) Count
	FROM ExternalPlatformServiceLog eps WITH (NOLOCK)
	JOIN DeliveryOrder do WITH (NOLOCK)
		ON do.Guide_Serie = eps.GuideSerie
			AND do.Guide_Number = eps.GuideNumber
	LEFT JOIN ExtPlatServiceRelationshipWithGuide esrw WITH (NOLOCK)
		ON esrw.GuideSerie = eps.GuideSerie
			AND esrw.GuideNumber = eps.GuideNumber
	WHERE CAST(eps.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
	AND do.StatusOrderId IN (5, 7, 14, 22, 23, 24, 25, 30)
	AND (esrw.RowStatus IS NULL
	OR esrw.RowStatus = 1)
	GROUP BY eps.GuideSerie
			,eps.GuideNumber
	UNION
	SELECT
		CONCAT(eps.GuideSerie
	   ,eps.GuideNumber) Guide
	   ,COUNT(1) Count
	FROM ExternalPlatformServiceLog eps WITH (NOLOCK)
	JOIN DeliveryOrder do WITH (NOLOCK)
		ON do.Guide_Serie = eps.GuideSerie
			AND do.Guide_Number = eps.GuideNumber
	LEFT JOIN ExtPlatServiceRelationshipWithGuide esrw WITH (NOLOCK)
		ON esrw.GuideSerie = eps.GuideSerie
			AND esrw.GuideNumber = eps.GuideNumber
	JOIN
		[DeliveryBackOffice].[dbo].[Province] P WITH(NOLOCK)
		ON
			do.Receiver_Department = P.ProvinceName 
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[ServiceProvinceConfiguration] SPC WITH(NOLOCK)
		ON
			P.IdProvince = SPC.ProvinceId
	JOIN
		[DeliveryBackOffice].[dbo].[Township] TMun WITH(NOLOCK)
		ON
			do.Receiver_Town = TMun.TownshipName 
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[ServiceTownshipConfiguration] STC WITH(NOLOCK)
		ON
			TMun.IdTownship = STC.TownshipId
			AND
			STC.RowStatus = 0 -- Municipios anulados de configuración
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[ServiceTownshipConfiguration] STCAllowed WITH(NOLOCK) 
		ON
			TMun.IdTownship = STC.TownshipId
			AND
			STC.RowStatus = 1
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[ServiceZoneConfiguration] SZC WITH(NOLOCK)
		ON
			TMun.IdTownship = SZC.TownshipId
			AND
			do.Receiver_Zone = SZC.Zone
			AND
			SZC.RowStatus = 0 -- Zonas anuladas de configuración
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[ServiceZoneConfiguration] SZCZero WITH(NOLOCK) -- Zona 0 = cualquier zona de municipio
		ON
			STC.TownshipId = SZCZero.TownshipId
			AND
			SZCZero.Zone = 0
			AND
			SZCZero.RowStatus = 1
	WHERE CAST(eps.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
	AND esrw.RowStatus = 1
	AND
	SPC.IdServiceProvinceConfiguration IS NOT NULL
	AND
	(
		(
			@AreTownshipsConfigurated = 1
			AND
			STC.IdServiceTownshipConfiguration IS NOT NULL
			AND
			STCAllowed.IdServiceTownshipConfiguration IS NULL
		)
		OR
		(
			@AreZonesConfigurated = 1
			AND
			SZC.IdServiceZoneConfiguration IS NOT NULL
			AND
			SZCZero.IdServiceZoneConfiguration IS NULL
		)
	)
	GROUP BY eps.GuideSerie
			,eps.GuideNumber
	
END
