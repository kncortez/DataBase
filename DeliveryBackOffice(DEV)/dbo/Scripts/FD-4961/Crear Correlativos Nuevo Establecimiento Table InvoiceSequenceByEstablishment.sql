-- =============================================
-- Author:      Juan Ramirez
-- Create date: 2025/06/04
-- Description: Tabla de información de correlativo por establecimiento.
-- =============================================
    DECLARE @Establishment NVARCHAR(150) = 'B001'; --Id de Establecimiento

    INSERT INTO dbo.InvoiceSequenceByEstablishment
    (
        Establishment,
        TypeDocument,
        [Sequence],
        RowStatus,
        DateCreated,
        TokenCreated,
        DateUpdated,
        TokenUpdated
    )
    VALUES
    (   @Establishment,        -- Establishment - varchar(50)
        1,      -- TypeDocument - int
        '1',      -- Sequence - varchar(500)
        1,   -- RowStatus - bit
        GETDATE(), -- DateCreated - datetime
        N'JRAMIREZ',       -- TokenCreated - nvarchar(50)
        NULL,      -- DateUpdated - datetime
        NULL       -- TokenUpdated - nvarchar(50)
        ),
    (   @Establishment,        -- Establishment - varchar(50)
        2,      -- TypeDocument - int
        '1',      -- Sequence - varchar(500)
        1,   -- RowStatus - bit
        GETDATE(), -- DateCreated - datetime
        N'JRAMIREZ',       -- TokenCreated - nvarchar(50)
        NULL,      -- DateUpdated - datetime
        NULL       -- TokenUpdated - nvarchar(50)
        ),
    (   @Establishment,        -- Establishment - varchar(50)
        4,      -- TypeDocument - int
        '1',      -- Sequence - varchar(500)
        1,   -- RowStatus - bit
        GETDATE(), -- DateCreated - datetime
        N'JRAMIREZ',       -- TokenCreated - nvarchar(50)
        NULL,      -- DateUpdated - datetime
        NULL       -- TokenUpdated - nvarchar(50)
        )

        