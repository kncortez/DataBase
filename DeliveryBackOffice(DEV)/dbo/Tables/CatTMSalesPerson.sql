CREATE TABLE [dbo].[CatTMSalesPerson] (
    [IdCatTMSalesPerson] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Code]               NVARCHAR (25)  NOT NULL,
    [FirstName]          NVARCHAR (100) NOT NULL,
    [LastName]           NVARCHAR (100) NOT NULL,
    [Country]            NVARCHAR (25)  NOT NULL,
    [RegisterUserId]     BIGINT         NOT NULL,
    [RowStatus]          BIT            NOT NULL,
    [DateCreated]        DATETIME       NOT NULL,
    [TokenCreated]       NVARCHAR (50)  NOT NULL,
    [DateUpdated]        DATETIME       NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
    [CatSaleAdvisorId]   INT            NULL,
    PRIMARY KEY CLUSTERED ([IdCatTMSalesPerson] ASC),
    CONSTRAINT [FK_CatTMSalesPerson_CatSaleAdvisor] FOREIGN KEY ([CatSaleAdvisorId]) REFERENCES [dbo].[CatSaleAdvisor] ([IdSaleAdvisor]),
    CONSTRAINT [FK_CatTMSalesPerson_RegisterUser] FOREIGN KEY ([RegisterUserId]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para vincular registros de tabla CatTMSalesPerson con tabla CatSaleAdvisor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTMSalesPerson', @level2type = N'COLUMN', @level2name = N'CatSaleAdvisorId';

