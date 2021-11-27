--script para configuracion de modulo gestion de usuarios
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
    ModDateCreated,
    ModTokenUpdated,
    ModDateUpdated
)
VALUES
(   'Administración',        -- ModName - varchar(100)
    NULL,      -- ModIdModuleParent - int
    '',        -- ModPath - varchar(200)
    'Administración del sistema',      -- ModDescription - varchar(150)
    1,         -- ModOrder - int
    '',      -- ModMetadata - varchar(50)
    'TRUE',      -- ModVisible - bit
    'TRUE',      -- ModRowStatus - bit
    '5Y5-3R4M1R3Z',        -- ModTokenCreated - varchar(50)
    GETDATE(), -- ModDateCreated - datetime
    NULL,      -- ModTokenUpdated - varchar(50)
    NULL       -- ModDateUpdated - datetime
    )

DECLARE @IdModule AS INT 
DECLARE @IdModuleParentUsr  AS INT 

SET @IdModule = (SELECT ModIdModule FROM DeliveryBackOffice.dbo.CatModule WHERE ModName = 'Administración' AND ModDescription = 'Administración del sistema')

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
    ModDateCreated,
    ModTokenUpdated,
    ModDateUpdated
)
VALUES
(   'Gestión',        -- ModName - varchar(100)
    @IdModule,      -- ModIdModuleParent - int
    'Gestión System Admin',        -- ModPath - varchar(200)
    'Gestión System Admin',      -- ModDescription - varchar(150)
    1,         -- ModOrder - int
    '',      -- ModMetadata - varchar(50)
    'TRUE',      -- ModVisible - bit
    'TRUE',      -- ModRowStatus - bit
    '5Y5-3R4M1R3Z',        -- ModTokenCreated - varchar(50)
    GETDATE(), -- ModDateCreated - datetime
    NULL,      -- ModTokenUpdated - varchar(50)
    NULL       -- ModDateUpdated - datetime
    )

SET @IdModuleParentUsr = (SELECT ModIdModule FROM DeliveryBackOffice.dbo.CatModule WHERE ModName = 'Gestión' AND ModDescription = 'Gestión System Admin' AND ModPath = 'Gestión System Admin')

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
    ModDateCreated,
    ModTokenUpdated,
    ModDateUpdated
)
VALUES
(   'Usuarios',        -- ModName - varchar(100)
    @IdModuleParentUsr,      -- ModIdModuleParent - int
    'FrmUserManagement',        -- ModPath - varchar(200)
    'Gestión de Usuarios',      -- ModDescription - varchar(150)
    1,         -- ModOrder - int
    '',      -- ModMetadata - varchar(50)
    'TRUE',      -- ModVisible - bit
    'TRUE',      -- ModRowStatus - bit
    '5Y5-3R4M1R3Z',        -- ModTokenCreated - varchar(50)
    GETDATE(), -- ModDateCreated - datetime
    NULL,      -- ModTokenUpdated - varchar(50)
    NULL       -- ModDateUpdated - datetime
    )

SELECT TOP (5) * FROM dbo.CatModule ORDER BY 1 DESC 

DECLARE @IdModuleUsr AS INT 

SET @IdModuleUsr = (SELECT ModIdModule FROM DeliveryBackOffice.dbo.CatModule WHERE ModPath = 'FrmUserManagement')

PRINT @IdModuleUsr

INSERT INTO DeliveryBackOffice.dbo.CatalogbyModule
(
    NameCatalog,
    ModuleID,
    SystemID,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated
)
VALUES
(   'HubLogistics',    -- NameCatalog - nvarchar(50)
    @IdModuleUsr,    -- ModuleID - int
    2,    -- SystemID - int
    'TRUE', -- RowStatus - bit
    '5Y5-3R4M1R3Z',    -- TokenCreated - nvarchar(50)
    GETDATE(),    -- DateCreated - datetime
    NULL,    -- TokenUpdated - nvarchar(50)
    NULL     -- DateUpdated - datetime
    )