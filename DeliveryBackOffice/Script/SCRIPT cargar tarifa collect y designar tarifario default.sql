update dbo.RateHeader set RheDefault = 0
where RheId = 1


update dbo.RateHeader set RheDefault = 1
where RheId = 3



update dbo.RateHeader set PiecesIncluded = 1, CollectRate =2, ReturnRate = 100
where RheId >= 1

select * from dbo.RateHeader