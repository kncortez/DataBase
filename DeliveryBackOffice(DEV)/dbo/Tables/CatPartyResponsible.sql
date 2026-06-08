CREATE TABLE [dbo].[CatPartyResponsible] (
    [IdCatPartyResponsible] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PartyResponsibleName]  NVARCHAR (50) NOT NULL,
    [RowStatus]             BIT           NOT NULL,
    [TokenCreated]          NVARCHAR (50) NOT NULL,
    [DateCreated]           DATETIME      NOT NULL,
    [DateUpdated]           DATETIME      NULL,
    [TokenUpdated]          NVARCHAR (50) NULL,
    CONSTRAINT [PK_CatPartyResponsible] PRIMARY KEY CLUSTERED ([IdCatPartyResponsible] ASC)
);



GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catalogo de parte responsable de la incidencia, Forza, cliente',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPartyResponsible',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del catalago',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPartyResponsible',
    @level2type = N'COLUMN',
    @level2name = N'IdCatPartyResponsible'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de la parte responsable de la incidencia',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPartyResponsible',
    @level2type = N'COLUMN',
    @level2name = N'PartyResponsibleName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPartyResponsible',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Codigo de quien creo el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPartyResponsible', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPartyResponsible', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Codigo de quien modifico el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPartyResponsible', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPartyResponsible', @level2type = N'COLUMN', @level2name = N'DateUpdated';

