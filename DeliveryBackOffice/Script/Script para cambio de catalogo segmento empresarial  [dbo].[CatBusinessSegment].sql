SELECT * FROM dbo.CatBusinessSegment

UPDATE dbo.CatBusinessSegment 
SET RowStatus = 'FALSE',
TokenUpdated = 'SYS-ERAMIREZ',
DateUpdated = GETDATE()
WHERE RowStatus = 'TRUE'

INSERT INTO dbo.CatBusinessSegment
(
    BusinessSegmentName,
    BusinessSegmentDescription,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated
)
VALUES
(   N'B2B - BUSINESS TO BUSINESS',       -- BusinessSegmentName - nvarchar(75)
    N'Business to Business',       -- BusinessSegmentDescription - nvarchar(200)
    'TRUE',      -- RowStatus - bit
    N'SYS-ERAMIREZ',       -- TokenCreated - nvarchar(50)
    GETDATE(), -- DateCreated - datetime
    NULL,      -- TokenUpdated - nvarchar(50)
    NULL       -- DateUpdated - datetime
    )

INSERT INTO dbo.CatBusinessSegment
(
    BusinessSegmentName,
    BusinessSegmentDescription,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated
)
VALUES
(   N'B2C - BUSINESS TO CUSTOMER',       -- BusinessSegmentName - nvarchar(75)
    N'Business to Customer',       -- BusinessSegmentDescription - nvarchar(200)
    'TRUE',      -- RowStatus - bit
    N'SYS-ERAMIREZ',       -- TokenCreated - nvarchar(50)
    GETDATE(), -- DateCreated - datetime
    NULL,      -- TokenUpdated - nvarchar(50)
    NULL       -- DateUpdated - datetime
    )

INSERT INTO dbo.CatBusinessSegment
(
    BusinessSegmentName,
    BusinessSegmentDescription,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated
)
VALUES
(   N'C2B - CUSTOMER TO BUSINESS',       -- BusinessSegmentName - nvarchar(75)
    N'Customer to Business',       -- BusinessSegmentDescription - nvarchar(200)
    'TRUE',      -- RowStatus - bit
    N'SYS-ERAMIREZ',       -- TokenCreated - nvarchar(50)
    GETDATE(), -- DateCreated - datetime
    NULL,      -- TokenUpdated - nvarchar(50)
    NULL       -- DateUpdated - datetime
    )

INSERT INTO dbo.CatBusinessSegment
(
    BusinessSegmentName,
    BusinessSegmentDescription,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated
)
VALUES
(   N'C2C - CUSTOMER TO CUSTOMER',       -- BusinessSegmentName - nvarchar(75)
    N'Customer to Customer',       -- BusinessSegmentDescription - nvarchar(200)
    'TRUE',      -- RowStatus - bit
    N'SYS-ERAMIREZ',       -- TokenCreated - nvarchar(50)
    GETDATE(), -- DateCreated - datetime
    NULL,      -- TokenUpdated - nvarchar(50)
    NULL       -- DateUpdated - datetime
    )

SELECT * FROM dbo.CatBusinessSegment


SELECT * FROM dbo.RatebyCustomer
