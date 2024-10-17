INSERT INTO InvoiceBatchRelationships (
    Id_Lote,
    CodeOfReference,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated,
    IdStation
)
VALUES (
    -- Sustituye estos valores por los que necesites
    11,             -- Id_Lote
    0,              -- CodeOfReference
    1,              -- RowStatus (1 para true, 0 para false)
    'SYS-DRAMIREZ', -- TokenCreated
    GETDATE(),      -- DateCreated (fecha y hora actual)
    NULL,           -- TokenUpdated
    NULL,           -- DateUpdated (fecha y hora actual)
    273             -- IdStation
);