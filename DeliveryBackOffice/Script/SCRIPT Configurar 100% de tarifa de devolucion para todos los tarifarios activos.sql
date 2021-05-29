-- Configurar 100% de tarifa de devolucion para todos los tarifarios activos


update dbo.RateHeader
set ReturnRate = 100
where RheRowStatus = 1


select * from dbo.RateHeader