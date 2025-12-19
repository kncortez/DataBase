/* =================================================
   Script:    Descuento Navidad Honduras 2025
   Propósito: Modificación por segmento de tarifario estandar para Hn.
   Autor:     Walter Orozco
   Historia:  FDAPI-5289[FDAPI-5288]
   Fecha:     2025-12-17
================================================= */

BEGIN TRY
    BEGIN TRANSACTION;

	DECLARE
		@Token			NVARCHAR(100)	= 'SYS-DESCUENTONAVIDAD25',
		@DateCreated	DATETIME		= GETDATE();
    
     DECLARE 
		@IdSegmentMetro			INT	= (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'MEH'), --14 Metro Honduras
		@IdSegmentLocal			INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'LOH'), --15 Local Honduras
		@IdSegmentDepart		INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'DEH'), --16 Departamental Honduras
		@IdSegmentRegional		INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'REH'), --17 Regional Honduras
		@IdSegmentForOlancho	INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'FOH'), --18 Foranea Olancho Honduras
		@IdSegmentEspecial		INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'ESH'), --19 Especial Honduras
		@IdSegmentNacional		INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'NAH'), --21 Nacional Honduras
		@IdSegmentForIslas		INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'FIH'), --20 Foranea Islas De La Bahia Honduras
		@IdSegmentForGracias	INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'FGH'); --33 Foraneo Gracias a Dios

	DECLARE 
		@IdRate			INT = (SELECT RheId from RateHeader WITH(NOLOCK) where RheName ='Tarifario de servicio estandar' AND CountryId = 'HN'),
		@TypeServiceSTD INT = (SELECT CtsId FROM CatTypeService WITH(NOLOCK) WHERE CtsShortName = 'STD'), --5
		@TypeServiceCOD INT = (SELECT CtsId FROM CatTypeService WITH(NOLOCK) WHERE CtsShortName = 'COD'); --6

	DECLARE
		@PaquetePequeño			INT = (SELECT AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK) WHERE Code = 'EXPHN076'), --567 Paquete pequeño
		@PaqueteMediano			INT = (SELECT AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK) WHERE Code = 'EXPHN077'), --568 Paquete mediano
		@PaqueteGrande			INT = (SELECT AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK) WHERE Code = 'EXPHN078'), --569 Paquete grande
		@PaqueteExtraGrande		INT = (SELECT AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK) WHERE Code = 'EXPHN079'), --570 Paquete extra grande
		@PaqueteSobreDim		INT = (SELECT AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK) WHERE Code = 'EXPHN080'); --571 Paquete sobredimensionado

	--Segmentos: M=Metro, L=Local, D=Departamental, R=Regional, N=Nacional, FO=Foránea Olancho, E=Especial, IB=Isla de la Bahía, GD=Foráneo GD

	-- =========================
	-- Servicio Estándar (STD)
	-- =========================
	DECLARE
		@STD_M_PP	DECIMAL(14,2) = 64.00,	@STD_M_PM	DECIMAL(14,2) = 71.00,	@STD_M_PG	DECIMAL(14,2) = 94.00,	@STD_M_PE	DECIMAL(14,2) = 101.00, @STD_M_PS	DECIMAL(14,2) = 109.00,
		@STD_L_PP	DECIMAL(14,2) = 74.00,	@STD_L_PM	DECIMAL(14,2) = 81.00,	@STD_L_PG	DECIMAL(14,2) = 104.00, @STD_L_PE	DECIMAL(14,2) = 111.00, @STD_L_PS	DECIMAL(14,2) = 119.00,
		@STD_D_PP	DECIMAL(14,2) = 84.00,	@STD_D_PM	DECIMAL(14,2) = 91.00,	@STD_D_PG	DECIMAL(14,2) = 114.00, @STD_D_PE	DECIMAL(14,2) = 121.00, @STD_D_PS	DECIMAL(14,2) = 129.00,
		@STD_R_PP	DECIMAL(14,2) = 94.00,	@STD_R_PM	DECIMAL(14,2) = 101.00, @STD_R_PG	DECIMAL(14,2) = 124.00, @STD_R_PE	DECIMAL(14,2) = 131.00, @STD_R_PS	DECIMAL(14,2) = 139.00,
		@STD_N_PP	DECIMAL(14,2) = 111.00,	@STD_N_PM	DECIMAL(14,2) = 118.00, @STD_N_PG	DECIMAL(14,2) = 141.00, @STD_N_PE	DECIMAL(14,2) = 148.00, @STD_N_PS	DECIMAL(14,2) = 155.00,
		@STD_FO_PP	DECIMAL(14,2) = 147.00, @STD_FO_PM	DECIMAL(14,2) = 155.00, @STD_FO_PG	DECIMAL(14,2) = 178.00, @STD_FO_PE	DECIMAL(14,2) = 185.00, @STD_FO_PS	DECIMAL(14,2) = 192.00,
		@STD_E_PP	DECIMAL(14,2) = 201.00, @STD_E_PM	DECIMAL(14,2) = 208.00, @STD_E_PG	DECIMAL(14,2) = 231.00, @STD_E_PE	DECIMAL(14,2) = 239.00, @STD_E_PS	DECIMAL(14,2) = 246.00,
		@STD_IB_PP	DECIMAL(14,2) = 268.00, @STD_IB_PM	DECIMAL(14,2) = 275.00, @STD_IB_PG	DECIMAL(14,2) = 298.00, @STD_IB_PE	DECIMAL(14,2) = 306.00, @STD_IB_PS	DECIMAL(14,2) = 313.00,
		@STD_GD_PP	DECIMAL(14,2) = 335.00, @STD_GD_PM	DECIMAL(14,2) = 342.00, @STD_GD_PG	DECIMAL(14,2) = 358.00, @STD_GD_PE	DECIMAL(14,2) = 366.00, @STD_GD_PS	DECIMAL(14,2) = 373.00;

	-- =========================
	-- Servicio C.O.D. (COD)
	-- =========================
	DECLARE
		@COD_M_PP	DECIMAL(14,2) = 57.00,	@COD_M_PM	DECIMAL(14,2) = 64.00,	@COD_M_PG	DECIMAL(14,2) = 87.00,	@COD_M_PE	DECIMAL(14,2) = 94.00,	@COD_M_PS	DECIMAL(14,2) = 102.00,
		@COD_L_PP	DECIMAL(14,2) = 67.00,	@COD_L_PM	DECIMAL(14,2) = 74.00,	@COD_L_PG	DECIMAL(14,2) = 97.00,	@COD_L_PE	DECIMAL(14,2) = 105.00, @COD_L_PS	DECIMAL(14,2) = 112.00,
		@COD_D_PP	DECIMAL(14,2) = 77.00,	@COD_D_PM	DECIMAL(14,2) = 84.00,	@COD_D_PG	DECIMAL(14,2) = 107.00, @COD_D_PE	DECIMAL(14,2) = 115.00, @COD_D_PS	DECIMAL(14,2) = 122.00,
		@COD_R_PP	DECIMAL(14,2) = 87.00,	@COD_R_PM	DECIMAL(14,2) = 94.00,	@COD_R_PG	DECIMAL(14,2) = 117.00, @COD_R_PE	DECIMAL(14,2) = 125.00, @COD_R_PS	DECIMAL(14,2) = 132.00,
		@COD_N_PP	DECIMAL(14,2) = 104.00, @COD_N_PM	DECIMAL(14,2) = 111.00, @COD_N_PG	DECIMAL(14,2) = 134.00, @COD_N_PE	DECIMAL(14,2) = 141.00, @COD_N_PS	DECIMAL(14,2) = 149.00,
		@COD_FO_PP	DECIMAL(14,2) = 141.00, @COD_FO_PM	DECIMAL(14,2) = 148.00, @COD_FO_PG	DECIMAL(14,2) = 171.00, @COD_FO_PE	DECIMAL(14,2) = 178.00, @COD_FO_PS	DECIMAL(14,2) = 186.00,
		@COD_E_PP	DECIMAL(14,2) = 194.00, @COD_E_PM	DECIMAL(14,2) = 202.00, @COD_E_PG	DECIMAL(14,2) = 224.00, @COD_E_PE	DECIMAL(14,2) = 232.00, @COD_E_PS	DECIMAL(14,2) = 239.00,
		@COD_IB_PP	DECIMAL(14,2) = 261.00, @COD_IB_PM	DECIMAL(14,2) = 269.00, @COD_IB_PG	DECIMAL(14,2) = 291.00, @COD_IB_PE	DECIMAL(14,2) = 299.00, @COD_IB_PS	DECIMAL(14,2) = 306.00,
		@COD_GD_PP	DECIMAL(14,2) = 328.00, @COD_GD_PM	DECIMAL(14,2) = 335.00, @COD_GD_PG	DECIMAL(14,2) = 348.00, @COD_GD_PE	DECIMAL(14,2) = 355.00, @COD_GD_PS	DECIMAL(14,2) = 362.00;

	-- ==============================================
	--				MODIFICAR ESTANDAR
	-- ==============================================
 
	-- INHABILITAR TARIFAS ANTIGUAS
	UPDATE RateData 
	SET 
		RowStatus		= 0,
		TokenUpdated	= @Token,
		DateUpdated		= GETDATE()
	WHERE RateId = @IdRate
	AND RowStatus = 1
	AND TypeServiceId = @TypeServiceSTD

	--COBERTURA METRO		
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	, TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceSTD , @IdSegmentMetro , NULL , NULL , @PaquetePequeño		, @STD_M_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentMetro , NULL , NULL , @PaqueteMediano		, @STD_M_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentMetro , NULL , NULL , @PaqueteGrande		, @STD_M_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentMetro , NULL , NULL , @PaqueteExtraGrande	, @STD_M_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentMetro , NULL , NULL , @PaqueteSobreDim		, @STD_M_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA LOCAL		
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	, TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceSTD , @IdSegmentLocal , NULL , NULL , @PaquetePequeño		, @STD_L_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentLocal , NULL , NULL , @PaqueteMediano		, @STD_L_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentLocal , NULL , NULL , @PaqueteGrande		, @STD_L_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentLocal , NULL , NULL , @PaqueteExtraGrande	, @STD_L_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentLocal , NULL , NULL , @PaqueteSobreDim		, @STD_L_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA DEPARTAMENTAL
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
		, TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceSTD , @IdSegmentDepart , NULL , NULL , @PaquetePequeño      , @STD_D_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentDepart , NULL , NULL , @PaqueteMediano      , @STD_D_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentDepart , NULL , NULL , @PaqueteGrande       , @STD_D_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentDepart , NULL , NULL , @PaqueteExtraGrande  , @STD_D_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentDepart , NULL , NULL , @PaqueteSobreDim     , @STD_D_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA REGIONAL
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	  , TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceSTD , @IdSegmentRegional , NULL , NULL , @PaquetePequeño      , @STD_R_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentRegional , NULL , NULL , @PaqueteMediano      , @STD_R_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentRegional , NULL , NULL , @PaqueteGrande       , @STD_R_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentRegional , NULL , NULL , @PaqueteExtraGrande  , @STD_R_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentRegional , NULL , NULL , @PaqueteSobreDim     , @STD_R_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA NACIONAL
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	  , TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceSTD , @IdSegmentNacional , NULL , NULL , @PaquetePequeño      , @STD_N_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentNacional , NULL , NULL , @PaqueteMediano      , @STD_N_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentNacional , NULL , NULL , @PaqueteGrande       , @STD_N_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentNacional , NULL , NULL , @PaqueteExtraGrande  , @STD_N_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentNacional , NULL , NULL , @PaqueteSobreDim     , @STD_N_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA FORÁNEA OLANCHO
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	  , TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceSTD , @IdSegmentForOlancho , NULL , NULL , @PaquetePequeño      , @STD_FO_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentForOlancho , NULL , NULL , @PaqueteMediano      , @STD_FO_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentForOlancho , NULL , NULL , @PaqueteGrande       , @STD_FO_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentForOlancho , NULL , NULL , @PaqueteExtraGrande  , @STD_FO_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentForOlancho , NULL , NULL , @PaqueteSobreDim     , @STD_FO_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA ESPECIAL
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	  , TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceSTD , @IdSegmentEspecial , NULL , NULL , @PaquetePequeño      , @STD_E_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentEspecial , NULL , NULL , @PaqueteMediano      , @STD_E_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentEspecial , NULL , NULL , @PaqueteGrande       , @STD_E_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentEspecial , NULL , NULL , @PaqueteExtraGrande  , @STD_E_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentEspecial , NULL , NULL , @PaqueteSobreDim     , @STD_E_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA ISLAS DE LA BAHÍA
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	  , TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceSTD , @IdSegmentForIslas , NULL , NULL , @PaquetePequeño      , @STD_IB_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentForIslas , NULL , NULL , @PaqueteMediano      , @STD_IB_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentForIslas , NULL , NULL , @PaqueteGrande       , @STD_IB_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentForIslas , NULL , NULL , @PaqueteExtraGrande  , @STD_IB_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentForIslas , NULL , NULL , @PaqueteSobreDim     , @STD_IB_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA FORÁNEO GD
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	  , TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceSTD , @IdSegmentForGracias , NULL , NULL , @PaquetePequeño      , @STD_GD_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentForGracias , NULL , NULL , @PaqueteMediano      , @STD_GD_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentForGracias , NULL , NULL , @PaqueteGrande       , @STD_GD_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentForGracias , NULL , NULL , @PaqueteExtraGrande  , @STD_GD_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceSTD , @IdSegmentForGracias , NULL , NULL , @PaqueteSobreDim     , @STD_GD_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);
    
	PRINT('Se inserto las tarifas para el servicio STD correctamente.');

	-- ==============================================
	--				MODIFICAR C.O.D.
	-- ==============================================
 
	-- INHABILITAR TARIFAS ANTIGUAS
	UPDATE RateData 
	SET 
		RowStatus		= 0,
		TokenUpdated	= @Token,
		DateUpdated		= GETDATE()
	WHERE RateId = @IdRate
	AND RowStatus = 1
	AND TypeServiceId = @TypeServiceCOD

	--COBERTURA METRO		
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	, TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceCOD , @IdSegmentMetro , NULL , NULL , @PaquetePequeño		, @COD_M_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentMetro , NULL , NULL , @PaqueteMediano		, @COD_M_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentMetro , NULL , NULL , @PaqueteGrande		, @COD_M_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentMetro , NULL , NULL , @PaqueteExtraGrande	, @COD_M_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentMetro , NULL , NULL , @PaqueteSobreDim		, @COD_M_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA LOCAL		
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	, TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceCOD , @IdSegmentLocal , NULL , NULL , @PaquetePequeño		, @COD_L_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentLocal , NULL , NULL , @PaqueteMediano		, @COD_L_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentLocal , NULL , NULL , @PaqueteGrande		, @COD_L_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentLocal , NULL , NULL , @PaqueteExtraGrande	, @COD_L_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentLocal , NULL , NULL , @PaqueteSobreDim		, @COD_L_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA DEPARTAMENTAL
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
		, TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceCOD , @IdSegmentDepart , NULL , NULL , @PaquetePequeño      , @COD_D_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentDepart , NULL , NULL , @PaqueteMediano      , @COD_D_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentDepart , NULL , NULL , @PaqueteGrande       , @COD_D_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentDepart , NULL , NULL , @PaqueteExtraGrande  , @COD_D_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentDepart , NULL , NULL , @PaqueteSobreDim     , @COD_D_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA REGIONAL
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	  , TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceCOD , @IdSegmentRegional , NULL , NULL , @PaquetePequeño      , @COD_R_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentRegional , NULL , NULL , @PaqueteMediano      , @COD_R_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentRegional , NULL , NULL , @PaqueteGrande       , @COD_R_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentRegional , NULL , NULL , @PaqueteExtraGrande  , @COD_R_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentRegional , NULL , NULL , @PaqueteSobreDim     , @COD_R_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA NACIONAL
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	  , TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceCOD , @IdSegmentNacional , NULL , NULL , @PaquetePequeño      , @COD_N_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentNacional , NULL , NULL , @PaqueteMediano      , @COD_N_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentNacional , NULL , NULL , @PaqueteGrande       , @COD_N_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentNacional , NULL , NULL , @PaqueteExtraGrande  , @COD_N_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentNacional , NULL , NULL , @PaqueteSobreDim     , @COD_N_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA FORÁNEA OLANCHO
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	  , TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceCOD , @IdSegmentForOlancho , NULL , NULL , @PaquetePequeño      , @COD_FO_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentForOlancho , NULL , NULL , @PaqueteMediano      , @COD_FO_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentForOlancho , NULL , NULL , @PaqueteGrande       , @COD_FO_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentForOlancho , NULL , NULL , @PaqueteExtraGrande  , @COD_FO_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentForOlancho , NULL , NULL , @PaqueteSobreDim     , @COD_FO_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA ESPECIAL
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	  , TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceCOD , @IdSegmentEspecial , NULL , NULL , @PaquetePequeño      , @COD_E_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentEspecial , NULL , NULL , @PaqueteMediano      , @COD_E_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentEspecial , NULL , NULL , @PaqueteGrande       , @COD_E_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentEspecial , NULL , NULL , @PaqueteExtraGrande  , @COD_E_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentEspecial , NULL , NULL , @PaqueteSobreDim     , @COD_E_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA ISLAS DE LA BAHÍA
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	  , TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceCOD , @IdSegmentForIslas , NULL , NULL , @PaquetePequeño      , @COD_IB_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentForIslas , NULL , NULL , @PaqueteMediano      , @COD_IB_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentForIslas , NULL , NULL , @PaqueteGrande       , @COD_IB_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentForIslas , NULL , NULL , @PaqueteExtraGrande  , @COD_IB_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentForIslas , NULL , NULL , @PaqueteSobreDim     , @COD_IB_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);

	--COBERTURA FORÁNEO GD
	INSERT INTO dbo.RateData
	( RateId , TypeServiceId , TypeSegmentId , HubSourceId , HubDestinyId , ArticleId , RateValue , RowStatus , TokenCreated , DateCreated
	  , TokenUpdated , DateUpdated , LimitHourDelivery , LimitHourPickup , WeightFrom , WeightTo , PackagesFrom , PackagesTo )
	VALUES
	( @IdRate , @TypeServiceCOD , @IdSegmentForGracias , NULL , NULL , @PaquetePequeño      , @COD_GD_PP , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentForGracias , NULL , NULL , @PaqueteMediano      , @COD_GD_PM , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentForGracias , NULL , NULL , @PaqueteGrande       , @COD_GD_PG , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentForGracias , NULL , NULL , @PaqueteExtraGrande  , @COD_GD_PE , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL),
	( @IdRate , @TypeServiceCOD , @IdSegmentForGracias , NULL , NULL , @PaqueteSobreDim     , @COD_GD_PS , 1 , @Token , @DateCreated , NULL , NULL , NULL , NULL , NULL , NULL , NULL , NULL);
    
	PRINT('Se inserto las tarifas para el servicio COD correctamente.');

    COMMIT TRANSACTION;
	PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
