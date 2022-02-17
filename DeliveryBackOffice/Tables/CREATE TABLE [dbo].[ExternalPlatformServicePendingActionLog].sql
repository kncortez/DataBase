USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ExternalPlatformServicePendingActionLog]    Script Date: 2/17/2022 9:36:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ExternalPlatformServicePendingActionLog](
	[IdExternalPlatformServiceXLog] [int] IDENTITY(1,1) NOT NULL,
	[ExternalPlatformId] [int] NOT NULL,
	[GuideSerie] [nvarchar](2) NOT NULL,
	[GuideNumber] [int] NOT NULL,
	[IsPendingInsert] [bit] NULL,
	[IsPendingUpdate] [bit] NULL,
	[IsPendingDelete] [bit] NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdExternalPlatformServiceXLog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ExternalPlatformServicePendingActionLog]  WITH CHECK ADD  CONSTRAINT [FK_ExternalPlatformServicePendingActionLog_CatExternalPlatform] FOREIGN KEY([ExternalPlatformId])
REFERENCES [dbo].[CatExternalPlatform] ([IdExternalPlatform])
GO

ALTER TABLE [dbo].[ExternalPlatformServicePendingActionLog] CHECK CONSTRAINT [FK_ExternalPlatformServicePendingActionLog_CatExternalPlatform]
GO

ALTER TABLE [dbo].[ExternalPlatformServicePendingActionLog]  WITH CHECK ADD  CONSTRAINT [FK_ExternalPlatformServicePendingActionLog_DeliveryOrder] FOREIGN KEY([GuideSerie], [GuideNumber])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[ExternalPlatformServicePendingActionLog] CHECK CONSTRAINT [FK_ExternalPlatformServicePendingActionLog_DeliveryOrder]
GO

ALTER TABLE [dbo].[ExternalPlatformServicePendingActionLog]  WITH CHECK ADD  CONSTRAINT [CHK_ExternalPlatformServicePendingActionLog_Action] CHECK  ((isnull([IsPendingInsert],(0))>(0) AND isnull([IsPendingUpdate],(0))=(0) AND isnull([IsPendingDelete],(0))=(0) OR isnull([IsPendingInsert],(0))=(0) AND isnull([IsPendingUpdate],(0))>(0) AND isnull([IsPendingDelete],(0))=(0) OR isnull([IsPendingInsert],(0))=(0) AND isnull([IsPendingUpdate],(0))=(0) AND isnull([IsPendingDelete],(0))>(0)))
GO

ALTER TABLE [dbo].[ExternalPlatformServicePendingActionLog] CHECK CONSTRAINT [CHK_ExternalPlatformServicePendingActionLog_Action]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExternalPlatformServicePendingActionLog', @level2type=N'COLUMN',@level2name=N'IdExternalPlatformServiceXLog'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID que hace referencia a la tabla CatExternalPlatform' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExternalPlatformServicePendingActionLog', @level2type=N'COLUMN',@level2name=N'ExternalPlatformId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de la guía referenciando a la tabla DeliveryOrder' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExternalPlatformServicePendingActionLog', @level2type=N'COLUMN',@level2name=N'GuideSerie'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de la guía referenciando a la tabla DeliveryOrder' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExternalPlatformServicePendingActionLog', @level2type=N'COLUMN',@level2name=N'GuideNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Si el registro esta pendiente de ser ingresado a la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExternalPlatformServicePendingActionLog', @level2type=N'COLUMN',@level2name=N'IsPendingInsert'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Si el registro esta pendiente de ser actualizado en la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExternalPlatformServicePendingActionLog', @level2type=N'COLUMN',@level2name=N'IsPendingUpdate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Si el registro esta pendiente de ser eliminado en la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExternalPlatformServicePendingActionLog', @level2type=N'COLUMN',@level2name=N'IsPendingDelete'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExternalPlatformServicePendingActionLog', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExternalPlatformServicePendingActionLog', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExternalPlatformServicePendingActionLog', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExternalPlatformServicePendingActionLog', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExternalPlatformServicePendingActionLog', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Bitácora de guías que quedan pendientes de realizar una acción bajo la plataforma externa correspondiente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExternalPlatformServicePendingActionLog'
GO


