CREATE TABLE [dbo].[CatValueType] (
    [IdCatValueType]       INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ValueTypeName]        NVARCHAR (50)  NOT NULL,
    [ValueTypeDescription] NVARCHAR (200) NULL,
    [RowStatus]            BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]          DATETIME       NOT NULL,
    [TokenCreated]         NVARCHAR (50)  NOT NULL,
    [DateUpdated]          DATETIME       NULL,
    [TokenUpdated]         NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdCatValueType] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogo de tipos de valor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatValueType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatValueType', @level2type = N'COLUMN', @level2name = N'IdCatValueType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de valor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatValueType', @level2type = N'COLUMN', @level2name = N'ValueTypeName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de valor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatValueType', @level2type = N'COLUMN', @level2name = N'ValueTypeDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatValueType', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatValueType', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatValueType', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatValueType', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatValueType', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

