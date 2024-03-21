CREATE TABLE [dbo].[StatusOrderRelation] (
    [IdStatusOrderRelation]		INT			IDENTITY (1, 1) NOT NULL,
    [StatusOrderId]				TINYINT     NOT NULL,
    [StatusOrderExternalId]     INT			NOT NULL,
    [RowStatus]          BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]        DATETIME       NOT NULL,
    [TokenCreated]       NVARCHAR (50)  NOT NULL,
    [DateUpdated]        DATETIME       NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
	CONSTRAINT [PK_IdStatusOrderRelation] PRIMARY KEY CLUSTERED ([IdStatusOrderRelation] ASC),
    CONSTRAINT [FK_StatusOrderRelation_StatusOrderExternal] FOREIGN KEY ([StatusOrderExternalId]) REFERENCES [dbo].[StatusOrderExternal] ([IdStatusOrderExternal]),
    CONSTRAINT [FK_StatusOrderRelation_StatusOrder] FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder]  ([StatusOrderId])
);
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de la tabla',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderRelation',
    @level2type = N'COLUMN',
    @level2name = N'IdStatusOrderRelation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado Forza',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderRelation',
    @level2type = N'COLUMN',
    @level2name = N'StatusOrderId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado Externo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderRelation',
    @level2type = N'COLUMN',
    @level2name = N'StatusOrderExternalId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderRelation',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha Creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderRelation',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario Creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderRelation',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha Actualización',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderRelation',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario Actualizacion',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderRelation',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'