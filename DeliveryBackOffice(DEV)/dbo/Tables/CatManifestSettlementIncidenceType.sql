CREATE TABLE [dbo].[CatManifestSettlementIncidenceType] (
    [IdCatManifestSettlementIncidenceType]	INT			IDENTITY (1, 1) NOT NULL,
    [Category]				NVARCHAR (50)   NULL,
    [Type]					NVARCHAR (50)   NULL,
    [RowStatus]             BIT             DEFAULT ((1)) NOT NULL,
    [DateCreated]           DATETIME        NULL,
    [TokenCreated]          NVARCHAR (50)   NOT NULL,
    [DateUpdated]           DATETIME        NULL,
    [TokenUpdated]          NVARCHAR (50)   NULL,
    PRIMARY KEY CLUSTERED ([IdCatManifestSettlementIncidenceType] ASC)
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Categoría de una incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManifestSettlementIncidenceType', @level2type = N'COLUMN', @level2name = N'Category';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManifestSettlementIncidenceType', @level2type = N'COLUMN', @level2name = N'Type';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManifestSettlementIncidenceType', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManifestSettlementIncidenceType', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManifestSettlementIncidenceType', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManifestSettlementIncidenceType', @level2type = N'COLUMN', @level2name = N'DateUpdated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManifestSettlementIncidenceType', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
