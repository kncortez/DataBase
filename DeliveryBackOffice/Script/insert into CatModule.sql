insert into CatModule (ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated, ModTokenUpdated, ModDateUpdated)
values ('Cierres', null, '/cierres', 'Cierres', 11, 'file.png', 1,1,'SYS-HGOMEZ', GETDATE(), null, null)

insert into CatModule (ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated, ModTokenUpdated, ModDateUpdated)
values ('Reportes', null, '/reportes', 'Reportes', 12, 'file.png', 1,1,'SYS-HGOMEZ', GETDATE(), null, null)

select * from CatModule

insert into RolByModuleBySystem (RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsTokenUpdated, RmsDateUpdated)
values (4,1,27,1,'SYS-HGOMEZ', GETDATE(), null, null)


insert into RolByModuleBySystem (RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsTokenUpdated, RmsDateUpdated)
values (4,1,28,1,'SYS-HGOMEZ', GETDATE(), null, null)

select * from RolByModuleBySystem



insert into ConfigParams (Name, Description, Value, Status, CreateDate)
values ('ClosureExpressCenter', 'Dirección del reporte de cierre de express center','http://192.168.31.57/ReportServer/Pages/ReportViewer?/ForzaDelivery%2freportClosure', 1 , GETDATE())

select * from ConfigParams