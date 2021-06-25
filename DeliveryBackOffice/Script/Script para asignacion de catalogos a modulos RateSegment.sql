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
(   'RateSegment',    -- NameCatalog - nvarchar(50)
    20,    -- ModuleID - int
    2,    -- SystemID - int
    'TRUE', -- RowStatus - bit
    'SYS-ERAMIREZ',    -- TokenCreated - nvarchar(50)
    GETDATE(),    -- DateCreated - datetime
    NULL,    -- TokenUpdated - nvarchar(50)
    NULL     -- DateUpdated - datetime
    )