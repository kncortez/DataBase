--Pasos para instalacion
-- 1. Eliminar SP que usa el objeto
DROP PROCEDURE dbo.SetServiceRequestFD
-- 2. Eliminar el objeto tipo tabla
DROP TYPE dbo.TblDeliveryOrdersFD;

-- 3. Crear nueva version del objeto TblDeliveryOrdersFD
-- 4. Crear nueva version de SP