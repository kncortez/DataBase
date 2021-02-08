insert into dbo.HubLogistics 
values('Gua Metro','GUM',1,null,'GT','SYS-CAQUINO', GETDATE(), NULL, NULL ,0)

select * from dbo.HubLogistics  WHERE HubStatus = 1


UPDATE dbo.TownshipByHubLogistic set IdHublogistic = 22 WHERE IdRateSegment = 2
SELECT * FROM DBO.TownshipByHubLogistic WHERE IdRateSegment = 2




