USE [DeliveryBackOffice]
GO

INSERT INTO [DeliveryBackOffice].[dbo].[SegmentArea]([NameSegmentOfArea],[Abrevation],[SegmentDescription],[SegmentStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated]) VALUES('ZONA LOCAL','LOCAL','Ciudad de Guatemala y Mixco','TRUE','SYS-ERAMIREZ',GETDATE(),NULL,NULL)
INSERT INTO [DeliveryBackOffice].[dbo].[SegmentArea]([NameSegmentOfArea],[Abrevation],[SegmentDescription],[SegmentStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated]) VALUES('ZONA A','A','Municipios del Departamento de Guatemala, excepto Mixco;  Sacatepéquez, Chimaltenango, Escuintla, El Progreso.','TRUE','SYS-ERAMIREZ',GETDATE(),NULL,NULL)
INSERT INTO [DeliveryBackOffice].[dbo].[SegmentArea]([NameSegmentOfArea],[Abrevation],[SegmentDescription],[SegmentStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated]) VALUES('ZONA B','B','Chiquimula, Santa Rosa, Jalapa, Jutiapa, Quiché, Suchitepéquez, Retalhuleu, Sololá, Zacapa.','TRUE','SYS-ERAMIREZ',GETDATE(),NULL,NULL)
INSERT INTO [DeliveryBackOffice].[dbo].[SegmentArea]([NameSegmentOfArea],[Abrevation],[SegmentDescription],[SegmentStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated]) VALUES('ZONA C','C','Alta Verapaz, Huehuetenango, Izabal, Quetzaltenango, Baja Verapaz, San Marcos, Totonicapán.','TRUE','SYS-ERAMIREZ',GETDATE(),NULL,NULL)
INSERT INTO [DeliveryBackOffice].[dbo].[SegmentArea]([NameSegmentOfArea],[Abrevation],[SegmentDescription],[SegmentStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated]) VALUES('ZONA D','D','Petén','TRUE','SYS-ERAMIREZ',GETDATE(),NULL,NULL)

GO

--SELECT * FROM [DeliveryBackOffice].[dbo].[SegmentArea]

