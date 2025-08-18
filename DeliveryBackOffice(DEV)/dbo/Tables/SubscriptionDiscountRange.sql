CREATE TABLE [dbo].[SubscriptionDiscountRange] (
    [IdSubscriptionDiscountRange] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SubscriptionId]              INT            NOT NULL,
    [DiscountLowServiceRange]     INT            NOT NULL,
    [DiscountTopServiceRange]     INT            NULL,
    [ValueTypeId]                 INT            NOT NULL,
    [DiscountValue]               DECIMAL (5, 2) NOT NULL,
    [RowStatus]                   BIT            CONSTRAINT [DF_SubscriptionDiscountRange_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                NVARCHAR (50)  NOT NULL,
    [DateCreated]                 VARCHAR (50)   NOT NULL,
    [TokenUpdated]                NVARCHAR (50)  NULL,
    [DateUpdated]                 DATETIME       NULL,
    CONSTRAINT [PK_SubscriptionDiscountRange] PRIMARY KEY CLUSTERED ([IdSubscriptionDiscountRange] ASC)
);






GO
CREATE NONCLUSTERED INDEX [idx_SubscriptionId]
    ON [dbo].[SubscriptionDiscountRange]([SubscriptionId] ASC);

