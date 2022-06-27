CREATE TABLE [dbo].[CatCheckpointType] (
    [IdCatCheckpointType]       TINYINT        NOT NULL,
    [CheckpointTypeDescription] NVARCHAR (200) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdCatCheckpointType] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogo de tipos de checkpoint', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCheckpointType';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCheckpointType', @level2type = N'COLUMN', @level2name = N'IdCatCheckpointType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de checkpoint', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCheckpointType', @level2type = N'COLUMN', @level2name = N'CheckpointTypeDescription';

