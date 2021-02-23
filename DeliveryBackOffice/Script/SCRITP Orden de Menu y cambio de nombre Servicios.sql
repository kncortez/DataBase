update dbo.CatModule set ModName = 'Generar guías', ModOrder =  2 where ModName = 'Cotizador'
update dbo.CatModule set ModOrder =  3 where ModName = 'Rastreo'
update dbo.CatModule set ModOrder =  4 where ModName = 'Mi perfil'
update dbo.CatModule set ModOrder =  6 where ModName = 'Facturación'
update dbo.CatModule set ModOrder =  7 where ModName = 'Direcciones'
update dbo.CatModule set ModVisible = 0 where ModName = 'Métodos de Pago'

select * from dbo.CatModule  where ModRowStatus = 1 and ModVisible = 1 order by ModOrder


update dbo.CatTypeService set CtsShortName = 'NDD' WHERE CtsId = 2 
update dbo.CatTypeService set CtsShortName = 'SDD' WHERE CtsId = 1
select * from dbo.CatTypeService 
