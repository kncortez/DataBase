CREATE TABLE [dbo].[RatebyCustomer] (
    [RbcId]              BIGINT       IDENTITY (1, 1) NOT NULL,
    [RbcIdRate]          INT          NOT NULL,
    [RbcIdCustomer]      INT          NOT NULL,
    [RbcRowStatus]       BIT          NOT NULL,
    [RbcTokenCreated]    VARCHAR (50) NOT NULL,
    [RbcDateCreated]     DATETIME     NOT NULL,
    [RbcTokenUpdated]    VARCHAR (50) NULL,
    [RbcDateUpdated]     DATETIME     NULL,
    [RbcCodeOfReference] INT          NULL,
    PRIMARY KEY CLUSTERED ([RbcId] ASC),
    FOREIGN KEY ([RbcCodeOfReference]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [FKRbcCustomer] FOREIGN KEY ([RbcIdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FKRbcRate] FOREIGN KEY ([RbcIdRate]) REFERENCES [dbo].[RateHeader] ([RheId])
);


GO
CREATE NONCLUSTERED INDEX [IX_RatebyCustomer]
    ON [dbo].[RatebyCustomer]([RbcIdCustomer] ASC, [RbcRowStatus] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para vincular tarifario con un punto de visita.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RatebyCustomer', @level2type = N'COLUMN', @level2name = N'RbcCodeOfReference';

