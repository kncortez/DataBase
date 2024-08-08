USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[Geofence]
           ([CountryId],[GeofenceDescription],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[Deparment],[Town],[Zone],[SettlementId])
     VALUES
           ('HN','Honduras','TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
GO


INSERT INTO [dbo].[Point]
           ([PointDescription],[PointLatitude],[PointLongitude],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           ('Inferior Izquierda Honduras',12.96681300, -89.34936400,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL)
GO

INSERT INTO [dbo].[Point]
           ([PointDescription],[PointLatitude],[PointLongitude],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           ('Inferior Derecha Honduras',13.11937600, -83.04608200,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL)
GO


INSERT INTO [dbo].[Point]
           ([PointDescription],[PointLatitude],[PointLongitude],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           ('Superior Izquierda Honduras',15.99252300, -89.59690800,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL)
GO

INSERT INTO [dbo].[Point]
           ([PointDescription],[PointLatitude],[PointLongitude],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           ('Superior Derecha Honduras',16.11116600, -82.95493800,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL)
GO


INSERT INTO [dbo].[GeofencePoint]
           ([IdGeofence],[IdPoint],[GeofencePointOrder],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           (2,7,6,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL)
GO

INSERT INTO [dbo].[GeofencePoint]
           ([IdGeofence],[IdPoint],[GeofencePointOrder],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           (2,8,7,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL)
GO

INSERT INTO [dbo].[GeofencePoint]
           ([IdGeofence],[IdPoint],[GeofencePointOrder],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           (2,6,8,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL)
GO

INSERT INTO [dbo].[GeofencePoint]
           ([IdGeofence],[IdPoint],[GeofencePointOrder],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           (2,5,9,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL)
GO

INSERT INTO [dbo].[GeofencePoint]
           ([IdGeofence],[IdPoint],[GeofencePointOrder],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
     VALUES
           (2,7,10,'TRUE','SYS-BPEDROZA',GETDATE(),NULL,NULL)
GO




