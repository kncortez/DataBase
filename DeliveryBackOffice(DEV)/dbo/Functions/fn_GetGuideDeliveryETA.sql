
-- =============================================
-- Author:		<Andrés, Ruíz>
-- Create date: <17-04-2023>
-- Description:	< Función para determinar tiempo estimado de entrega de una guía basado en hub de origen y destino >
-- =============================================
-- =============================================
-- Author:		<Walter, Orozco>
-- Create date: <29-08-2024>
-- Description:	< Se agrega campos de país y cambios necesarios para soportar multipaís.>
-- =============================================
CREATE FUNCTION  [dbo].[fn_GetGuideDeliveryETA]
(
	@OriginProvince NVARCHAR(200),
	@OriginTownship NVARCHAR(200) = NULL,
	@OriginTownshipInputId INT = NULL,
	@OriginCountry NVARCHAR(2) = 'GT',
	@DestinyProvince NVARCHAR(200),
	@DestinyTownship NVARCHAR(200) = NULL,
	@DestinyTownshipInputId INT = NULL,
	@DestinyCountry NVARCHAR(2) = 'GT',
	@StartDate DATETIME = NULL
)
RETURNS DATE
AS
BEGIN

	-- Variables globales
	-- Por defecto NULL ya que si ocurre un inconveniente en el cálculo debe retornar NULL
	DECLARE @ResultDate DATE = NULL;
	DECLARE @DaysToAdd INT = NULL;
	-- 
	DECLARE @DefaultDate INT = 5;
	-- Fecha objetivo
	DECLARE @TargetDate DATETIME = NULL;
	IF(@StartDate IS NULL)
	BEGIN
	    SET @TargetDate = GETDATE();
	END
	ELSE
	BEGIN
	    SET @TargetDate = CAST(@StartDate AS DATE);
	END
	-- Tabla de coberturas de municipios por HUB
	DECLARE @TownshipCoverageByHub TABLE (
		CoverageHeaderCode NVARCHAR(50) NOT NULL,
		CoverageHubAbbreviation NVARCHAR(50) NOT NULL,
		CoverageHubId INT NULL
	);

	INSERT INTO @TownshipCoverageByHub
	(
	    [CoverageHeaderCode],
	    [CoverageHubAbbreviation]
	)
	SELECT 
		 [DSC].[HeaderCode]
		 ,MAX([HL].[HubAbbreviation])
	FROM
		[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC  WITH(NOLOCK) 
		INNER JOIN
			[DeliveryBackOffice].[dbo].[HubLogistics] HL  WITH(NOLOCK) 
			ON
				[DSC].[Hub] = HL.[HubAbbreviation]
				AND
				[HL].[HubStatus] = 1
	WHERE
		DSC.[RowStatus] = 1 AND [HL].[IdCountry] = @OriginCountry
	GROUP BY
		[DSC].[HeaderCode]

	UPDATE
		[TCBH]
	SET
		[TCBH].[CoverageHubId] = [HL].[IdHubLogistic]
	FROM
		@TownshipCoverageByHub TCBH
		INNER JOIN
			[DeliveryBackOffice].[dbo].[HubLogistics] HL  WITH(NOLOCK) 
			ON
				[TCBH].[CoverageHubAbbreviation] = [HL].[HubAbbreviation]

	-- Variables de flujo
	DECLARE @OriginProvinceId INT;
	DECLARE @OriginTownshipId INT;
	DECLARE @OriginCoverageHub INT;
	DECLARE @DestinyProvinceId INT;
	DECLARE @DestinyTownshipId INT;
	DECLARE @DestinyCoverageHub INT;


	-- Obtener identificación de departamento a procesar, en caso que no se obtenga correctamente por municipio
	-- Departamento origen
	SET @OriginProvinceId =
	(
		SELECT 
			TOP (1) 
				[Prv].[IdProvince] 
		FROM 
			[DeliveryBackOffice].[dbo].[Province] Prv  WITH(NOLOCK) 
		WHERE
			[Prv].[ProvinceName] = @OriginProvince 
			AND
			[Prv].[ProvinceStatus] = 1
			AND
			[Prv].[IdCountry]= @OriginCountry
		ORDER BY
			[Prv].[DateCreated] DESC
	)
	-- Departamento destino
	SET @DestinyProvinceId =
	(
		SELECT 
			TOP (1) 
				[Prv].[IdProvince] 
		FROM 
			[DeliveryBackOffice].[dbo].[Province] Prv  WITH(NOLOCK) 
		WHERE
			[Prv].[ProvinceName] = @DestinyProvince 
			AND
			[Prv].[ProvinceStatus] = 1
			AND
			[Prv].[IdCountry]= @DestinyCountry
		ORDER BY
			[Prv].[DateCreated] DESC
	)

	-- Obtener identificador del municipio a procesar, validando si municipio existe dentro de departamento
	-- Municipio de origen
	IF(ISNULL(@OriginTownshipInputId,0) = 0)
	BEGIN
		SET @OriginTownshipId =
		(
			SELECT 
				TOP (1) 
					[Twn].[IdTownship] 
			FROM 
				[DeliveryBackOffice].[dbo].[Township] Twn  WITH(NOLOCK) 
				INNER JOIN [DeliveryBackOffice].[dbo].[Province] Prv WITH(NOLOCK) 
					ON [Twn].[IdProvince] = [Prv].[IdProvince]
			WHERE
				[Twn].[TownshipName] = @OriginTownship  COLLATE Latin1_General_CI_AI 
				AND
				[Twn].[IdProvince] = @OriginProvinceId
				AND
				[Twn].[TownshipStatus] = 1
				AND
				[Prv].[IdCountry] = @OriginCountry
			ORDER BY
				[Twn].[DateCreated] DESC
		)
	END
	ELSE
    BEGIN
		SET @OriginTownshipId =
		(
			SELECT 
				TOP (1) 
					[Twn].[IdTownship] 
			FROM 
				[DeliveryBackOffice].[dbo].[Township] Twn  WITH(NOLOCK) 
				INNER JOIN [DeliveryBackOffice].[dbo].[Province] Prv WITH(NOLOCK) 
					ON [Twn].[IdProvince] = [Prv].[IdProvince]
			WHERE
				[Twn].[IdTownship] =  @OriginTownshipInputId
				AND
				[Twn].[IdProvince] = @OriginProvinceId
				AND
				[Twn].[TownshipStatus] = 1
				AND
				[Prv].[IdCountry] = @OriginCountry
			ORDER BY
				[Twn].[DateCreated] DESC
		)
    END
	-- Municipio destino
	IF(ISNULL(@DestinyTownshipInputId,0) = 0)
	BEGIN
		SET @DestinyTownshipId =
		(
			SELECT 
				TOP (1) 
					[Twn].[IdTownship] 
			FROM 
				[DeliveryBackOffice].[dbo].[Township] Twn  WITH(NOLOCK) 
				INNER JOIN [DeliveryBackOffice].[dbo].[Province] Prv WITH(NOLOCK) 
					ON [Twn].[IdProvince] = [Prv].[IdProvince]
			WHERE
				[Twn].[TownshipName] = @DestinyTownship  COLLATE Latin1_General_CI_AI 
				AND
				[Twn].[IdProvince] = @DestinyProvinceId
				AND
				[Twn].[TownshipStatus] = 1
				AND
				[Prv].[IdCountry] = @DestinyCountry
			ORDER BY
				[Twn].[DateCreated] DESC
		)
	END
	ELSE
    BEGIN
		SET @DestinyTownshipId =
		(
			SELECT 
				TOP (1) 
					[Twn].[IdTownship] 
			FROM 
				[DeliveryBackOffice].[dbo].[Township] Twn  WITH(NOLOCK) 
				INNER JOIN [DeliveryBackOffice].[dbo].[Province] Prv WITH(NOLOCK) 
					ON [Twn].[IdProvince] = [Prv].[IdProvince]
			WHERE
				[Twn].[IdTownship] =  @DestinyTownshipInputId
				AND
				[Twn].[IdProvince] = @DestinyProvinceId
				AND
				[Twn].[TownshipStatus] = 1
				AND
				[Prv].[IdCountry] = @DestinyCountry
			ORDER BY
				[Twn].[DateCreated] DESC
		)
    END

	--SELECT 
	--	@OriginProvinceId
	--	,@OriginTownshipId
	--	,@DestinyProvinceId
	--	,@DestinyTownshipId

	-- Tomar cabeceras en caso no se detecte correctamente municipios
	-- No se detecto correctamente municipio de origen
	IF(ISNULL(@OriginTownshipId, 0) = 0)
	BEGIN
	    SET @OriginTownshipId =
		(
			SELECT 
				TOP (1) 
					[Twn].[IdTownship] 
			FROM 
				[DeliveryBackOffice].[dbo].[Township] Twn  WITH(NOLOCK) 
				INNER JOIN [DeliveryBackOffice].[dbo].[Province] Prv WITH(NOLOCK) 
					ON [Twn].[IdProvince] = [Prv].[IdProvince]
			WHERE
				-- Cabeceras tienen codigo XX01
				[Twn].[HeaderCode] LIKE '%01'
				AND
				[Twn].[IdProvince] = @OriginProvinceId
				AND
				[Twn].[TownshipStatus] = 1
				AND
				[Prv].[IdCountry] = @OriginCountry
			ORDER BY
				[Twn].[DateCreated] DESC
		)
	END
	-- No se detecto correctamente municipio de destino
	IF(ISNULL(@DestinyTownshipId, 0) = 0)
	BEGIN
	    SET @DestinyTownshipId =
		(
			SELECT 
				TOP (1) 
					[Twn].[IdTownship] 
			FROM 
				[DeliveryBackOffice].[dbo].[Township] Twn  WITH(NOLOCK) 
			INNER JOIN [DeliveryBackOffice].[dbo].[Province] Prv WITH(NOLOCK) 
					ON [Twn].[IdProvince] = [Prv].[IdProvince]
			WHERE
				-- Cabeceras tienen codigo XX01
				[Twn].[HeaderCode] LIKE '%01'
				AND
				[Twn].[IdProvince] = @DestinyProvinceId
				AND
				[Twn].[TownshipStatus] = 1
				AND
				[Prv].[IdCountry] = @DestinyCountry
			ORDER BY
				[Twn].[DateCreated] DESC
		)
	END

	-- Obtener HUBS para proceso de cálculo de tiempo estimado de entrega
	-- Obtener hub de origen
	SET @OriginCoverageHub =
	(
		SELECT 
			TOP (1) 
				 [TCBH].[CoverageHubId]
		FROM 
			@TownshipCoverageByHub TCBH
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Township] Twn  WITH(NOLOCK) 
				ON
					[TCBH].[CoverageHeaderCode] = [Twn].[HeaderCode]
			INNER JOIN [DeliveryBackOffice].[dbo].[Province] Prv WITH(NOLOCK) 
					ON [Twn].[IdProvince] = [Prv].[IdProvince]
		WHERE
			[Twn].[IdTownship] = @OriginTownshipId
			AND
			[Prv].[IdCountry] = @OriginCountry
	)
	-- Obtener hub de destino
	SET @DestinyCoverageHub =
	(
		SELECT 
			TOP (1) 
				 [TCBH].[CoverageHubId]
		FROM 
			@TownshipCoverageByHub TCBH
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Township] Twn  WITH(NOLOCK) 
				ON
					[TCBH].[CoverageHeaderCode] = [Twn].[HeaderCode]
			INNER JOIN [DeliveryBackOffice].[dbo].[Province] Prv WITH(NOLOCK) 
					ON [Twn].[IdProvince] = [Prv].[IdProvince]
		WHERE
			[Twn].[IdTownship] = @DestinyTownshipId
			AND
			[Prv].[IdCountry] = @DestinyCountry
	)

	--SELECT 
	--	@OriginCoverageHub,
	--	@DestinyCoverageHub

	-- Obtener días por adicionar para tiempo estimado de entrega
	SET @DaysToAdd =
	(
		SELECT 
			TOP (1) 
				[DFDC].[DaysToAdd] 
		FROM 
			[DeliveryBackOffice].[dbo].[DayForDeliveryCoverage] DFDC  WITH(NOLOCK) 
		WHERE
			[DFDC].[HubLogisticsOrigin] = @OriginCoverageHub
			AND
			[DFDC].[HubLogisticsDestiny] = @DestinyCoverageHub
			AND
			[DFDC].[RowStatus] = 1
		ORDER BY
			[DFDC].[DateCreated] DESC
	)

	--SELECT 
	--	@DaysToAdd
	

	IF ( @DaysToAdd IS NULL )
	BEGIN
	    SET @ResultDate = CAST(DATEADD(DAY, @DefaultDate, ISNULL(@TargetDate, GETDATE())) AS DATE);
	END
	ELSE
    BEGIN
        SET @ResultDate = CAST(DATEADD(DAY, @DaysToAdd, ISNULL(@TargetDate, GETDATE())) AS DATE)
    END

	DECLARE @ValidDate BIT = 0;
	WHILE (ISNULL(@ValidDate, 0) = 0 AND @ResultDate IS NOT NULL)
	BEGIN

		IF ( EXISTS (SELECT [NLC].[NoLaborDate] FROM [DeliveryBackOffice].[dbo].[NoLaborCalendar] NLC  WITH(NOLOCK) WHERE [NLC].[NoLaborDate] = @ResultDate AND [NLC].[RowStatus] = 1 AND [NLC].[IdCountry] = @OriginCountry) )
		BEGIN

			SET @ResultDate = CAST(DATEADD(DAY, 1, ISNULL(@ResultDate, GETDATE())) AS DATE)

		END
		ELSE
        BEGIN

            SET @ValidDate = 1;

        END

	END

	RETURN @ResultDate;

END