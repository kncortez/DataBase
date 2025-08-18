CREATE TABLE [dbo].[IncidentTypeRelation] (
    [IdRelation]            INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [StatusOrderExternalId] INT           NOT NULL,
    [IncidenceTypeId]       INT           NOT NULL,
    [RowStatus]             BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]           DATETIME      NOT NULL,
    [TokenCreated]          NVARCHAR (50) NOT NULL,
    [DateUpdated]           DATETIME      NULL,
    [TokenUpdated]          NVARCHAR (50) NULL,
    CONSTRAINT [PK_IdRelation] PRIMARY KEY CLUSTERED ([IdRelation] ASC),
    CONSTRAINT [FK_IncidentTypeRelation_CatTypeIncidence] FOREIGN KEY ([IncidenceTypeId]) REFERENCES [dbo].[CatTypeIncidence] ([IdIncidenceType]),
    CONSTRAINT [FK_IncidentTypeRelation_StatusOrderExternal] FOREIGN KEY ([StatusOrderExternalId]) REFERENCES [dbo].[StatusOrderExternal] ([IdStatusOrderExternal])
);



GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de la tabla IncidentTypeRelation',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidentTypeRelation',
    @level2type = N'COLUMN',
    @level2name = N'IdRelation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del estado externo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidentTypeRelation',
    @level2type = N'COLUMN',
    @level2name = N'StatusOrderExternalId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del tipo de incidencia Forza',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidentTypeRelation',
    @level2type = N'COLUMN',
    @level2name = N'IncidenceTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidentTypeRelation',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha Creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidentTypeRelation',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario Creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidentTypeRelation',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha Actualización',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidentTypeRelation',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario Actualización',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidentTypeRelation',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'