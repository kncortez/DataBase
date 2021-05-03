-- EJECUTAR POR PARTES


ALTER TABLE dbo.RateHeader
ADD RateTypeId int null;

update dbo.RateHeader set  RateTypeId =1
where RheShortName IN('IND','EXP')

update dbo.RateHeader set  RateTypeId =2
where RheShortName ='COR'


Alter Table dbo.RateHeader
ADD FragilRate decimal (12,2) null
, InsuranceRate decimal (12,2) null
, InsuranceExempt decimal (12,2) null
, AdditionalWeightRate decimal (12,2) null
, WeightLimit decimal (12,2) null
, CreditCardRate decimal (12,2) null
, PickupRate decimal (12,2) null
, Attempt int null
, CountryId varchar(2) null
, CurrencyId int null
, IsTemplate bit null
, RateByPiece bit null
,ReturnRate decimal(12,2) null
,CollectRate decimal(12,2) null
,PiecesIncluded decimal (12,2)

ALTER TABLE  dbo.RateHeader
ADD FOREIGN KEY(CountryId) REFERENCES CatCountry(IdCountry)


ALTER TABLE  dbo.RateHeader
ADD FOREIGN KEY(CurrencyId) REFERENCES DeliveryCurrency(Currency_Id)


select * from dbo.RateHeader