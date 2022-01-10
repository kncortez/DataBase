DECLARE @rol BIGINT = (SELECT RolIdRol FROM DeliveryBackOffice.dbo.CatRol WHERE RolName='Concesionario');


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
1,--RmsIdModule,
1,--RmsRowStatus,
'SYS-MESPINOZA',--RmsTokenCreated,
GETDATE()--RmsDateCreated
),
(
@rol,--RmsIdRol,
1,--RmsIdSystem,
2,--RmsIdModule,
1,--RmsRowStatus,
'SYS-MESPINOZA',--RmsTokenCreated,
GETDATE()--RmsDateCreated
),
(
@rol,--RmsIdRol,
1,--RmsIdSystem,
6,--RmsIdModule,
1,--RmsRowStatus,
'SYS-MESPINOZA',--RmsTokenCreated,
GETDATE()--RmsDateCreated
),
(
@rol,--RmsIdRol,
1,--RmsIdSystem,
7,--RmsIdModule,
1,--RmsRowStatus,
'SYS-MESPINOZA',--RmsTokenCreated,
GETDATE()--RmsDateCreated
),
(
@rol,--RmsIdRol,
1,--RmsIdSystem,
8,--RmsIdModule,
1,--RmsRowStatus,
'SYS-MESPINOZA',--RmsTokenCreated,
GETDATE()--RmsDateCreated
),
(
@rol,--RmsIdRol,
1,--RmsIdSystem,
10,--RmsIdModule,
1,--RmsRowStatus,
'SYS-MESPINOZA',--RmsTokenCreated,
GETDATE()--RmsDateCreated
),
(
@rol,--RmsIdRol,
1,--RmsIdSystem,
14,--RmsIdModule,
1,--RmsRowStatus,
'SYS-MESPINOZA',--RmsTokenCreated,
GETDATE()--RmsDateCreated
)


SELECT cm.ModName, RmsIdModule FROM DeliveryBackOffice.dbo.RolByModuleBySystem 
JOIN DeliveryBackOffice.dbo.CatModule cm ON cm.ModIdModule=RmsIdModule 
WHERE RmsIdRol=@rol AND RmsRowStatus=1
