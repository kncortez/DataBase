CREATE TABLE [dbo].[FinalStatusByModule] (
    [IdFinalStatusByModule] INT           IDENTITY (1, 1) NOT NULL,
    [StatusOrderId]         TINYINT       NOT NULL,
    [ModuleId]              INT           NOT NULL,
    [RowStatus]             BIT           NOT NULL,
    [TokenCreated]          NVARCHAR (50) NOT NULL,
    [DateCreated]           DATETIME      NOT NULL,
    [TokenUpdated]          NVARCHAR (50) NULL,
    [DateUpdated]           DATETIME      NULL,
    CONSTRAINT [PK_FinalStatusByModule] PRIMARY KEY CLUSTERED ([IdFinalStatusByModule] ASC),
    CONSTRAINT [FK_FinalStatusByModule_CatModule] FOREIGN KEY ([ModuleId]) REFERENCES [dbo].[CatModule] ([ModIdModule])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de estados finales de guías por modulo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinalStatusByModule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinalStatusByModule', @level2type = N'COLUMN', @level2name = N'IdFinalStatusByModule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de estado de ordenes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinalStatusByModule', @level2type = N'COLUMN', @level2name = N'StatusOrderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del modulo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinalStatusByModule', @level2type = N'COLUMN', @level2name = N'ModuleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinalStatusByModule', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinalStatusByModule', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinalStatusByModule', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinalStatusByModule', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinalStatusByModule', @level2type = N'COLUMN', @level2name = N'DateUpdated';

