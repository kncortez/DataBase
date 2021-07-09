
INSERT INTO dbo.ConfigParams
([Name],[Description],[Value],[Status],[CreateDate])
values('CODRateDef', 'Tarifa COD Default', 5,1,GETDATE())


INSERT INTO dbo.ConfigParams
([Name],[Description],[Value],[Status],[CreateDate])
values('CODExemptDef', 'Tarifa excenta de COD default', 0,1,GETDATE())


select * from dbo.ConfigParams
where Name ='CODExemptDef'

select * from dbo.ConfigParams
where Name ='CODRateDef'