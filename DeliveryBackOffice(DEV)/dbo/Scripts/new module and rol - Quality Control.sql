--DATOS DEL USUARIO QUIEN REGISTRA LA INFORMACIÓN
DECLARE @TokenCreated AS NVARCHAR(50) = 'SYS-ADMIN' 

DECLARE @System AS int
SET @System = (SELECT SysIdSystem FROM DeliveryBackOffice.dbo.CatSystem)

INSERT INTO DeliveryBackOffice.dbo.CatRol
(
    RolIdSystem,
    RolName,
    RolDescription,
    RolAdminBrothers,
    RolAdminClient,
    RolRowStatus,
    RolTokenCreated,
    RolDateCreated,
    RolokenUpdated,
    RolDateUpdated,
    RolAdminInternal
)
VALUES
(   @System,         -- RolIdSystem - int 
    'Control Calidad',        -- RolName - varchar(50)
    'Rol para usuarios de control de calidad',        -- RolDescription - varchar(100)
    NULL,      -- RolAdminBrothers - bit
    0,      -- RolAdminClient - bit
    1,      -- RolRowStatus - bit
    @TokenCreated,        -- RolTokenCreated - varchar(50)
    GETDATE(), -- RolDateCreated - datetime
    NULL,      -- RolokenUpdated - varchar(50)
    NULL,      -- RolDateUpdated - datetime
    NULL       -- RolAdminInternal - bit
    )

DECLARE @IDRol int;
SET @IDRol = SCOPE_IDENTITY();
SELECT @IDRol 'IdRol'

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
    ModDateUpdated,
    ModGroup
)
VALUES
(   'Control de calidad',        -- ModName - varchar(100)
    NULL,      -- ModIdModuleParent - int
    '/control-calidad/control-calidad',        -- ModPath - varchar(200)
    'Modulo control de calidad',      -- ModDescription - varchar(150)
    1,         -- ModOrder - int
    'fa fa-server fa-1x',      -- ModMetadata - varchar(50)
    1,      -- ModVisible - bit
    1,      -- ModRowStatus - bit
    @TokenCreated,        -- ModTokenCreated - varchar(50)
    GETDATE(), -- ModDateCreated - datetime
    NULL,      -- ModTokenUpdated - varchar(50)
    NULL,      -- ModDateUpdated - datetime
    1    -- ModGroup - int
    )

DECLARE @IDModule int;
SET @IDModule = SCOPE_IDENTITY();
SELECT @IDModule 'IdModule'