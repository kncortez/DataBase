CREATE TABLE [dbo].[VisitPointByClientPortfolio] (
    [IdVisitPointByClientPortfolio] BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
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
    [id_relation]                   BIGINT         NULL,
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
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'IdVisitPointByClientPortfolio'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Primer nombre',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'FirstName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Segundo nombre',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'SecondName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Primer apellido',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'LastName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Segundo Apellido',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'SecondLastName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'Email'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Prefijo de numero(+502)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'NirPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Número de teléfono',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'Phone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'CUI',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'CUI'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Id de punto de visita',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'VisitPointId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Datos de puntos de visita por cartera de cliente corporativo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByClientPortfolio',
    @level2type = NULL,
    @level2name = NULL