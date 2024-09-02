--FDAPI-2241
--Corrección para dejar los mismos registros de producción y solo debe insertar las nuevas regiones

UPDATE CatRegion
   SET IdCountry = 'GT'
 WHERE IdCatRegion IN (1,2,3);

INSERT INTO CatRegion (RegionName,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,IdCountry)
VALUES ('OCCIDENTAL', 1, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL, 'HN');

INSERT INTO CatRegion (RegionName,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,IdCountry)
VALUES ('NOROCCIDENTAL', 1, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL, 'HN');

INSERT INTO CatRegion (RegionName,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,IdCountry)
VALUES ('NORORIENTAL', 1, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL, 'HN');

INSERT INTO CatRegion (RegionName,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,IdCountry)
VALUES ('CENTRO OCCIDENTAL', 1, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL, 'HN');

INSERT INTO CatRegion (RegionName,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,IdCountry)
VALUES ('CENTRO ORIENTAL', 1, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL, 'HN');

INSERT INTO CatRegion (RegionName,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,IdCountry)
VALUES ('SUR', 1, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL, 'HN');

