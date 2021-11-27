SELECT * FROM  [dbo].[CatModule]
WHERE ModPath = 'FrmBusinessPartner'

SELECT * FROM dbo.CatalogbyModule
WHERE ModuleID = 43

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
(   'ExpressCenter',    -- NameCatalog - nvarchar(50)
    43,    -- ModuleID - int
    2,    -- SystemID - int
    'TRUE', -- RowStatus - bit
    '5Y5-3R4M1R3Z',    -- TokenCreated - nvarchar(50)
    GETDATE(),    -- DateCreated - datetime
    NULL,    -- TokenUpdated - nvarchar(50)
    NULL     -- DateUpdated - datetime
)


EXEC dbo.sphdGetCatalog @IdCorrelative = -1, -- int
                        @Calalog = N'all',     -- nvarchar(50)
                        @IdFilter = N'GT',    -- nvarchar(10)
                        @IdModule = 43,      -- int
                        @IdParentFilter = -1 -- int




