USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SettlementPickupStation](
	[IdSettlementPickupStation] [bigint] IDENTITY(1,1) NOT NULL,
	[CouriermanId] [varchar](50) NULL,
	[RouteId] [varchar](250) NOT NULL,
	[TransactionDate] DATE NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	IdSettlementPickupStation ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[SettlementPickupStation] ON 
GO
SET IDENTITY_INSERT [dbo].[SettlementPickupStation] OFF
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador único de manifiesto.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStation', @level2type=N'COLUMN',@level2name=N'IdSettlementPickupStation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Couierman relacionado al manifiesto.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStation', @level2type=N'COLUMN',@level2name=N'CouriermanId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de ruta del manifiesto.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStation', @level2type=N'COLUMN',@level2name=N'RouteId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha del despacho.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStation', @level2type=N'COLUMN',@level2name=N'TransactionDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Si el registro está vigente.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStation', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStation', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStation', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStation', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStation', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Manifiesto de recolección asociado a cada courier.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStation'
GO