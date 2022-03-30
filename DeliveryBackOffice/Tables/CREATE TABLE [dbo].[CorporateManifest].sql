USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CorporateManifest](
	[IdManifest] [BIGINT] IDENTITY(1,1) NOT NULL,
	[ManifestSerie][NVARCHAR](MAX) NOT NULL,
	[ManifestNumber] [BIGINT] NOT NULL,
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

EXECUTE sp_addextendedproperty N'MS_Description', N'ID de la tabla CorporateManifest', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'IdManifest'
EXECUTE sp_addextendedproperty N'MS_Description', N'Serie de manifiesto', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'ManifestSerie'
EXECUTE sp_addextendedproperty N'MS_Description', N'Numero de manifiesto', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'ManifestNumber'
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creacion', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'TokenCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de creacion', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'DateCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de actualizacion', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'TokenUpdated'
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de actualizacion', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifest', N'COLUMN', N'DateUpdated'

