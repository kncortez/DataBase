CREATE TABLE [dbo].[VisitPointByClientPortfolio] (
    [IdVisitPointByClientPortfolio] BIGINT         IDENTITY (1, 1) NOT NULL,
    [FirstName]                     NVARCHAR (50)  NULL,
    [SecondName]                    NVARCHAR (50)  NULL,
    [LastName]                      NVARCHAR (50)  NULL,
    [SecondLastName]                NVARCHAR (50)  NULL,
    [Email]                         NVARCHAR (200) NULL,
    [NirPhone]                      NVARCHAR (10)  NULL,
    [Phone]                         NVARCHAR (20)  NULL,
    [CUI]                           NVARCHAR (100) NULL,
    [VisitPointId]                  INT            NULL,
    [RowStatus]                     BIT            NOT NULL,
    [TokenCreated]                  NVARCHAR (150) NOT NULL,
    [DateCreated]                   DATETIME       NOT NULL,
    [TokenUpdated]                  NVARCHAR (150) NULL,
    [DateUpdated]                   DATETIME       NULL,
    [InternalCode]                  VARCHAR (50)   NULL,
    [TaxId]                         VARCHAR (50)   NULL,
    [ContactName]                   VARCHAR (50)   NULL,
    [IsBusiness]                    BIT            NULL,
    CONSTRAINT [PK_VisitPointByClientPortfolio] PRIMARY KEY CLUSTERED ([IdVisitPointByClientPortfolio] ASC)
);








GO
CREATE NONCLUSTERED INDEX [IX_VisitPointByClientPortfolio_LoadList]
    ON [dbo].[VisitPointByClientPortfolio]([VisitPointId] ASC, [RowStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_VisitPointByClientPortfolioLS]
    ON [dbo].[VisitPointByClientPortfolio]([LastName] ASC, [SecondLastName] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_VisitPointByClientPortfolioFSC]
    ON [dbo].[VisitPointByClientPortfolio]([FirstName] ASC, [SecondName] ASC, [CUI] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_VisitPointByClientPortfolio]
    ON [dbo].[VisitPointByClientPortfolio]([Email] ASC, [Phone] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IdVisitPointByClientPortafolio]
    ON [dbo].[VisitPointByClientPortfolio]([IdVisitPointByClientPortfolio] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NIt de cartera de cliente corporativo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointByClientPortfolio', @level2type = N'COLUMN', @level2name = N'TaxId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Codigo interno de cliente corporativo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointByClientPortfolio', @level2type = N'COLUMN', @level2name = N'InternalCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contacto de cartera de cliente corporativo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointByClientPortfolio', @level2type = N'COLUMN', @level2name = N'ContactName';


GO
CREATE NONCLUSTERED INDEX [IDX_Phone]
    ON [dbo].[VisitPointByClientPortfolio]([Phone] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'bandera indica si el tipo de cliente es individual o empresarial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointByClientPortfolio', @level2type = N'COLUMN', @level2name = N'IsBusiness';

