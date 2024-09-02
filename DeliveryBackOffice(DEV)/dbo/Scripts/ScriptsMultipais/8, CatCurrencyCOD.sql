--FDAPI-2241
-- =============================================
-- Author:      <Daniel, Ramirez >
-- Create date: <2024-06-06>
-- Description: <Se agrega el valor de la moneda lempira>
-- =============================================
WITH ValoresTemporales 
  AS (
      SELECT *
        FROM ( VALUES
               (4, 'LEMPIRA',NULL,'HNL','340','1','SYS-DRAMIREZ',GETDATE(),NULL,NULL)
             ) AS temp(IdCatCurrencyCOD,[Name],Symbol,CodeISO,
                       NumISO,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated)
     )
MERGE INTO CatCurrencyCOD AS cts
USING ValoresTemporales AS vtemp
   ON cts.IdCatCurrencyCOD = vtemp.IdCatCurrencyCOD
 WHEN NOT MATCHED THEN
      INSERT ([Name],Symbol,CodeISO,NumISO,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated)
      VALUES (vtemp.[Name],vtemp.Symbol,vtemp.CodeISO,vtemp.NumISO,vtemp.RowStatus,vtemp.TokenCreated,vtemp.DateCreated,vtemp.TokenUpdated,vtemp.DateUpdated)
 WHEN MATCHED 
      THEN UPDATE 
  SET cts.[Name] = vtemp.[Name],
      cts.Symbol = vtemp.Symbol,
      cts.CodeISO = vtemp.CodeISO,
      cts.NumISO = vtemp.NumISO,
      cts.RowStatus = vtemp.RowStatus,
      cts.TokenCreated = vtemp.TokenCreated,
      cts.DateCreated = vtemp.DateCreated,
      cts.TokenUpdated = vtemp.TokenUpdated,
      cts.DateUpdated = vtemp.DateUpdated;
