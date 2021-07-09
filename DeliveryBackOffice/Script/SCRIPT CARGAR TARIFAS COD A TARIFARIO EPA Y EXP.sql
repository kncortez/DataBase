
DECLARE @Token VARCHAR(50) ='SYS-CAQUINO'

DECLARE @RateIDCOR INT	=( select top 1 RheId from dbo.RateHeader where RheShortName ='COR' and  RheRowStatus = 1  ) 
DECLARE @RateIDEXP INT	=( select top 1 RheId from dbo.RateHeader where RheShortName ='EXP' and  RheRowStatus = 1  ) 

DECLARE @SDD INT = (select  TOP 1 CtsId from dbo.CatTypeService where CtsShortName ='SDD' )
DECLARE @NDD INT = (select  TOP 1 CtsId from dbo.CatTypeService where CtsShortName ='NDD' )
DECLARE @TDA INT = (select  TOP 1 CtsId from dbo.CatTypeService where CtsShortName ='TDA' )

DECLARE @LOC INT = (select  TOP 1 CrsId FROM dbo.CatRateSegment where CrsShortName ='LOC' )
DECLARE @MET INT = (select  TOP 1 CrsId FROM dbo.CatRateSegment where CrsShortName ='MET' )
DECLARE @FOR INT = (select  TOP 1 CrsId FROM dbo.CatRateSegment where CrsShortName ='FOR' )

INSERT INTO dbo.RateCOD
(RateId, TypeServiceId , TypeSegmentId, CODRate, CODExempt, CreditCardSurcharge, RowStatus ,TokenCreated, DateCreated)
VALUES(@RateIDCOR,@SDD,@LOC,2,0,5,1,@Token,GETDATE())
	, (@RateIDCOR,@SDD,@MET,2,0,5,1,@Token,GETDATE())
	, (@RateIDCOR,@SDD,@FOR,3,0,5,1,@Token,GETDATE())
	, (@RateIDCOR,@NDD,@LOC,2,0,5,1,@Token,GETDATE())
	, (@RateIDCOR,@NDD,@MET,2,0,5,1,@Token,GETDATE())
	, (@RateIDCOR,@NDD,@FOR,3,0,5,1,@Token,GETDATE())
	, (@RateIDCOR,@TDA,@LOC,3,0,5,1,@Token,GETDATE())
	, (@RateIDCOR,@TDA,@MET,3,0,5,1,@Token,GETDATE())
	, (@RateIDCOR,@TDA,@FOR,3,0,5,1,@Token,GETDATE())

	,(@RateIDEXP,@SDD,@LOC,2,0,5,1,@Token,GETDATE())
	, (@RateIDEXP,@SDD,@MET,2,0,5,1,@Token,GETDATE())
	, (@RateIDEXP,@SDD,@FOR,3,0,5,1,@Token,GETDATE())
	, (@RateIDEXP,@NDD,@LOC,2,0,5,1,@Token,GETDATE())
	, (@RateIDEXP,@NDD,@MET,2,0,5,1,@Token,GETDATE())
	, (@RateIDEXP,@NDD,@FOR,3,0,5,1,@Token,GETDATE())
	, (@RateIDEXP,@TDA,@LOC,3,0,5,1,@Token,GETDATE())
	, (@RateIDEXP,@TDA,@MET,3,0,5,1,@Token,GETDATE())
	, (@RateIDEXP,@TDA,@FOR,3,0,5,1,@Token,GETDATE())

select * from dbo.RateCOD