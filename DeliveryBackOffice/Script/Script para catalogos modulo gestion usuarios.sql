SELECT * FROM DeliveryBackOffice.dbo.CatalogbyModule WHERE ModuleID = 43

UPDATE DeliveryBackOffice.dbo.CatalogbyModule SET RowStatus= 'FALSE' , TokenUpdated='5Y5-3R4M1R3Z', DateUpdated= GETDATE() WHERE ModuleID = 43 

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
(   'FDstations',    -- NameCatalog - nvarchar(50)
    43,    -- ModuleID - int
    2,    -- SystemID - int
    'TRUE', -- RowStatus - bit
    '5Y5-3R4M1R3Z',    -- TokenCreated - nvarchar(50)
    GETDATE(),    -- DateCreated - datetime
    NULL,    -- TokenUpdated - nvarchar(50)
    NULL     -- DateUpdated - datetime
    )

SELECT * FROM DeliveryBackOffice.dbo.CatalogbyModule WHERE ModuleID = 43