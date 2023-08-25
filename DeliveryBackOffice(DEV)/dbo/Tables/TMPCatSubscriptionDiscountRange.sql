CREATE TABLE [dbo].[TMPCatSubscriptionDiscountRange] (
    [IdCatSubscriptionDiscountRange] INT            NOT NULL,
    [CatSubscriptionId]              INT            NOT NULL,
    [DiscountLowServiceRange]        INT            NOT NULL,
    [DiscountTopServiceRange]        INT            NULL,
    [ValueTypeId]                    INT            NOT NULL,
    [DiscountValue]                  DECIMAL (5, 2) NOT NULL,
    [RowStatus]                      BIT            NOT NULL,
    [TokenCreated]                   NVARCHAR (50)  NOT NULL,
    [DateCreated]                    DATETIME       NOT NULL,
    [TokenUpdated]                   NVARCHAR (50)  NULL,
    [DateUpdated]                    DATETIME       NULL
);

