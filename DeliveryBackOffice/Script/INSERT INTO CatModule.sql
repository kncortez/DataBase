SELECT * FROM DeliveryBackOffice.dbo.CatModule

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
'Guías Rápidas',--ModName,
NULL,--ModIdModuleParent,
'/guias-rapidas',--ModPath,
'Guías rápidas corporativos',--ModDescription,
13,--ModOrder,
'file.png',--ModMetadata,
1,--ModVisible, 
1,--ModRowStatus,
'SYS-MESPINOZA',--ModTokenCreated,
GETDATE()--ModDateCreated
),
(
'Cartera Clientes',--ModName,
2,--ModIdModuleParent,
'/cartera-corporativos',--ModPath,
'Cartera clientes corporativos',--ModDescription,
14,--ModOrder,
'file.png',--ModMetadata,
1,--ModVisible, 
1,--ModRowStatus,
'SYS-MESPINOZA',--ModTokenCreated,
GETDATE()--ModDateCreated
),
(
'Crear Guías',--ModName,
'express/crear-guias',--ModPath,
'Crear Guías ',--ModDescription,
2,--ModOrder,
'file.png',--ModMetadata,
1,--ModVisible, 
1,--ModRowStatus,
'SYS-MESPINOZA',--ModTokenCreated,
GETDATE()--ModDateCreated
)


