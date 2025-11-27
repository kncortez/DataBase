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

DECLARE @IdRate			INT = (SELECT RheId from RateHeader WITH(NOLOCK) where RheName ='Tarifario destinos express center' AND CountryId = 'HN'),
		@TypeServiceSTD INT = (SELECT CtsId FROM CatTypeService WITH(NOLOCK) WHERE CtsShortName = 'STD'),--5
		@TypeServiceCOD INT = (SELECT CtsId FROM CatTypeService WITH(NOLOCK) WHERE CtsShortName = 'COD');--6



DECLARE @IdPeq INT =(SELECT AbcId FROM ArticleByCustomer WITH(NOLOCK) WHERE AbcIdArticle =(SELECT ArtId FROM CatArticle WITH(NOLOCK) WHERE ArtName = 'Paquete Pequeño' and IdCountry = 'HN') AND Code = 'EXPHN076') ,
		@IdMed INT =(SELECT AbcId FROM ArticleByCustomer WITH(NOLOCK) WHERE AbcIdArticle =(SELECT ArtId FROM CatArticle WITH(NOLOCK) WHERE ArtName = 'Paquete Mediano' and IdCountry = 'HN') AND Code ='EXPHN077'),
		@IdGrand INT =(SELECT AbcId FROM ArticleByCustomer WITH(NOLOCK) WHERE AbcIdArticle =(SELECT ArtId FROM CatArticle WITH(NOLOCK) WHERE ArtName = 'Paquete Grande' and IdCountry = 'HN') AND Code ='EXPHN078'),
		@IdExt INT =(SELECT AbcId FROM ArticleByCustomer WITH(NOLOCK) WHERE AbcIdArticle =(SELECT ArtId FROM CatArticle WITH(NOLOCK) WHERE ArtName = 'Paquete Extra Grande' and IdCountry = 'HN') AND Code ='EXPHN079'),
		@IdSob INT =(SELECT AbcId FROM ArticleByCustomer WITH(NOLOCK) WHERE AbcIdArticle =(SELECT ArtId FROM CatArticle WITH(NOLOCK) WHERE ArtName = 'Paquete Sobredimensionado' and IdCountry = 'HN') AND Code ='EXPHN080');



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
 ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,@IdPeq,80,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,@IdMed,91,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,@IdGrand,125,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,@IdExt,136,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,@IdSob,147,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)




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
 ( @IdRate,@TypeServiceSTD,@IdSegmentLocal,NULL,NULL,@IdPeq,95,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentLocal,NULL,NULL,@IdMed,106,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentLocal,NULL,NULL,@IdGrand,140,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentLocal,NULL,NULL,@IdExt,151,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentLocal,NULL,NULL,@IdSob,162,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



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
 ( @IdRate,@TypeServiceSTD,@IdSegmentDepart,NULL,NULL,@IdPeq,110,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentDepart,NULL,NULL,@IdMed,121,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentDepart,NULL,NULL,@IdGrand,155,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentDepart,NULL,NULL,@IdExt,166,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentDepart,NULL,NULL,@IdSob,177,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



 

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
 ( @IdRate,@TypeServiceSTD,@IdSegmentRegional,NULL,NULL,@IdPeq,125,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentRegional,NULL,NULL,@IdMed,136,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentRegional,NULL,NULL,@IdGrand,170,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentRegional,NULL,NULL,@IdExt,181,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentRegional,NULL,NULL,@IdSob,192,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);






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
 ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,@IdPeq,150,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,@IdMed,161,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,@IdGrand,195,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,@IdExt,206,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,@IdSob,217,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)




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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForOlancho,NULL,NULL,@IdPeq,205,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForOlancho,NULL,NULL,@IdMed,216,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForOlancho,NULL,NULL,@IdGrand,250,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForOlancho,NULL,NULL,@IdExt,261,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForOlancho,NULL,NULL,@IdSob,272,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);




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
 ( @IdRate,@TypeServiceSTD,@IdSegmentEspecial,NULL,NULL,@IdPeq,285,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentEspecial,NULL,NULL,@IdMed,296,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentEspecial,NULL,NULL,@IdGrand,330,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentEspecial,NULL,NULL,@IdExt,341,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentEspecial,NULL,NULL,@IdSob,352,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForIslas,NULL,NULL,@IdPeq,385,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForIslas,NULL,NULL,@IdMed,396,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForIslas,NULL,NULL,@IdGrand,430,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForIslas,NULL,NULL,@IdExt,441,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForIslas,NULL,NULL,@IdSob,452,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForGracias,NULL,NULL,@IdPeq,485,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForGracias,NULL,NULL,@IdMed,496,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForGracias,NULL,NULL,@IdGrand,520,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForGracias,NULL,NULL,@IdExt,531,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceSTD,@IdSegmentForGracias,NULL,NULL,@IdSob,542,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);






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
 ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,@IdPeq,70,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,@IdMed,81,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,@IdGrand,115,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,@IdExt,126,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,@IdSob,137,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)



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
 ( @IdRate,@TypeServiceCOD,@IdSegmentLocal,NULL,NULL,@IdPeq,85,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentLocal,NULL,NULL,@IdMed,96,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentLocal,NULL,NULL,@IdGrand,130,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentLocal,NULL,NULL,@IdExt,141,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentLocal,NULL,NULL,@IdSob,152,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);





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
 ( @IdRate,@TypeServiceCOD,@IdSegmentDepart,NULL,NULL,@IdPeq,100,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentDepart,NULL,NULL,@IdMed,111,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentDepart,NULL,NULL,@IdGrand,145,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentDepart,NULL,NULL,@IdExt,156,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentDepart,NULL,NULL,@IdSob,167,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);



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
 ( @IdRate,@TypeServiceCOD,@IdSegmentRegional,NULL,NULL,@IdPeq,115,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentRegional,NULL,NULL,@IdMed,126,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentRegional,NULL,NULL,@IdGrand,160,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentRegional,NULL,NULL,@IdExt,171,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentRegional,NULL,NULL,@IdSob,182,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);





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
 ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,@IdPeq,140,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,@IdMed,151,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,@IdGrand,185,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,@IdExt,196,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,@IdSob,207,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)






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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForOlancho,NULL,NULL,@IdPeq,195,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForOlancho,NULL,NULL,@IdMed,206,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForOlancho,NULL,NULL,@IdGrand,240,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForOlancho,NULL,NULL,@IdExt,251,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForOlancho,NULL,NULL,@IdSob,262,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);




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
 ( @IdRate,@TypeServiceCOD,@IdSegmentEspecial,NULL,NULL,@IdPeq,275,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentEspecial,NULL,NULL,@IdMed,286,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentEspecial,NULL,NULL,@IdGrand,320,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentEspecial,NULL,NULL,@IdExt,331,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentEspecial,NULL,NULL,@IdSob,342,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);




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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForIslas,NULL,NULL,@IdPeq,375,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForIslas,NULL,NULL,@IdMed,386,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForIslas,NULL,NULL,@IdGrand,420,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForIslas,NULL,NULL,@IdExt,431,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForIslas,NULL,NULL,@IdSob,442,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);




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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForGracias,NULL,NULL,@IdPeq,475,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForGracias,NULL,NULL,@IdMed,485,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForGracias,NULL,NULL,@IdGrand,505,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForGracias,NULL,NULL,@IdExt,515,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( @IdRate,@TypeServiceCOD,@IdSegmentForGracias,NULL,NULL,@IdSob,525,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


 COMMIT TRANSACTION
    PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    PRINT 'Ocurrió un error al ejecutar la actualización.'
    PRINT ERROR_MESSAGE()
END CATCH