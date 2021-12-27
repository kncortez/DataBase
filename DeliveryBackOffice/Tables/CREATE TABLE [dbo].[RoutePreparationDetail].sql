USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[RuotePreparation]    Script Date: 22/12/2021 15:21:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RoutePreparationDetail](
    [IdRoutePreparationDetail] [int] IDENTITY(1,1) NOT NULL,
	[RoutePreparationId] [int] NOT NULL,
	[Guide_Serie] [nvarchar](2) NOT NULL,
	[Guide_Number] [int] NOT NULL,
    [RowStatus] [bit] NOT NULL,
    [TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
    [TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_RoutePreparationDetail_IdRoutePreparationDetail] PRIMARY KEY CLUSTERED 
(
	[IdRoutePreparationDetail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RoutePreparationDetail]  WITH CHECK ADD  CONSTRAINT [FK_RoutePreparationDetail_RoutePreparationId] FOREIGN KEY([RoutePreparationId])
REFERENCES [dbo].[RoutePreparation] ([IdRoutePreparation])
GO

ALTER TABLE [dbo].[RoutePreparationDetail] CHECK CONSTRAINT [FK_RoutePreparationDetail_RoutePreparationId]
GO

ALTER TABLE [dbo].[RoutePreparationDetail]  WITH CHECK ADD  CONSTRAINT [FK_RoutePreparationDetail_DeliveryOrder] FOREIGN KEY([Guide_Serie], [Guide_Number])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[RoutePreparationDetail] CHECK CONSTRAINT [FK_RoutePreparationDetail_DeliveryOrder]
GO

ALTER TABLE [dbo].[RoutePreparationDetail] ADD CONSTRAINT [df_RoutePreparationDetail_RowStatus] DEFAULT 'TRUE' FOR RowStatus;
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla IdRoutePreparationDetail.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationDetail', @level2type=N'COLUMN',@level2name=N'IdRoutePreparationDetail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla RoutePreparation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationDetail', @level2type=N'COLUMN',@level2name=N'RoutePreparationId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de la guía.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationDetail', @level2type=N'COLUMN',@level2name=N'Guide_Serie'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de la guía.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationDetail', @level2type=N'COLUMN',@level2name=N'Guide_number'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationDetail', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationDetail', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationDetail', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que modificó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationDetail', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationDetail', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar el detalle de guías de la preparación de entregas.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationDetail'
GO