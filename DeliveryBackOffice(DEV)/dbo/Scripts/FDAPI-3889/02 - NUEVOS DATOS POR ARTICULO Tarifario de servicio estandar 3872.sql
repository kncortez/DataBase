DECLARE 
	@IdSegmentLOCAL                INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'LOC'), -- 1
	@IdSegmentCABECERA             INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'MET'), --2
	@IdSegmentDEPARTAMENTAL        INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'FOR'), --3
	@IdSegmentESPECIAL             INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'ESP'), --4
	@IdSegmentCABECERA_NORTE       INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'CNO'), --5
	@IdSegmentDEPARTAMENTAL_NORTE  INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'DNO'), --6
	@IdSegmentESPECIAL_NORTE       INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'ENO'), --7
	@IdSegmentCABECERA_OCCIDENTE   INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'COC'), --8
	@IdSegmentDEPARTAMEN_OCCIDENTE INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'DOC'), --9
	@IdSegmentESPECIAL_OCCIDENTE   INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'EOC'),--10
	@IdSegmentCABECERA_ORIENTE     INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'COR'),--11
	@IdSegmentDEPARTAMENTAL_ORIENT INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'DOR'),--12
	@IdSegmentESPECIAL_ORIENTE     INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'EOR'),--13
	@IdSegmentLOCAL_HN             INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'LOH');--15





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
where RateId= 3872
and RowStatus = 1
and TypeServiceId is not null
AND TypeServiceId = 5 --estandar


