DECLARE @IdCustomer int = 1033


DECLARE @VP int =(
select top 1 CodeOfReference
from dbo.VisitPointClient
where CustomerID = @IdCustomer)


DECLARE @GUA INT = (select HB.IdHubLogistic from dbo.HubLogistics hb where hb.HubAbbreviation in('GUA'))

DECLARE @GTM INT = (select HB.IdHubLogistic from dbo.HubLogistics hb where hb.HubAbbreviation in('GTM'))

DECLARE @LOC INT = (Select top 1 cs.CrsId from dbo.CatRateSegment cs where cs.CrsShortName ='LOC')
DECLARE @MET INT = (Select top 1 cs.CrsId from dbo.CatRateSegment cs where cs.CrsShortName ='MET')


INSERT INTO dbo.VisitPointCoverage
(VisitPointId,HubLogisticId,SegmentId,RowStatus, TokenCreated, DateCreated)
values(@VP,@GUA,@LOC,1,'SYS-CAQUINO',GETDATE())
	,(@VP,@GTM,@MET,1,'SYS-CAQUINO',GETDATE())

SELECT * FROM DBO.VisitPointCoverage
WHERE VisitPointId = @VP