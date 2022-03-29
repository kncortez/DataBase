

INSERT INTO DeliveryBackOffice.dbo.CatModule
(
ModName,
ModIdModuleParent,
ModPath,
ModDescription,
ModOrder,
ModMetadata,
ModVisible,
ModRowStatus,
ModTokenCreated,
ModDateCreated
)
VALUES
(
'Liquidación Recolecciones',              --ModName,
NULL,                         --ModIdModuleParent,
'/liquidacion-recolecciones',             --ModPath,
'Liquidación Recolecciones', --ModDescription,
15,                           --ModOrder,
'file.png',                   --ModMetadata,
1,                            --ModVisible, 
1,                            --ModRowStatus,
'SYS-MESPINOZA',              --ModTokenCreated,
GETDATE()                     --ModDateCreated
)


SELECT *
FROM DeliveryBackOffice.dbo.CatModule;