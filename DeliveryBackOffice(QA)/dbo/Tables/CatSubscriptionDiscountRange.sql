CREATE TABLE [dbo].[CatSubscriptionDiscountRange] (
    [IdCatSubscriptionDiscountRange] INT            IDENTITY (1, 1) NOT NULL,
    [CatSubscriptionId]              INT            NOT NULL,
    [DiscountLowServiceRange]        INT            NOT NULL,
    [DiscountTopServiceRange]        INT            NULL,
    [ValueTypeId]                    INT            NOT NULL,
    [DiscountValue]                  DECIMAL (5, 2) NOT NULL,
    [RowStatus]                      BIT            CONSTRAINT [DF_CatSubscriptionDiscountRange_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                   NVARCHAR (50)  NOT NULL,
    [DateCreated]                    DATETIME       NOT NULL,
    [TokenUpdated]                   NVARCHAR (50)  NULL,
    [DateUpdated]                    DATETIME       NULL,
    CONSTRAINT [PK_CatSubscriptionDiscountRange] PRIMARY KEY CLUSTERED ([IdCatSubscriptionDiscountRange] ASC),
    CONSTRAINT [FK_CatSubscriptionDiscountRange_IdCatSubscription] FOREIGN KEY ([CatSubscriptionId]) REFERENCES [dbo].[CatSubscription] ([IdCatSubscription]) ON DELETE CASCADE,
    CONSTRAINT [FK_CatSubscriptionDiscountRange_ValueTypeId] FOREIGN KEY ([ValueTypeId]) REFERENCES [dbo].[CatValueType] ([IdCatValueType]) ON DELETE CASCADE
);

