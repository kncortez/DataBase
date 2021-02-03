update dbo.CatTypeService set CtsName = 'Next Day Delivery', CtsDescription = 'Entrega al siguiente dia', CtsTokenUpdated = 'SYS-CAQUINO', CtsDateUpdated = GETDATE()
where CtsShortName = 'NDD'


select * from dbo.CatTypeService