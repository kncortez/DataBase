CREATE TABLE [dbo].[ManifestSettlementIncidenceDetail] (
    [IdManifestSettlementIncidenceDetail]             INT            IDENTITY (1, 1) NOT NULL,
    [Guide_Serie]		VARCHAR (2)		NULL,
    [Guide_Number]      INT             NULL,
	[ManifestSettlementIncidenceId] INT	NULL,
    [RowStatus]         BIT            NOT NULL,
    [TokenCreated]      NVARCHAR (50)  NOT NULL,
    [DateCreated]       DATETIME       NOT NULL,
    [TokenUpdated]      NVARCHAR (50)  NULL,
    [DateUpdated]       DATETIME       NULL,
    CONSTRAINT [PK_ManifestSettlementIncidenceDetail] PRIMARY KEY CLUSTERED ([IdManifestSettlementIncidenceDetail] ASC),	
    CONSTRAINT [FK_ManifestSettlementIncidenceDetail_ManifestSettlementIncidence] FOREIGN KEY([ManifestSettlementIncidenceId]) REFERENCES [dbo].[ManifestSettlementIncidence] ([IdManifestSettlementIncidence])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidenceDetail', @level2type = N'COLUMN', @level2name = N'Guide_Serie';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidenceDetail', @level2type = N'COLUMN', @level2name = N'Guide_Number';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Incidencia del manifiesto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidenceDetail', @level2type = N'COLUMN', @level2name = N'ManifestSettlementIncidenceId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidenceDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidenceDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidenceDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidenceDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManifestSettlementIncidenceDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';
GO


