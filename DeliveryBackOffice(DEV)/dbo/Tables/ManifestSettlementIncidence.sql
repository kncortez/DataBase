CREATE TABLE [dbo].[ManifestSettlementIncidence] (
    [IdManifestSettlementIncidence] INT			    IDENTITY (1, 1) NOT NULL,
    [CatRouteId]					INT				NULL,
    [CourierName]					NVARCHAR(50)	NULL,
    [ManifestNumber]				INT				NULL,
    [TotalAmount]					DECIMAL(14,2)	NULL,
    [GuidesQuantity]				SMALLINT		NULL,
    [TotalNumberOfPieces]			SMALLINT		NULL,
    [IncidenceApproved]				BIT             NULL,
    [TokenValidator]				NVARCHAR (50)	NULL,
    [CatManifestSettlementIncidenceTypeId]             INT            NULL,
    [IncidenceComment]				NVARCHAR (300)	NULL,
    [ResolutionComment]				NVARCHAR (300)	NULL,
    [RowStatus]						BIT				DEFAULT ((1)) NOT NULL,
    [DateCreated]					DATETIME		NULL,
    [TokenCreated]					NVARCHAR (50)	NOT NULL,
    [DateUpdated]					DATETIME		NULL,
    [TokenUpdated]					NVARCHAR (50)	NULL,
	CONSTRAINT [PK_ManifestSettlementIncidence_IdManifestSettlementIncidence] PRIMARY KEY CLUSTERED ([IdManifestSettlementIncidence] ASC),
    CONSTRAINT [FK_ManifestSettlementIncidence_CatRoute] FOREIGN KEY ([CatRouteId]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    CONSTRAINT [FK_ManifestSettlementIncidence_CatTypeIncidence] FOREIGN KEY (CatManifestSettlementIncidenceTypeId) REFERENCES [dbo].[CatTypeIncidence] ([IdIncidenceType])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ruta de entregas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'CatRouteId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del piloto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'CourierName';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de manifiesto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'ManifestNumber';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total del manifiesto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'TotalAmount';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total de guías', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'GuidesQuantity';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de piezas entregadas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'TotalNumberOfPieces';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estadp de la incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'IncidenceApproved';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que valida la incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'TokenValidator';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'CatManifestSettlementIncidenceTypeId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comentario en la incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'IncidenceComment';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comentario al finalizar la incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'ResolutionComment';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'DateUpdated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidence', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
