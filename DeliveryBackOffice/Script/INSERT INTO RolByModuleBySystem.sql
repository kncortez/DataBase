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
6,--RmsIdRol,
1,--RmsIdSystem,
31,--RmsIdModule,
1,--RmsRowStatus,
'SYS-MESPINOZA',--RmsTokenCreated,
GETDATE()--RmsDateCreated
),
(
6,--RmsIdRol,
1,--RmsIdSystem,
32,--RmsIdModule,
1,--RmsRowStatus,
'SYS-MESPINOZA',--RmsTokenCreated,
GETDATE()--RmsDateCreated
),
(
6,--RmsIdRol,
1,--RmsIdSystem,
38,--RmsIdModule,
1,--RmsRowStatus,
'SYS-MESPINOZA',--RmsTokenCreated,
GETDATE()--RmsDateCreated
)

UPDATE DeliveryBackOffice.dbo.RolByModuleBySystem
SET RmsRowStatus=0
WHERE RmsIdRol=6 AND RmsIdModule=5 

UPDATE DeliveryBackOffice.dbo.RolByModuleBySystem
SET RmsRowStatus=0
WHERE RmsIdRol=6 AND RmsIdModule=9

UPDATE DeliveryBackOffice.dbo.RolByModuleBySystem
SET RmsRowStatus=0
WHERE RmsIdRol=6 AND RmsIdModule=24

SELECT cm.ModName, RmsIdModule FROM DeliveryBackOffice.dbo.RolByModuleBySystem 
JOIN DeliveryBackOffice.dbo.CatModule cm ON cm.ModIdModule=RmsIdModule 
WHERE RmsIdRol=6 AND RmsRowStatus=1
