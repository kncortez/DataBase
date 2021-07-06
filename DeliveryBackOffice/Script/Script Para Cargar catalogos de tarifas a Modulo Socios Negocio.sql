
INSERT INTO dbo.CatalogbyModule
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
(   'RateType',    -- NameCatalog - nvarchar(50)
    19,    -- ModuleID - int
    2,    -- SystemID - int
    'TRUE', -- RowStatus - bit
    'SYS-ERAMIREZ',    -- TokenCreated - nvarchar(50)
    GETDATE(),    -- DateCreated - datetime
    NULL,    -- TokenUpdated - nvarchar(50)
    NULL     -- DateUpdated - datetime
    )

INSERT INTO dbo.CatalogbyModule
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
(   'RateCatalog',    -- NameCatalog - nvarchar(50)
    19,    -- ModuleID - int
    2,    -- SystemID - int
    'TRUE', -- RowStatus - bit
    'SYS-ERAMIREZ',    -- TokenCreated - nvarchar(50)
    GETDATE(),    -- DateCreated - datetime
    NULL,    -- TokenUpdated - nvarchar(50)
    NULL     -- DateUpdated - datetime
    )