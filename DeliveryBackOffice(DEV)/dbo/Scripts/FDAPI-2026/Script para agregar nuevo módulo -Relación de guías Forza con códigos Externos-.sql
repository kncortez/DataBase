--Script para agregar nuevo m�dulo -Relaci�n de gu�as Forza con c�digos Externos-
DECLARE @Token NVARCHAR(50) = N'SYS-BHERRERA'; --Token de creaci�n
DECLARE @Order INT = 0;
DECLARE @IdRol INT = 0;
DECLARE @IdSystem INT = 0;
DECLARE @ID INT;


INSERT INTO [dbo].[CatRol]
           ([RolIdSystem]
           ,[RolName]
           ,[RolDescription]
           ,[RolAdminBrothers]
           ,[RolAdminClient]
           ,[RolRowStatus]
           ,[RolTokenCreated]
           ,[RolDateCreated]
           ,[RolokenUpdated]
           ,[RolDateUpdated]
           ,[RolAdminInternal])
     VALUES
           (1
           ,'ACorp+AsignaciónGuías'
           ,'ACorp+AsignaciónGuías'
           ,NULL
           ,0
           ,1
           ,'SYS-AIXCHOP'
           ,GETDATE()
           ,NULL
           ,NULL
           ,0);

SET @IdRol = SCOPE_IDENTITY();

SELECT @IdSystem = SysIdSystem
FROM dbo.CatSystem
WHERE SysNameSystem = 'Hermes Web';


SELECT @Order = MAX(A3.ModOrder) + 1
FROM dbo.CatRol A1
    INNER JOIN RolByModuleBySystem A2
        ON A2.RmsIdRol = A1.RolIdRol
    INNER JOIN dbo.CatModule A3
        ON A3.ModIdModule = A2.RmsIdModule
WHERE RolName LIKE '%Admin Corp%'
      AND A2.RmsRowStatus = 1
      AND A3.ModRowStatus = 1;


INSERT INTO dbo.CatModule
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
(   'Asignaci�n de gu�as',                          -- ModName - varchar(100)
    NULL,                                           -- ModIdModuleParent - int
    '/guide-assignment',                            -- ModPath - varchar(200)
    'Relaci�n de gu�as Forza con c�digos Externos', -- ModDescription - varchar(150)
    @Order,                                         -- ModOrder - int
    'file.png',                                     -- ModMetadata - varchar(50)
    1,                                              -- ModVisible - bit
    1,                                              -- ModRowStatus - bit
    @Token,                                         -- ModTokenCreated - varchar(50)
    GETDATE(),                                      -- ModDateCreated - datetime
    NULL,                                           -- ModTokenUpdated - varchar(50)
    NULL,                                           -- ModDateUpdated - datetime
    NULL                                            -- ModGroup - int
    );

SET @ID = SCOPE_IDENTITY();

INSERT INTO DeliveryBackOffice.dbo.RolByModuleBySystem
(
    RmsIdRol,
    RmsIdSystem,
    RmsIdModule,
    RmsRowStatus,
    RmsTokenCreated,
    RmsDateCreated,
    RmsTokenUpdated,
    RmsDateUpdated,
    RmsModuleMenu,
    RmsHasNewFunction
)
VALUES
(   @IdRol,    -- RmsIdRol - int
    @IdSystem, -- RmsIdSystem - int
    @ID,       -- RmsIdModule - int
    1,         -- RmsRowStatus - bit
    @Token,    -- RmsTokenCreated - varchar(50)
    GETDATE(), -- RmsDateCreated - datetime
    NULL,      -- RmsTokenUpdated - varchar(50)
    NULL,      -- RmsDateUpdated - datetime
    NULL,      -- RmsModuleMenu - int
    NULL       -- RmsHasNewFunction - bit
    );
