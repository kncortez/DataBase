--Corrección, tiene como dependencia el insert de los township
USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatRoute]
           ([CodeRoute],[Description],[IdTownship],[IdTypeRoute],[Zone],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           ('HN001','RUTA PRUEBA 1 HONDURAS',346,2,NULL,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL);
GO

INSERT INTO [dbo].[CatRoute]
           ([CodeRoute],[Description],[IdTownship],[IdTypeRoute],[Zone],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           ('HN002','RUTA PRUEBA 2 HONDURAS',346,2,NULL,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL);
GO

INSERT INTO [dbo].[CatRoute]
           ([CodeRoute],[Description],[IdTownship],[IdTypeRoute],[Zone],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           ('HN003','RUTA PRUEBA 3 HONDURAS',347,2,NULL,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL);
GO

INSERT INTO [dbo].[CatRoute]
           ([CodeRoute],[Description],[IdTownship],[IdTypeRoute],[Zone],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           ('HN004','RUTA PRUEBA 4 HONDURAS',361,2,NULL,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL);
GO

INSERT INTO [dbo].[CatRoute]
           ([CodeRoute],[Description],[IdTownship],[IdTypeRoute],[Zone],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           ('HN005','RUTA PRUEBA 5 HONDURAS',346,2,NULL,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL);
GO

INSERT INTO [dbo].[CatRoute]
           ([CodeRoute],[Description],[IdTownship],[IdTypeRoute],[Zone],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           ('HN006','RUTA PRUEBA 6 HONDURAS',347,2,NULL,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL);
GO