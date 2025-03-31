USE [DeliveryBackOffice];
DECLARE @IdSegmentMetro		INT	= (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'MEG'),
		@IdSegmentLocal		INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'LOC'),
		@IdSegmentDepart	INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'FOR'),
		@IdSegmentRegional	INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'REG'),
		@IdSegmentForPeten	INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'FPG'),
		@IdSegmentEspecial	INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'ESP'),
		@IdSegmentNacional	INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'NAG');




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
where RateId= 2286
and RowStatus = 1
and TypeServiceId is not null
AND TypeServiceId = 5 --estandar


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
 ( 2286,5,@IdSegmentMetro,NULL,NULL,531,25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentMetro,NULL,NULL,532,35,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentMetro,NULL,NULL,533,55,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentMetro,NULL,NULL,534,65,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentMetro,NULL,NULL,535,75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


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
 ( 2286,5,@IdSegmentLocal,NULL,NULL,531,30,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentLocal,NULL,NULL,532,40,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentLocal,NULL,NULL,533,60,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentLocal,NULL,NULL,534,70,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentLocal,NULL,NULL,535,80,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



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
 ( 2286,5,@IdSegmentDepart,NULL,NULL,531,35,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentDepart,NULL,NULL,532,45,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentDepart,NULL,NULL,533,65,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentDepart,NULL,NULL,534,75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentDepart,NULL,NULL,535,85,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


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
 ( 2286,5,@IdSegmentRegional,NULL,NULL,531,40,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentRegional,NULL,NULL,532,50,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentRegional,NULL,NULL,533,70,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentRegional,NULL,NULL,534,80,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentRegional,NULL,NULL,535,90,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



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
 ( 2286,5,@IdSegmentNacional,NULL,NULL,531,45,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentNacional,NULL,NULL,532,55,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentNacional,NULL,NULL,533,75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentNacional,NULL,NULL,534,85,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentNacional,NULL,NULL,535,95,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


--COBERTURA FORANEA PETEN		
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
 ( 2286,5,@IdSegmentForPeten,NULL,NULL,531,50,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentForPeten,NULL,NULL,532,60,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentForPeten,NULL,NULL,533,80,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentForPeten,NULL,NULL,534,90,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentForPeten,NULL,NULL,535,100,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


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
 ( 2286,5,@IdSegmentEspecial,NULL,NULL,531,65,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentEspecial,NULL,NULL,532,75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentEspecial,NULL,NULL,533,95,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentEspecial,NULL,NULL,534,105,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,5,@IdSegmentEspecial,NULL,NULL,535,115,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);







 --*********************
 --*********************
 --*****     COD
 --*********************
 --*********************

 UPDATE RateData 
SET RowStatus = 0,
TokenUpdated = 'SYS-BPEDROZA',
DateUpdated = GETDATE()
where RateId= 2286
and RowStatus = 1
and TypeServiceId is not null
AND TypeServiceId = 6 --COD

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
 ( 2286,6,@IdSegmentMetro,NULL,NULL,531,24,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentMetro,NULL,NULL,532,34,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentMetro,NULL,NULL,533,54,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentMetro,NULL,NULL,534,64,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentMetro,NULL,NULL,535,74,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


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
 ( 2286,6,@IdSegmentLocal,NULL,NULL,531,28,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentLocal,NULL,NULL,532,38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentLocal,NULL,NULL,533,58,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentLocal,NULL,NULL,534,68,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentLocal,NULL,NULL,535,78,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



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
 ( 2286,6,@IdSegmentDepart,NULL,NULL,531,34,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentDepart,NULL,NULL,532,44,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentDepart,NULL,NULL,533,64,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentDepart,NULL,NULL,534,74,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentDepart,NULL,NULL,535,84,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


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
 ( 2286,6,@IdSegmentRegional,NULL,NULL,531,36,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentRegional,NULL,NULL,532,46,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentRegional,NULL,NULL,533,66,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentRegional,NULL,NULL,534,76,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentRegional,NULL,NULL,535,86,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



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
 ( 2286,6,@IdSegmentNacional,NULL,NULL,531,38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentNacional,NULL,NULL,532,48,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentNacional,NULL,NULL,533,68,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentNacional,NULL,NULL,534,78,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentNacional,NULL,NULL,535,88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



--COBERTURA FORANEA PETEN		
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
 ( 2286,6,@IdSegmentForPeten,NULL,NULL,531,40,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentForPeten,NULL,NULL,532,50,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentForPeten,NULL,NULL,533,70,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentForPeten,NULL,NULL,534,80,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentForPeten,NULL,NULL,535,90,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


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
 ( 2286,6,@IdSegmentEspecial,NULL,NULL,531,48,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentEspecial,NULL,NULL,532,58,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentEspecial,NULL,NULL,533,78,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentEspecial,NULL,NULL,534,88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 2286,6,@IdSegmentEspecial,NULL,NULL,535,98,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

