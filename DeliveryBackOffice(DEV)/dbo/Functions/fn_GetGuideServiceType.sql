-- =============================================
-- Author:		<Andrés, Ruíz>
-- Create date: <10-02-2023>
-- Description:	< Función para determinar tipo de servicio en base a datos de una guía, o verificar si tipo de servicio de guía es valido para condiciones de la guía >
-- =============================================
CREATE FUNCTION  [dbo].[fn_GetGuideServiceType]
(
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@StatedTypeService NVARCHAR(5) = NULL,
	@StatedCustomerId INT = NULL
)
RETURNS NVARCHAR(5)
AS
BEGIN

	-- Variables globales
	DECLARE @DefaultServiceType NVARCHAR(5) = 'STD';

	-- Control de datos para buscar tipo de servicio
	DECLARE @CustomerId INT
	DECLARE @VisitPointClientId INT
	DECLARE @HasCollectOnDelivery BIT

	-- Control de flujo de retorno de tipo de servicio
	DECLARE @FinalTypeServiceFound BIT
	DECLARE @FinalTypeService NVARCHAR(50)

	-- Obtener datos desde la guía
	SELECT
		@CustomerId = DO.IdCustomer,
		@VisitPointClientId = DO.Sender_ID,
		@HasCollectOnDelivery = (CASE WHEN ISNULL(DO.Collect_OnDelivery, 0) > 0 THEN 1 ELSE 0 END)
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
	WHERE
		DO.Guide_Serie = @GuideSerie
		AND
		DO.Guide_Number = @GuideNumber

	-- Fijar ID de cliente con el proporcionado
	IF(ISNULL(@StatedCustomerId, 0) != 0)
	BEGIN

		SET @CustomerId = @StatedCustomerId

	END

	DECLARE @RateToSearch INT

	-- Obtener tarifario de punto de visita, si es posible
	SELECT
		TOP 1
			@RateToSearch = RBC.RbcIdRate
	FROM
		[DeliveryBackOffice].[dbo].[RatebyCustomer] RBC WITH(NOLOCK)
	WHERE
		RBC.RbcIdCustomer = @CustomerId
		AND
		RBC.RbcCodeOfReference = @VisitPointClientId
		AND
		RBC.RbcRowStatus = 1
	ORDER BY
		RBC.RbcDateCreated DESC

	-- No se obtuvo tarifario especifico de punto de visita
	IF(ISNULL(@RateToSearch, 0) = 0)
	BEGIN

		-- Obtener tarifario de cliente
		SELECT
			TOP 1
				@RateToSearch = RBC.RbcIdRate
		FROM
			[DeliveryBackOffice].[dbo].[RatebyCustomer] RBC WITH(NOLOCK)
		WHERE
			RBC.RbcIdCustomer = @CustomerId
			AND
			RBC.RbcRowStatus = 1
		ORDER BY
			RBC.RbcDateCreated DESC

	END

	-- Si tipo de servicio existe dentro de tarifa
	SELECT
		TOP 1
			@FinalTypeServiceFound = 1
	FROM
		[DeliveryBackOffice].[dbo].[RateData] RD WITH(NOLOCK)
		INNER JOIN
			[DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK)
			ON
				RD.TypeServiceId = CTS.CtsId
	WHERE
		RD.RateId = @RateToSearch
		AND
		RD.ArticleId IS NULL
		AND
		CTS.CtsShortName = @StatedTypeService COLLATE Latin1_General_CI_AI

	-- Se adminte que ya se encontro tipo de servicio
	IF(@FinalTypeServiceFound = 1)
	BEGIN

		-- Tipo de dato envíado es posible como tipo de servicio
		SET @FinalTypeService = @StatedTypeService;

		RETURN @FinalTypeService;

	END
	ELSE
	BEGIN

		-- Determinar servicio bajo condiciones de tipos de servicio DENTRO de tarifario del cliente propietario de la guía
		SELECT
			TOP 1
				@FinalTypeService = CTS.CtsShortName,
				@FinalTypeServiceFound = 1
		FROM
			[DeliveryBackOffice].[dbo].[RateData] RD WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK)
				ON
					RD.TypeServiceId = CTS.CtsId
		WHERE
			RD.RateId = @RateToSearch
			AND
			RD.ArticleId IS NULL
			AND
			(
				(
					-- Servicio COD
					@HasCollectOnDelivery = 1
					AND
					CTS.CtsShortName = 'COD'
				)
				OR
				(
					-- Servicio STD
					@HasCollectOnDelivery = 0
					AND
					CTS.CtsShortName = 'STD'
				)
				OR
				(
					-- Default dentro de tarifario
					CTS.CtsShortName = 'NDD'
				)
			)

	END

	-- Se identifico tipo de servicio
	IF(@FinalTypeServiceFound = 1)
	BEGIN
	
		-- Retornar posible tipo de servicio
		RETURN @FinalTypeService;

	END

	-- Tipo de servicio por defecto
	RETURN @DefaultServiceType;
	
END