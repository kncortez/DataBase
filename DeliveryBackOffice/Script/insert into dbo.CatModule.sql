insert into dbo.CatModule
 ([ModName], [ModIdModuleParent], [ModPath], [ModDescription]
 , [ModOrder], [ModMetadata], [ModVisible], [ModRowStatus], [ModTokenCreated]
 , [ModDateCreated])
 values
 ('Recolección',NULL,'cost','Recolección de guías', 1, null, 0, 1
 , 'SYS-HGOMEZ', GETDATE())
 ,
 ('POD',NULL,'cost','Entrega de guías', 1, null, 0, 1
 , 'SYS-HGOMEZ', GETDATE())
 select * from CatModule