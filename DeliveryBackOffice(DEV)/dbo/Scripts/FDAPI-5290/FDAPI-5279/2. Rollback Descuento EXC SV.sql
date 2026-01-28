/* =================================================
   Script:    Rollback Descuento EXC SV
   Propósito: Modificación por segmento de tarifario express center para Sv.
   Autor:     Walter Orozco
   Historia:  FDAPI-5290[FDAPI-5279]
   Fecha:     2025-12-23
================================================= */

BEGIN TRY
    BEGIN TRANSACTION;

	DECLARE
		@Token			NVARCHAR(100)	= 'SYS-RBDESCUENTOEXC',
		@DateCreated	DATETIME		= GETDATE(),
		@ServicioEco	DECIMAL(14,2)	= 1.00;
    
     DECLARE 
		@IdSegmentMetro			INT	= (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'MES'), --27 Metro Salvador
		@IdSegmentNacional		INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'NAS'); --32 Local Salvador

	DECLARE 
		@IdRate			INT = (SELECT RheId from RateHeader WITH(NOLOCK) where RheName ='Tarifario destinos express center' AND CountryId = 'SV'),
		@TypeServiceSTD INT = (SELECT CtsId FROM CatTypeService WITH(NOLOCK) WHERE CtsShortName = 'STD'), --5
		@TypeServiceCOD INT = (SELECT CtsId FROM CatTypeService WITH(NOLOCK) WHERE CtsShortName = 'COD'); --6

	DECLARE
		@PaquetePequeño			INT = (SELECT AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK) WHERE Code = 'EXPSV076'), --578 Paquete pequeño
		@PaqueteMediano			INT = (SELECT AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK) WHERE Code = 'EXPSV077'), --579 Paquete mediano
		@PaqueteGrande			INT = (SELECT AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK) WHERE Code = 'EXPSV078'), --580 Paquete grande
		@PaqueteExtraGrande		INT = (SELECT AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK) WHERE Code = 'EXPSV079'), --581 Paquete extra grande
		@PaqueteSobreDim		INT = (SELECT AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK) WHERE Code = 'EXPSV080'); --582 Paquete sobredimensionado

	--Segmentos: M=Metro, N=Nacional

	-- =========================
	-- Servicio Estándar (STD)
	-- =========================
	DECLARE
		@STD_M_PP	DECIMAL(14,2) = 3.00,	@STD_M_PM	DECIMAL(14,2) = 3.00,	@STD_M_PG	DECIMAL(14,2) = 3.00,	@STD_M_PE	DECIMAL(14,2) = 3.00,	@STD_M_PS	DECIMAL(14,2) = 3.00,
		@STD_N_PP	DECIMAL(14,2) = 4.00,	@STD_N_PM	DECIMAL(14,2) = 4.00,	@STD_N_PG	DECIMAL(14,2) = 4.00,	@STD_N_PE	DECIMAL(14,2) = 4.00,	@STD_N_PS	DECIMAL(14,2) = 4.00;
		
	-- =========================
	-- Servicio C.O.D. (COD)
	-- =========================
	DECLARE
		@COD_M_PP	DECIMAL(14,2) = 3.00,	@COD_M_PM	DECIMAL(14,2) = 3.00,	@COD_M_PG	DECIMAL(14,2) = 3.00,	@COD_M_PE	DECIMAL(14,2) = 3.00,	@COD_M_PS	DECIMAL(14,2) = 3.00,
		@COD_N_PP	DECIMAL(14,2) = 4.00,	@COD_N_PM	DECIMAL(14,2) = 4.00,	@COD_N_PG	DECIMAL(14,2) = 4.00,	@COD_N_PE	DECIMAL(14,2) = 4.00,	@COD_N_PS	DECIMAL(14,2) = 4.00;
		
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

	PRINT('Se inserto las tarifas para el servicio COD correctamente.');

	--Servicio Economico,  descuento sobre la tarifa asignada cuando se trate de un envío originado en una agencia EXC con destino a otra agencia EXC
	UPDATE RateData 
	SET 
		RateValue = RateValue - @ServicioEco
	WHERE RateId = @IdRate
	AND RowStatus = 1
	AND TypeServiceId IN (@TypeServiceSTD,@TypeServiceCOD)

	PRINT('Se realizaron modificaciones por Servicio Economico.');

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
