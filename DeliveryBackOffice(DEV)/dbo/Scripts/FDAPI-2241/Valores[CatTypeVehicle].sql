
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-06-04>
-- Description: <Valores para CatTypeVehicle de honduras>
-- =============================================

--Insertar valores de HN
   INSERT CatTypeVehicle
   SELECT [name], [Description], RowStatus, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL, PackageSize, 'HN'
     FROM CatTypeVehicle
    WHERE RowStatus = 1