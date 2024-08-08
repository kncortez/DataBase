
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-06-04>
-- Description: <Valores para CatVehicleCategories de honduras>
-- =============================================

 INSERT INTO CatVehicleBrand
 SELECT [name], RowStatus, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL,'HN'
   FROM CatVehicleBrand
  WHERE RowStatus = 1
