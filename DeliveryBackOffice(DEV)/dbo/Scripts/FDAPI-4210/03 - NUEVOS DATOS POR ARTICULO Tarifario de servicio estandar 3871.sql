BEGIN TRY
BEGIN TRANSACTION
 DECLARE @IdSegmentMetro		INT	= (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'MEH'), --14
		@IdSegmentLocal			INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'LOH'), --15
		@IdSegmentDepart		INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'DEH'), --16
		@IdSegmentRegional		INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'REH'), --17
		@IdSegmentForOlancho	INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'FOH'), --18
		@IdSegmentEspecial		INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'ESH'), --19
		@IdSegmentNacional		INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'NAH'), --21
		@IdSegmentForIslas		INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'FIH'), --20
		@IdSegmentForGracias	INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'FGH'); --33

DECLARE @IdRate			INT = (SELECT RheId from RateHeader WITH(NOLOCK) where RheName ='Tarifario de servicio estandar' AND CountryId = 'HN'),
		@TypeServiceSTD INT = (SELECT CtsId FROM CatTypeService WITH(NOLOCK) WHERE CtsShortName = 'STD'),--5
		@TypeServiceCOD INT = (SELECT CtsId FROM CatTypeService WITH(NOLOCK) WHERE CtsShortName = 'COD');--6

 --*********************
 --*********************
 --*****     ESTANDAR
 --*********************
 --*********************

 
--INHABILITAR TARIFAS ANTIGUAS
UPDATE RateData 
SET RowStatus = 0,
TokenUpdated = 'SYS-BPEDROZA',
DateUpdated = GETDATE()
where RateId= @IdRate
and RowStatus = 1
and TypeServiceId is not null
AND TypeServiceId = @TypeServiceSTD --estandar


--COBERTURA METRO		
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,567,95,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,568,106,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,569,140,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,570,151,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,571,162,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)



--COBERTURA LOCAL		CONFIGURADA EN TARIFARIOS
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentLocal,NULL,NULL,567,110,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentLocal,NULL,NULL,568,121,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentLocal,NULL,NULL,569,155,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentLocal,NULL,NULL,570,166,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentLocal,NULL,NULL,571,177,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



-- COBERTURA DEPARTAMENTAL		
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentDepart,NULL,NULL,567,125,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentDepart,NULL,NULL,568,136,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentDepart,NULL,NULL,569,170,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentDepart,NULL,NULL,570,181,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentDepart,NULL,NULL,571,192,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


 

--COBERTURA REGIONAL		
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentRegional,NULL,NULL,567,140,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentRegional,NULL,NULL,568,151,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentRegional,NULL,NULL,569,185,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentRegional,NULL,NULL,570,196,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentRegional,NULL,NULL,571,207,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);





-- COBERTURA NACIONAL		
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,567,165,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,568,176,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,569,210,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,570,221,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,571,232,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)




--COBERTURA FORANEA OLANCHO		
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForOlancho,NULL,NULL,567,220,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForOlancho,NULL,NULL,568,231,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForOlancho,NULL,NULL,569,265,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForOlancho,NULL,NULL,570,276,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForOlancho,NULL,NULL,571,287,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);




--COBERTURA ESPECIAL	
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentEspecial,NULL,NULL,567,300,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentEspecial,NULL,NULL,568,311,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentEspecial,NULL,NULL,569,345,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentEspecial,NULL,NULL,570,356,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentEspecial,NULL,NULL,571,367,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



 --COBERTURA FORANEA ISLAS		
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForIslas,NULL,NULL,567,400,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForIslas,NULL,NULL,568,411,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForIslas,NULL,NULL,569,445,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForIslas,NULL,NULL,570,456,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForIslas,NULL,NULL,571,467,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



  --COBERTURA FORANEA GRACIAS A DIOS		
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForGracias,NULL,NULL,567,500,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForGracias,NULL,NULL,568,511,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForGracias,NULL,NULL,569,535,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForGracias,NULL,NULL,570,546,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceSTD,@IdSegmentForGracias,NULL,NULL,571,557,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);






 --*********************
 --*********************
 --*****     COD
 --*********************
 --*********************

 UPDATE RateData 
SET RowStatus = 0,
TokenUpdated = 'SYS-BPEDROZA',
DateUpdated = GETDATE()
where RateId= @IdRate
and RowStatus = 1
and TypeServiceId is not null
AND TypeServiceId = @TypeServiceCOD --COD

--COBERTURA METRO		
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,567,85,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,568,96,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,569,130,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,570,141,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,571,152,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)


--COBERTURA LOCAL
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentLocal,NULL,NULL,567,100,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentLocal,NULL,NULL,568,111,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentLocal,NULL,NULL,569,145,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentLocal,NULL,NULL,570,156,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentLocal,NULL,NULL,571,167,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);




--COBERTURA DEPARTAMENTAL		
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentDepart,NULL,NULL,567,115,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentDepart,NULL,NULL,568,126,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentDepart,NULL,NULL,569,160,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentDepart,NULL,NULL,570,171,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentDepart,NULL,NULL,571,182,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



--COBERTURA REGIONAL		
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentRegional,NULL,NULL,567,130,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentRegional,NULL,NULL,568,141,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentRegional,NULL,NULL,569,175,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentRegional,NULL,NULL,570,186,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentRegional,NULL,NULL,571,197,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);




-- COBERTURA NACIONAL		
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,567,155,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,568,166,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,569,200,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,570,211,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,571,222,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)





--COBERTURA FORANEA OLANCHO		
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForOlancho,NULL,NULL,567,210,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForOlancho,NULL,NULL,568,221,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForOlancho,NULL,NULL,569,255,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForOlancho,NULL,NULL,570,266,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForOlancho,NULL,NULL,571,277,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);




--COBERTURA ESPECIAL	
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentEspecial,NULL,NULL,567,290,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentEspecial,NULL,NULL,568,301,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentEspecial,NULL,NULL,569,335,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentEspecial,NULL,NULL,570,346,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentEspecial,NULL,NULL,571,357,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);




--COBERTURA FORANEA ISLAS		

 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForIslas,NULL,NULL,567,390,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForIslas,NULL,NULL,568,401,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForIslas,NULL,NULL,569,435,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForIslas,NULL,NULL,570,446,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForIslas,NULL,NULL,571,457,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



 --COBERTURA FORANEA GRACIAS A DIOS
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForGracias,NULL,NULL,567,490,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForGracias,NULL,NULL,568,500,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForGracias,NULL,NULL,569,520,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForGracias,NULL,NULL,570,530,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
 INSERT INTO dbo.RateData
 (
     RateId
   , TypeServiceId
   , TypeSegmentId
   , HubSourceId
   , HubDestinyId
   , ArticleId
   , RateValue
   , RowStatus
   , TokenCreated
   , DateCreated
   , TokenUpdated
   , DateUpdated
   , LimitHourDelivery
   , LimitHourPickup
   , WeightFrom
   , WeightTo
   , PackagesFrom
   , PackagesTo
 )
 VALUES
 ( @IdRate,@TypeServiceCOD,@IdSegmentForGracias,NULL,NULL,571,540,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

 COMMIT TRANSACTION
    PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    PRINT 'Ocurrió un error al ejecutar la actualización.'
    PRINT ERROR_MESSAGE()
END CATCH