alter table dbo.RateEstimate
add IdTownshipSource int null
alter table dbo.RateEstimate
add IdTownshipDestiny int null

alter table dbo.RateEstimate
ADD CONSTRAINT FKRateTwonshipSource FOREIGN KEY (IdTownshipSource) REFERENCES dbo.Township(IdTownship)

alter table dbo.RateEstimate
ADD CONSTRAINT FKRateTwonshipDestiny FOREIGN KEY (IdTownshipDestiny) REFERENCES dbo.Township(IdTownship)

