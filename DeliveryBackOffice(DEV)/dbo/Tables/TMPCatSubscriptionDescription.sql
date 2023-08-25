CREATE TABLE [dbo].[TMPCatSubscriptionDescription] (
    [IdCatSubscriptionDescription] INT            NOT NULL,
    [Title]                        NVARCHAR (100) NOT NULL,
    [Description]                  NVARCHAR (500) NOT NULL,
    [Position]                     INT            NOT NULL,
    [Type]                         NVARCHAR (50)  NOT NULL,
    [CatSubscriptionId]            INT            NOT NULL,
    [RowStatus]                    BIT            NOT NULL,
    [DateCreated]                  DATETIME       NOT NULL,
    [TokenCreated]                 NVARCHAR (50)  NOT NULL,
    [DateUpdated]                  DATETIME       NULL,
    [TokenUpdated]                 NVARCHAR (50)  NULL
);

