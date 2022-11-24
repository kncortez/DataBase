CREATE TABLE [dbo].[TagsVariables] (
    [IdTagsVariables] INT            IDENTITY (1, 1) NOT NULL,
    [Tag]             NVARCHAR (50)  NOT NULL,
    [Description]     NVARCHAR (250) NOT NULL,
    CONSTRAINT [PK_TagsVaribles] PRIMARY KEY CLUSTERED ([IdTagsVariables] ASC)
);

