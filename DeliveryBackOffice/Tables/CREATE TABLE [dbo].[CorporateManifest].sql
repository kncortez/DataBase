USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CorporateManifest](
	[IdManifest] [BIGINT] IDENTITY(1000,1) NOT NULL,
	[ManifestSerie][NVARCHAR](MAX) NOT NULL,
  [AccountId] [BIGINT] NOT NULL,
  [CodeOfReferenceId] [INT] NOT NULL,
  [ManifestURL] [NVARCHAR](MAX) NULL,
  [RowStatus] [BIT] NOT NULL,
	[TokenCreated] [NVARCHAR](100) NOT NULL,
	[DateCreated] [DATETIME] NOT NULL,
	[TokenUpdated] [NVARCHAR](100) NULL,
	[DateUpdated] [DATETIME] NULL,
 CONSTRAINT [PKCorporateManifest] PRIMARY KEY CLUSTERED 
(
	[IdManifest] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CorporateManifest]  WITH CHECK ADD  CONSTRAINT [FKCorporateManifestAccountId] FOREIGN KEY([AccountId])
REFERENCES [dbo].Account ([AccIdAccount])
GO

ALTER TABLE [dbo].[CorporateManifest] CHECK CONSTRAINT [FKCorporateManifestAccountId]
GO

ALTER TABLE [dbo].[CorporateManifest]  WITH CHECK ADD  CONSTRAINT [FKCorporateManifestCodeOfReference] FOREIGN KEY([CodeOfReferenceId])
REFERENCES [dbo].VisitPointClient ([CodeOfReference])
GO

ALTER TABLE [dbo].[CorporateManifest] CHECK CONSTRAINT [FKCorporateManifestCodeOfReference]
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'ID de la tabla CorporateManifest y Numero de manifiesto', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'IdManifest'
EXECUTE sp_addextendedproperty N'MS_Description', N'Serie de manifiesto', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'ManifestSerie'
EXECUTE sp_addextendedproperty N'MS_Description', N'Id de referencia a tabla Account', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'AccountId'
EXECUTE sp_addextendedproperty N'MS_Description', N'Id de referencia a tabla VisitPointClient', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'CodeOfReferenceId'
EXECUTE sp_addextendedproperty N'MS_Description', N'URL de descarga de manifiesto', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'ManifestURL'
EXECUTE sp_addextendedproperty N'MS_Description', N'Stado de fila 1 activa 0 inactiva', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'RowStatus'
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creacion', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'TokenCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de creacion', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'DateCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de actualizacion', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'TokenUpdated'
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de actualizacion', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'DateUpdated'

