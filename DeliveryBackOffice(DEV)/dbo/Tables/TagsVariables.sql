CREATE TABLE [dbo].[TagsVariables] (
    [IdTagsVariables] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Tag]             NVARCHAR (50)  NOT NULL,
    [Description]     NVARCHAR (250) NOT NULL,
    CONSTRAINT [PK_TagsVaribles] PRIMARY KEY CLUSTERED ([IdTagsVariables] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DEscripción de etiqueta de variable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TagsVariables', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Etiqueta de variable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TagsVariables', @level2type = N'COLUMN', @level2name = N'Tag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador unico del tag', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TagsVariables', @level2type = N'COLUMN', @level2name = N'IdTagsVariables';

