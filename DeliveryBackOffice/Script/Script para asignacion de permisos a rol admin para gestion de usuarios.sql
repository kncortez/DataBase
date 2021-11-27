SELECT * FROM dbo.RolByUserBySystem WHERE RusIdSystem =2 
SELECT * FROM dbo.RolByModuleBySystem WHERE RmsIdSystem = 2 

SELECT * FROM dbo.CatModule

INSERT INTO dbo.RolByModuleBySystem
(
    RmsIdRol,
    RmsIdSystem,
    RmsIdModule,
    RmsRowStatus,
    RmsTokenCreated,
    RmsDateCreated,
    RmsTokenUpdated,
    RmsDateUpdated
)
VALUES
(   4,         -- RmsIdRol - int
    2,         -- RmsIdSystem - int
    41,         -- RmsIdModule - int
    'TRUE',      -- RmsRowStatus - bit
    '5Y5-3R4M1R3Z',        -- RmsTokenCreated - varchar(50)
    GETDATE(), -- RmsDateCreated - datetime
    NULL,      -- RmsTokenUpdated - varchar(50)
    NULL       -- RmsDateUpdated - datetime
    )

INSERT INTO dbo.RolByModuleBySystem
(
    RmsIdRol,
    RmsIdSystem,
    RmsIdModule,
    RmsRowStatus,
    RmsTokenCreated,
    RmsDateCreated,
    RmsTokenUpdated,
    RmsDateUpdated
)
VALUES
(   4,         -- RmsIdRol - int
    2,         -- RmsIdSystem - int
    42,         -- RmsIdModule - int
    'TRUE',      -- RmsRowStatus - bit
    '5Y5-3R4M1R3Z',        -- RmsTokenCreated - varchar(50)
    GETDATE(), -- RmsDateCreated - datetime
    NULL,      -- RmsTokenUpdated - varchar(50)
    NULL       -- RmsDateUpdated - datetime
    )


INSERT INTO dbo.RolByModuleBySystem
(
    RmsIdRol,
    RmsIdSystem,
    RmsIdModule,
    RmsRowStatus,
    RmsTokenCreated,
    RmsDateCreated,
    RmsTokenUpdated,
    RmsDateUpdated
)
VALUES
(   4,         -- RmsIdRol - int
    2,         -- RmsIdSystem - int
    43,         -- RmsIdModule - int
    'TRUE',      -- RmsRowStatus - bit
    '5Y5-3R4M1R3Z',        -- RmsTokenCreated - varchar(50)
    GETDATE(), -- RmsDateCreated - datetime
    NULL,      -- RmsTokenUpdated - varchar(50)
    NULL       -- RmsDateUpdated - datetime
    )