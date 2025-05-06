CREATE TABLE [dbo].[IncidenceDynamicInput] (
    [IdIncidenceDynamicInput] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FieldName]               NVARCHAR (50) NOT NULL,
    [FieldType]               NVARCHAR (50) NOT NULL,
    [IsEditable]              BIT           NOT NULL,
    [CatTypeIncidenceId]      INT           NOT NULL,
    [RowStatus]               BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]            NVARCHAR (50) NOT NULL,
    [DateCreated]             DATETIME      NOT NULL,
    [TokenUpdated]            NVARCHAR (50) NULL,
    [DateUpdated]             DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdIncidenceDynamicInput] ASC),
    CONSTRAINT [FK_IncidenceDynamicInput_CatTypeIncidence] FOREIGN KEY ([CatTypeIncidenceId]) REFERENCES [dbo].[CatTypeIncidence] ([IdIncidenceType])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicInput', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que actualizó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicInput', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicInput', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que generó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicInput', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicInput', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Incidencia relacionada.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicInput', @level2type = N'COLUMN', @level2name = N'CatTypeIncidenceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicador booleano para habilitar la edición del campo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicInput', @level2type = N'COLUMN', @level2name = N'IsEditable';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dominio del campo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicInput', @level2type = N'COLUMN', @level2name = N'FieldType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del campo que debe habilitarse o inhabilitarse.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicInput', @level2type = N'COLUMN', @level2name = N'FieldName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicInput', @level2type = N'COLUMN', @level2name = N'IdIncidenceDynamicInput';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para guardar campos editables por tipo de incidencia en landing page', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicInput';

