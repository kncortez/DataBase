CREATE TABLE [dbo].[CatArticleSAPCatTypeServiceClosure] (
    [IdCatArticleSAPCatTypeServiceClosure] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [IdCatArticleSAP]                      INT           NULL,
    [IdTypeService]                        INT           NULL,
    [SAPCode]                              NVARCHAR (50) NULL,
    CONSTRAINT [PK_CatArticleSAPCatTypeServiceClosure] PRIMARY KEY CLUSTERED ([IdCatArticleSAPCatTypeServiceClosure] ASC),
    CONSTRAINT [FK_CatArticleSAPCatTypeServiceClosure_IdTypeService] FOREIGN KEY ([IdTypeService]) REFERENCES [dbo].[CatTypeServiceClosure] ([IdTypeService]) ON DELETE CASCADE
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAPCatTypeServiceClosure', @level2type = N'COLUMN', @level2name = N'IdCatArticleSAPCatTypeServiceClosure';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID foranea ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAPCatTypeServiceClosure', @level2type = N'COLUMN', @level2name = N'IdCatArticleSAP';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID foranea de servicios ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAPCatTypeServiceClosure', @level2type = N'COLUMN', @level2name = N'IdTypeService';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código SAP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAPCatTypeServiceClosure', @level2type = N'COLUMN', @level2name = N'SAPCode';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catálogo de Articulos de SAP por tipo de cierre de servicio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticleSAPCatTypeServiceClosure',
    @level2type = NULL,
    @level2name = NULL