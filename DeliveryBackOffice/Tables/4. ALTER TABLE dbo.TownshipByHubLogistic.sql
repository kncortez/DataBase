ALTER TABLE dbo.TownshipByHubLogistic 
ADD IdRateSegment int null
ALTER TABLE dbo.TownshipByHubLogistic 
ADD CONSTRAINT FKHubRateSegment FOREIGN KEY (IdRateSegment) REFERENCES CatRateSegment(CrsId)

update dbo.TownshipByHubLogistic set IdRateSegment = ( select top 1 CrsId from CatRateSegment where CrsShortName = 'FOR')
where IdHublogistic = 1

update dbo.TownshipByHubLogistic set IdRateSegment = ( select top 1 CrsId from CatRateSegment where CrsShortName = 'LOC')
where IdHublogistic = 1 AND IdTownship IN(73,80,84)

update dbo.TownshipByHubLogistic set IdRateSegment = ( select top 1 CrsId from CatRateSegment where CrsShortName = 'MET')
where IdHublogistic = 1 AND IdTownship IN(79,78,74,86,81,87)

