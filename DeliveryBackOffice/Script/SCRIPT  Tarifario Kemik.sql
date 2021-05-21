
DECLARE @RateName nvarchar(50) ='Tarifas Todo Destino'
DECLARE @RateShortName nvarchar(10) =  'TTD'
DECLARE @RateDescription nvarchar(200) = 'Tarias todo destiono'
DECLARE @IdTypeRate int  = 2  -- todo destino
DECLARE @Token nvarchar(50) ='SYS-CAQUINO'

-- rowstatus
-- datecreated

DECLARE @FragilRate decimal(12,2) =0
DECLARE @InsuranceRate decimal(12,2)=1
DECLARE @InsuranceExempt decimal(12,2) =800
DECLARE @AdditionalWeightRate decimal(12,2)=1
DECLARE @WeightLimit decimal(12,2) =30
DECLARE @CreditCardRate decimal(12,2)=0
DECLARE @Attempt int = 2
DECLARE @ReturnRate decimal(12,2) = 100
DECLARE @CollectRate decimal(12,2)=3
DECLARE @PiecesIncluded int=1


DECLARE @CountryId nvarchar(50) ='GT'
DECLARE @CurrencyId INT =1
DECLARE @IsTemplate BIT=1



DECLARE @SDLOCRate DECIMAL(12,2) =25
DECLARE @SDMETRate DECIMAL(12,2) =28
DECLARE @SDFORRate DECIMAL(12,2) =0

DECLARE @NDLOCRate DECIMAL(12,2) =23
DECLARE @NDMETRate DECIMAL(12,2) =28
DECLARE @NDFORRate DECIMAL(12,2) =33

DECLARE @TDLOCRate DECIMAL(12,2) =27.6
DECLARE @TDMETRate DECIMAL(12,2) =33.6
DECLARE @TDFORRate DECIMAL(12,2) =39.6


DECLARE @SDD INT = (Select top 1 cs.CtsId from dbo.CatTypeService cs where cs.CtsShortName ='SDD')
DECLARE @NDD INT = (Select top 1 cs.CtsId from dbo.CatTypeService cs where cs.CtsShortName ='NDD')
DECLARE @TDA INT = (Select top 1 cs.CtsId from dbo.CatTypeService cs where cs.CtsShortName ='TDA')


DECLARE @LOC INT = (Select top 1 cs.CrsId from dbo.CatRateSegment cs where cs.CrsShortName ='LOC')
DECLARE @MET INT = (Select top 1 cs.CrsId from dbo.CatRateSegment cs where cs.CrsShortName ='MET')
DECLARE @FOR INT = (Select top 1 cs.CrsId from dbo.CatRateSegment cs where cs.CrsShortName ='FOR')



insert into dbo.RateHeader
(RheName,RheShortName,RheDescription,RheRowStatus,RheTokenCreated,RheDateCreated,RateTypeId, RheDefault
,FragilRate,InsuranceRate,InsuranceExempt, AdditionalWeightRate,WeightLimit,CreditCardRate,Attempt,ReturnRate, CollectRate,PiecesIncluded
,CountryId,CurrencyId,IsTemplate)

values(@RateName,@RateShortName,@RateDescription,1,@Token, getdate(),@IdTypeRate ,'false'
	,@FragilRate,@InsuranceRate,@InsuranceExempt,@AdditionalWeightRate,@WeightLimit,@CreditCardRate,@Attempt,@ReturnRate,@CollectRate,@PiecesIncluded
	,@CountryId,@CurrencyId,@IsTemplate)


DECLARE @IdRate int = SCOPE_IDENTITY()  

IF @SDLOCRate>0
INSERT INTO  DBO.RateData
(RateId, TypeServiceId, TypeSegmentId,RateValue, RowStatus, TokenCreated, DateCreated)
values (@IdRate, @SDD, @LOC,@SDLOCRate, 1,'SYS-CAQUINO', getdate())

IF @SDMETRate>0
INSERT INTO  DBO.RateData
(RateId, TypeServiceId, TypeSegmentId,RateValue, RowStatus, TokenCreated, DateCreated)
values (@IdRate, @SDD, @MET,@SDMETRate, 1,'SYS-CAQUINO', getdate())

IF @SDFORRate>0
INSERT INTO  DBO.RateData
(RateId, TypeServiceId, TypeSegmentId,RateValue, RowStatus, TokenCreated, DateCreated)
values (@IdRate, @SDD, @FOR,@SDFORRate, 1,'SYS-CAQUINO', getdate())


IF @NDLOCRate>0
INSERT INTO  DBO.RateData
(RateId, TypeServiceId, TypeSegmentId,RateValue, RowStatus, TokenCreated, DateCreated)
values (@IdRate, @SDD, @LOC,@NDLOCRate, 1,'SYS-CAQUINO', getdate())

IF @NDMETRate>0
INSERT INTO  DBO.RateData
(RateId, TypeServiceId, TypeSegmentId,RateValue, RowStatus, TokenCreated, DateCreated)
values (@IdRate, @SDD, @MET,@NDMETRate, 1,'SYS-CAQUINO', getdate())

IF @NDFORRate>0
INSERT INTO  DBO.RateData
(RateId, TypeServiceId, TypeSegmentId,RateValue, RowStatus, TokenCreated, DateCreated)
values (@IdRate, @SDD, @FOR,@NDFORRate, 1,'SYS-CAQUINO', getdate())


IF @TDLOCRate>0
INSERT INTO  DBO.RateData
(RateId, TypeServiceId, TypeSegmentId,RateValue, RowStatus, TokenCreated, DateCreated)
values (@IdRate, @SDD, @LOC,@TDLOCRate, 1,'SYS-CAQUINO', getdate())

IF @TDMETRate>0
INSERT INTO  DBO.RateData
(RateId, TypeServiceId, TypeSegmentId,RateValue, RowStatus, TokenCreated, DateCreated)
values (@IdRate, @SDD, @MET,@TDMETRate, 1,'SYS-CAQUINO', getdate())

IF @TDFORRate>0
INSERT INTO  DBO.RateData
(RateId, TypeServiceId, TypeSegmentId,RateValue, RowStatus, TokenCreated, DateCreated)
values (@IdRate, @SDD, @FOR,@TDFORRate, 1,'SYS-CAQUINO', getdate())


select * from dbo.RateHeader rh
where rh.RheId = @IdRate



select * from dbo.RateData
where RateId  = @IdRate



DECLARE @IdCustomer int = 204



update dbo.RatebyCustomer
set RbcIdRate = 7
where RbcIdCustomer = @IdCustomer


select * from dbo.RatebyCustomer
where RbcIdCustomer = @IdCustomer
