USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[RuotePreparation]    Script Date: 22/12/2021 15:21:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RoutePreparation](
    [IdRoutePreparation] [int] IDENTITY(1,1) NOT NULL,
	[CatRouteId] [int] NOT NULL,
	[DateRoutePreparation] [date] NOT NULL,
    [GuidesQuantity] [smallint] NOT NULL,
    [PiecesDry] [smallint] NOT NULL,
    [PiecesCold] [smallint] NOT NULL,
    [DeliveryOrderBySettlementId] [bigint] NULL,
    [RowStatus] [bit] NOT NULL,
    [TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
    [TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_RoutePreparation_IdRoutePreparation] PRIMARY KEY CLUSTERED 
(
	[IdRoutePreparation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RoutePreparation]  WITH CHECK ADD  CONSTRAINT [FK_RoutePreparation_CatRouteId] FOREIGN KEY([CatRouteId])
REFERENCES [dbo].[CatRoute] ([IdRoute])
GO

ALTER TABLE [dbo].[RoutePreparation] CHECK CONSTRAINT [FK_RoutePreparation_CatRouteId]
GO

ALTER TABLE [dbo].[RoutePreparation]  WITH CHECK ADD  CONSTRAINT [FK_RoutePreparation_DeliveryOrderBySettlementId] FOREIGN KEY([DeliveryOrderBySettlementId])
REFERENCES [dbo].[DeliveryOrderBySettlement] ([ID])
GO

ALTER TABLE [dbo].[RoutePreparation] CHECK CONSTRAINT [FK_RoutePreparation_DeliveryOrderBySettlementId]
GO

ALTER TABLE [dbo].[RoutePreparation] ADD CONSTRAINT [df_RoutePreparation_RowStatus] DEFAULT 'TRUE' FOR RowStatus;
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla RoutePreparation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparation', @level2type=N'COLUMN',@level2name=N'IdRoutePreparation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla CatRoute.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparation', @level2type=N'COLUMN',@level2name=N'CatRouteId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de la preparación de entregas.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparation', @level2type=N'COLUMN',@level2name=N'DateRoutePreparation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de guías en la preparación de entregas.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparation', @level2type=N'COLUMN',@level2name=N'GuidesQuantity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de piezas secas en la preparación de entregas.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparation', @level2type=N'COLUMN',@level2name=N'PiecesDry'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de piezas frías en la preparación de entregas.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparation', @level2type=N'COLUMN',@level2name=N'PiecesCold'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparation', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla DeliveryOrderBySettlement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparation', @level2type=N'COLUMN',@level2name=N'DeliveryOrderBySettlementId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparation', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparation', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que modificó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparation', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparation', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar la información de la preparación de entregas.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparation'
GO