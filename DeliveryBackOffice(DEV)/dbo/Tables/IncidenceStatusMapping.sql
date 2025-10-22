CREATE TABLE [dbo].[IncidenceStatusMapping]
(
    [IdMapping]                     INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [StatusOrderId]                 TINYINT         NULL,
    [IncidenceTypeId]               INT             NULL,
    [AttemptNumber]                 INT             NULL,
    [NewCode]                       INT             NOT NULL,
    [RowStatus]                     BIT             NOT NULL,
    [TokenCreated]                  VARCHAR (50)    NOT NULL,
    [DateCreated]                   DATETIME        NOT NULL,
    [TokenUpdated]                  VARCHAR (50)    NULL,
    [DateUpdated]                   DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdMapping] ASC),
    CONSTRAINT [FK_IncidenceStatusMapping_StatusOrder] FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder] ([StatusOrderId]),
    CONSTRAINT [FK_IncidenceStatusMapping_CatTypeIncidence] FOREIGN KEY ([IncidenceTypeId]) REFERENCES [dbo].[CatTypeIncidence] ([IdIncidenceType]),
);

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla para llevar el mapeo entre los estados e incidencias de Forza y los de Aeropost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidenceStatusMapping',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidenceStatusMapping',
    @level2type = N'COLUMN',
    @level2name = N'IdMapping'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Id del estado de la guía',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidenceStatusMapping',
    @level2type = N'COLUMN',
    @level2name = N'StatusOrderId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Id de la incidencia',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidenceStatusMapping',
    @level2type = N'COLUMN',
    @level2name = N'IncidenceTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Guarda si es el primer intento o el segundo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidenceStatusMapping',
    @level2type = N'COLUMN',
    @level2name = N'AttemptNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de estado para cliente Aeropost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidenceStatusMapping',
    @level2type = N'COLUMN',
    @level2name = N'NewCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidenceStatusMapping',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidenceStatusMapping',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidenceStatusMapping',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidenceStatusMapping',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'IncidenceStatusMapping',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO