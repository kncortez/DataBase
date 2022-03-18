USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SettlementPickupStationDetail](
	[IdSettlementPickupStationDetail] [bigint] IDENTITY(1,1) NOT NULL,
	[SettlementPickupStationId] [bigint] NOT NULL,
	[ServiceManagementId] [bigint] NOT NULL,
	[Price] DECIMAL(12,2) NOT NULL,
	[SettlementSequence] BIGINT NULL,
	[SettlementStationId] INT  NULL,
	[SettlementDate] DATETIME  NULL,
	[TokenSettlement] [VARCHAR](50) NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL
PRIMARY KEY CLUSTERED 
(
	IdSettlementPickupStationDetail ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SettlementPickupStationDetail]  WITH CHECK ADD FOREIGN KEY(SettlementPickupStationId)
REFERENCES [dbo].[SettlementPickupStation] ([IdSettlementPickupStation])
GO
ALTER TABLE [dbo].[SettlementPickupStationDetail]  WITH CHECK ADD FOREIGN KEY(ServiceManagementId)
REFERENCES [dbo].ServiceManagement (IdServiceManagement)
GO
ALTER TABLE [dbo].[SettlementPickupStationDetail]  WITH CHECK ADD FOREIGN KEY(SettlementStationId)
REFERENCES [dbo].VisitPointClient (CodeOfReference)
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id Detalle del manifiesto.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail', @level2type=N'COLUMN',@level2name=N'IdSettlementPickupStationDetail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id manifiesto encabezado.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail', @level2type=N'COLUMN',@level2name=N'SettlementPickupStationId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Servicio de recolección asociado.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail', @level2type=N'COLUMN',@level2name=N'ServiceManagementId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Precio del envío cuando aplique.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail', @level2type=N'COLUMN',@level2name=N'Price'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id del manifiesto de la liquidación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail', @level2type=N'COLUMN',@level2name=N'SettlementSequence'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estación o punto de venta donde se liquidan los servicios.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail', @level2type=N'COLUMN',@level2name=N'SettlementStationId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de liquidación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail', @level2type=N'COLUMN',@level2name=N'SettlementDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token del operador que lo liquidó.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail', @level2type=N'COLUMN',@level2name=N'TokenSettlement'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Si el registro está vigente.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Detalle de manifiesto de recolección asociado a cada courier.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementPickupStationDetail'
GO