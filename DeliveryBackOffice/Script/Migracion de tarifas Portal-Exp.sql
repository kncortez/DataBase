--SELECT *
--FROM DBO.RateData

insert into dbo.RateData 
(RateId, TypeServiceId, HubSourceId, HubDestinyId, RateValue, RowStatus, TokenCreated, DateCreated)
select RbhIdRate,RbhIdTypeService,RbhIdHubSource,RbhIdHubDestiny, RbhRate, RbhRowStatus, 'SYS-CAQUINO', GETDATE()
from dbo.RateByHub
where RbhIdRate =3

SELECT *
FROM dbo.RateData
WHERE RateId = 3
