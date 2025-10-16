CREATE TABLE [dbo].[Tool] (
    [IdTool]          INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CatTypeToolId]   INT            NOT NULL,
    [ToolSerie]       NVARCHAR (50)  NOT NULL,
    [ToolDescription] NVARCHAR (200) NULL,
    [RowStatus]       BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]    NVARCHAR (50)  NOT NULL,
    [DateCreated]     DATETIME       NOT NULL,
    [TokenUpdated]    NVARCHAR (50)  NULL,
    [DateUpdated]     DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdTool] ASC),
    CONSTRAINT [FK_Tool_TypeTool] FOREIGN KEY ([CatTypeToolId]) REFERENCES [dbo].[CatTypeTool] ([IdCatTypeTool]),
    CONSTRAINT [UQ_Tool_Serie] UNIQUE NONCLUSTERED ([ToolSerie] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tool', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tool', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tool', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tool', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tool', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de herramienta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tool', @level2type = N'COLUMN', @level2name = N'ToolDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de herramienta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tool', @level2type = N'COLUMN', @level2name = N'ToolSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de herramienta | Tabla CatTypeTool.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tool', @level2type = N'COLUMN', @level2name = N'CatTypeToolId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tool', @level2type = N'COLUMN', @level2name = N'IdTool';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de registro de herramientas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tool';