--1	LOCAL
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
 ( 3872,5,@IdSegmentLOCAL ,NULL,NULL,567,28.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentLOCAL ,NULL,NULL,568,39.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentLOCAL ,NULL,NULL,569,61.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentLOCAL ,NULL,NULL,570,73.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentLOCAL ,NULL,NULL,571,84.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

--2	CABECERA
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
 ( 3872,5,@IdSegmentCABECERA,NULL,NULL,531,39.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentCABECERA,NULL,NULL,532,50.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentCABECERA,NULL,NULL,533,73.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentCABECERA,NULL,NULL,534,84.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentCABECERA,NULL,NULL,535,95.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

--3	DEPARTAMENTAL
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL        ,NULL,NULL,531,40.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL        ,NULL,NULL,532,51.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL        ,NULL,NULL,533,74.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL        ,NULL,NULL,534,85.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL        ,NULL,NULL,535,96.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--4	ESPECIAL
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
 ( 3872,5,@IdSegmentESPECIAL ,NULL,NULL,531,58.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL ,NULL,NULL,532,69.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL ,NULL,NULL,533,92.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL ,NULL,NULL,534,103.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL ,NULL,NULL,535,114.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


--5	CABECERA NORTE
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
 ( 3872,5,@IdSegmentCABECERA_NORTE,NULL,NULL,531,46.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentCABECERA_NORTE,NULL,NULL,532,57.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentCABECERA_NORTE,NULL,NULL,533,79.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentCABECERA_NORTE,NULL,NULL,534,91.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentCABECERA_NORTE,NULL,NULL,535,102.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

--6	DEPARTAMENTAL NORTE
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL_NORTE  ,NULL,NULL,531,47.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL_NORTE  ,NULL,NULL,532,58.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL_NORTE  ,NULL,NULL,533,81,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL_NORTE  ,NULL,NULL,534,92.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL_NORTE  ,NULL,NULL,535,103.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--7	ESPECIAL NORTE
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
 ( 3872,5,@IdSegmentESPECIAL_NORTE,NULL,NULL,531,65.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL_NORTE,NULL,NULL,532,76.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL_NORTE,NULL,NULL,533,99,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL_NORTE,NULL,NULL,534,110.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL_NORTE,NULL,NULL,535,121.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--8	CABECERA OCCIDENTE
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
 ( 3872,5,@IdSegmentCABECERA_OCCIDENTE ,NULL,NULL,531,41.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentCABECERA_OCCIDENTE ,NULL,NULL,532,52.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentCABECERA_OCCIDENTE ,NULL,NULL,533,75.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentCABECERA_OCCIDENTE ,NULL,NULL,534,86.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentCABECERA_OCCIDENTE ,NULL,NULL,535,97.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--9	DEPARTAMENTAL OCCIDENTE
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
 ( 3872,5,@IdSegmentDEPARTAMEN_OCCIDENTE,NULL,NULL,531,42.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMEN_OCCIDENTE,NULL,NULL,532,54,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMEN_OCCIDENTE,NULL,NULL,533,76.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMEN_OCCIDENTE,NULL,NULL,534,87.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMEN_OCCIDENTE,NULL,NULL,535,99,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--10	ESPECIAL OCCIDENTE
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
 ( 3872,5,@IdSegmentESPECIAL_OCCIDENTE ,NULL,NULL,531,61.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL_OCCIDENTE ,NULL,NULL,532,73.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL_OCCIDENTE ,NULL,NULL,533,95.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL_OCCIDENTE ,NULL,NULL,534,106.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL_OCCIDENTE ,NULL,NULL,535,118.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--11	CABECERA ORIENTE
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
 ( 3872,5,@IdSegmentCABECERA_ORIENTE ,NULL,NULL,531,41.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentCABECERA_ORIENTE ,NULL,NULL,532,52.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentCABECERA_ORIENTE ,NULL,NULL,533,75.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentCABECERA_ORIENTE ,NULL,NULL,534,86.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentCABECERA_ORIENTE ,NULL,NULL,535,97.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--12	DEPARTAMENTAL ORIENTE
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL_ORIENT,NULL,NULL,531,42.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL_ORIENT,NULL,NULL,532,54,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL_ORIENT,NULL,NULL,533,76.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL_ORIENT,NULL,NULL,534,87.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentDEPARTAMENTAL_ORIENT,NULL,NULL,535,99,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--13	ESPECIAL ORIENTE
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
 ( 3872,5,@IdSegmentESPECIAL_ORIENTE ,NULL,NULL,531,61.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL_ORIENTE ,NULL,NULL,532,73.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL_ORIENTE ,NULL,NULL,533,95.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL_ORIENTE ,NULL,NULL,534,106.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,5,@IdSegmentESPECIAL_ORIENTE ,NULL,NULL,535,118.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--15	LOCAL HN
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
 ( 3872,5,@IdSegmentLOCAL_HN,NULL,NULL,567,39.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentLOCAL_HN,NULL,NULL,568,43.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentLOCAL_HN,NULL,NULL,569,56.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentLOCAL_HN,NULL,NULL,570,60.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,5,@IdSegmentLOCAL_HN,NULL,NULL,571,64.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)


 --*********************
 --*********************
 --*****     COD
 --*********************
 --*********************

 UPDATE RateData 
SET RowStatus = 0,
TokenUpdated = 'SYS-BPEDROZA',
DateUpdated = GETDATE()
where RateId= 3872
and RowStatus = 1
and TypeServiceId is not null
AND TypeServiceId = 6 --COD

--1	LOCAL
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
 ( 3872,6,@IdSegmentLOCAL ,NULL,NULL,567,31.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentLOCAL ,NULL,NULL,568,37.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentLOCAL ,NULL,NULL,569,59.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentLOCAL ,NULL,NULL,570,70.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentLOCAL ,NULL,NULL,571,82.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

--2	CABECERA
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
 ( 3872,6,@IdSegmentCABECERA,NULL,NULL,531,36,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentCABECERA,NULL,NULL,532,47.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentCABECERA,NULL,NULL,533,69.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentCABECERA,NULL,NULL,534,81,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentCABECERA,NULL,NULL,535,92.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

--3	DEPARTAMENTAL
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL        ,NULL,NULL,531,37.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL        ,NULL,NULL,532,48.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL        ,NULL,NULL,533,70.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL        ,NULL,NULL,534,82.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL        ,NULL,NULL,535,93.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--4	ESPECIAL
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
 ( 3872,6,@IdSegmentESPECIAL ,NULL,NULL,531,48.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL ,NULL,NULL,532,59.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL ,NULL,NULL,533,82.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL ,NULL,NULL,534,93.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL ,NULL,NULL,535,104.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--5	CABECERA NORTE
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
 ( 3872,6,@IdSegmentCABECERA_NORTE,NULL,NULL,531,36,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentCABECERA_NORTE,NULL,NULL,532,47.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentCABECERA_NORTE,NULL,NULL,533,69.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentCABECERA_NORTE,NULL,NULL,534,81,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentCABECERA_NORTE,NULL,NULL,535,92.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)

--6	DEPARTAMENTAL NORTE
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL_NORTE  ,NULL,NULL,531,37.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL_NORTE  ,NULL,NULL,532,48.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL_NORTE  ,NULL,NULL,533,70.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL_NORTE  ,NULL,NULL,534,82.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL_NORTE  ,NULL,NULL,535,93.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--7	ESPECIAL NORTE
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
 ( 3872,6,@IdSegmentESPECIAL_NORTE,NULL,NULL,531,48.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL_NORTE,NULL,NULL,532,59.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL_NORTE,NULL,NULL,533,82.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL_NORTE,NULL,NULL,534,93.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL_NORTE,NULL,NULL,535,104.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--8	CABECERA OCCIDENTE
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
 ( 3872,6,@IdSegmentCABECERA_OCCIDENTE ,NULL,NULL,531,36,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentCABECERA_OCCIDENTE ,NULL,NULL,532,47.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentCABECERA_OCCIDENTE ,NULL,NULL,533,69.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentCABECERA_OCCIDENTE ,NULL,NULL,534,81,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentCABECERA_OCCIDENTE ,NULL,NULL,535,92.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--9	DEPARTAMENTAL OCCIDENTE
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
 ( 3872,6,@IdSegmentDEPARTAMEN_OCCIDENTE,NULL,NULL,531,37.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMEN_OCCIDENTE,NULL,NULL,532,48.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMEN_OCCIDENTE,NULL,NULL,533,70.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMEN_OCCIDENTE,NULL,NULL,534,82.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMEN_OCCIDENTE,NULL,NULL,535,93.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--10	ESPECIAL OCCIDENTE
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
 ( 3872,6,@IdSegmentESPECIAL_OCCIDENTE ,NULL,NULL,531,48.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL_OCCIDENTE ,NULL,NULL,532,59.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL_OCCIDENTE ,NULL,NULL,533,82.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL_OCCIDENTE ,NULL,NULL,534,93.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL_OCCIDENTE ,NULL,NULL,535,104.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--11	CABECERA ORIENTE
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
 ( 3872,6,@IdSegmentCABECERA_ORIENTE ,NULL,NULL,531,36,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentCABECERA_ORIENTE ,NULL,NULL,532,47.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentCABECERA_ORIENTE ,NULL,NULL,533,69.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentCABECERA_ORIENTE ,NULL,NULL,534,81,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentCABECERA_ORIENTE ,NULL,NULL,535,92.25,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--12	DEPARTAMENTAL ORIENTE
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL_ORIENT,NULL,NULL,531,37.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL_ORIENT,NULL,NULL,532,48.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL_ORIENT,NULL,NULL,533,70.88,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL_ORIENT,NULL,NULL,534,82.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentDEPARTAMENTAL_ORIENT,NULL,NULL,535,93.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--13	ESPECIAL ORIENTE
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
 ( 3872,6,@IdSegmentESPECIAL_ORIENTE ,NULL,NULL,531,48.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL_ORIENTE ,NULL,NULL,532,59.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL_ORIENTE ,NULL,NULL,533,82.13,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL_ORIENTE ,NULL,NULL,534,93.38,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
 ( 3872,6,@IdSegmentESPECIAL_ORIENTE ,NULL,NULL,535,104.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--15	LOCAL HN
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
 ( 3872,6,@IdSegmentLOCAL_HN,NULL,NULL,567,35.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentLOCAL_HN,NULL,NULL,568,39.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentLOCAL_HN,NULL,NULL,569,52.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentLOCAL_HN,NULL,NULL,570,56.63,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
 ( 3872,6,@IdSegmentLOCAL_HN,NULL,NULL,571,60.75,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
