
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-06-04>
-- Description: <Valores para CatVehicleCategories de honduras>
-- =============================================

--Actualizar valores de GT
UPDATE CatVehicleCategories
   SET Idcountry = 'GT',
       TokenUpdated = 'SYS-DRAMIREZ',
       DateUpdated = GETDATE()
 WHERE Idcountry IS NULL

--Insertar valores de HN
INSERT INTO CatVehicleCategories
SELECT [name], RowStatus, 'SYS-DRAMIREZ',GETDATE(),NULL,NULL,NULL,NULL, NULL, NULL,'HN'
  FROM dbo.CatVehicleCategories
 WHERE RowStatus = 1