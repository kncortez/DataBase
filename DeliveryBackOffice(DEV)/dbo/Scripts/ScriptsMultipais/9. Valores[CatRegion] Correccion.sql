--FDAPI-2241
--Corrección para dejar los mismos registros de producción y solo debe insertar las nuevas regiones
WITH ValoresTemporales 
  AS (
      SELECT *
        FROM ( VALUES
               (1, 'CENTRAL', 1, 'SYS-AIXCHOP', '2022-02-22 23:22:39.533', 'SYS-DRAMIREZ', GETDATE(), 'GT'),
               (2, 'NORORIENTE', 1, 'SYS-AIXCHOP', '2022-02-22 23:22:39.533', 'SYS-DRAMIREZ', GETDATE(), 'GT'),
               (3, 'SUROCCIDENTE', 1, 'SYS-AIXCHOP', '2022-02-22 23:22:39.533', 'SYS-DRAMIREZ', GETDATE(), 'GT'),
               (4, 'OCCIDENTAL', 1, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL, 'HN'),
               (5, 'NOROCCIDENTAL', 1, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL, 'HN'),
               (6, 'NORORIENTAL', 1, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL, 'HN'),
               (7, 'CENTRO OCCIDENTAL', 1, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL, 'HN'),
               (8, 'CENTRO ORIENTAL', 1, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL, 'HN'),
               (9, 'SUR', 1, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL, 'HN')
             ) AS temp(IdCatRegion,RegionName,RowStatus,TokenCreated,
                       DateCreated,TokenUpdated,DateUpdated,IdCountry)
     )
MERGE INTO CatRegion AS cts
USING ValoresTemporales AS vtemp
   ON cts.IdCatRegion = vtemp.IdCatRegion
 WHEN NOT MATCHED THEN
      INSERT (RegionName,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,IdCountry)
      VALUES (vtemp.RegionName,vtemp.RowStatus,vtemp.TokenCreated,
              vtemp.DateCreated,vtemp.TokenUpdated,vtemp.DateUpdated,vtemp.IdCountry)
 WHEN MATCHED 
      THEN UPDATE 
  SET cts.RegionName = vtemp.RegionName,
      cts.RowStatus = vtemp.RowStatus,
      cts.TokenCreated = vtemp.TokenCreated,
      cts.DateCreated = vtemp.DateCreated,
      cts.TokenUpdated = vtemp.TokenUpdated,
      cts.DateUpdated = vtemp.DateUpdated,
      cts.IdCountry = vtemp.IdCountry;