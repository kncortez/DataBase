
-- Ejecturat por partes

ALTER TABLE dbo.CatTypeService
ADD RateGroup INT;

UPDATE dbo.CatTypeService SET RateGroup=1
WHERE CtsId in(1,2) 

UPDATE dbo.CatTypeService SET RateGroup=2
WHERE CtsId in(3) 

select * from dbo.CatTypeService

