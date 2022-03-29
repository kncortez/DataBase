DECLARE @rol BIGINT = (SELECT RolIdRol FROM DeliveryBackOffice.dbo.CatRol WHERE RolName='ADMINISTRACION Y CIERRES EXC PORTAL WEB');
DECLARE @IdModule BIGINT = (SELECT ModIdModule FROM DeliveryBackOffice.dbo.CatModule WHERE ModName='Liquidación Recolecciones')
--RmsIdSystem numero 1 es Portal Web
--RmsIdModule id de modulo nuevo que se asignara a un rol


INSERT INTO DeliveryBackOffice.dbo.RolByModuleBySystem 
(
RmsIdRol,
RmsIdSystem,
RmsIdModule,
RmsRowStatus,
RmsTokenCreated,
RmsDateCreated
)
VALUES
(
@rol,--RmsIdRol,
1,--RmsIdSystem,
@IdModule,--RmsIdModule,
1,--RmsRowStatus,
'SYS-MESPINOZA',--RmsTokenCreated,
GETDATE()--RmsDateCreated
)

---- Script para confirmar los modulos que tiene asignado el rol
SELECT cm.ModName, RmsIdModule, cm.ModPath FROM DeliveryBackOffice.dbo.RolByModuleBySystem 
JOIN DeliveryBackOffice.dbo.CatModule cm ON cm.ModIdModule=RmsIdModule 
WHERE RmsIdRol=@rol AND RmsRowStatus=1
