--select * from dbo.RateHeader
--where RheId = 2
--select * from dbo.RateDetail
--where RdtIdRate = 2 and RdtId = 7

-- actualizar encabezados de tarifario
update dbo.RateHeader
set RheTokenUpdated = 'SYS-CAQUINO'
, RheCreateUpdated = GETDATE()
, FragilRate = RdtFragileRate
, InsuranceRate = RdtInsuranceRate
, InsuranceExempt =800
, AdditionalWeightRate = RdtWeightAdditionalRate
, WeightLimit = RdtWeightLimit
, CreditCardRate = 2
, PickupRate =0
, Attempt = RdtDeliveryAttempts
, CountryId ='GT'
, CurrencyId = 1
, IsTemplate ='TRUE'
, RateByPiece = 'FALSE'
FROM dbo.RateDetail 
where RdtIdRate = 2  and RdtId = 7

--select * from dbo.RateHeader
--where RheId = 2

-- actualizar tarifario todo destino

insert into DBO.RateData (RateId,TypeServiceId,TypeSegmentId, RateValue, RowStatus, TokenCreated,Datecreated )
select RdtIdRate, RdtIdCatService, RdtIdRateSegment, RdtRate, 1,'SYS.CAQUINO'  , getdate()
from dbo.RateDetail
where RdtIdRate = 2 

--SELECT *
--FROM DBO.RateData


--SELECT RateId, TypeSegmentId, RateValue, ArticuleId  ,RowStatus, TokenCreated,Datecreated
--FROM DBO.RateData

-- actualizar tarifario por articulo

insert into DBO.RateData (RateId, TypeSegmentId, RateValue, ArticleId  ,RowStatus, TokenCreated,Datecreated )
select 2, SegmetId, Price, ArticuleByCustomerId,1,'SYS-CAQUINO', GETDATE()
from dbo.RateByArticuleByCustomer

SELECT *
FROM DBO.RateData



