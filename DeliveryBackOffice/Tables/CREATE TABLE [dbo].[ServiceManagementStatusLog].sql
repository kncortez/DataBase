USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ServiceManagementStatusLog]    Script Date: 09/02/2022 12:21:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ServiceManagementStatusLog](
    [IdServiceManagementStatusLog] [bigint] IDENTITY(1,1) NOT NULL,
	[ServiceManagementId] [int] NOT NULL,
    [ServiceStatusIdOld] [int] NOT NULL,
    [ServiceStatusIdNew] [int] NOT NULL,
    [RowStatus] [bit] NOT NULL,
    [TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
    [TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_ServiceManagementStatusLog_IdServiceManagementStatusLog] PRIMARY KEY CLUSTERED 
(
	[IdServiceManagementStatusLog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ServiceManagementStatusLog]  WITH CHECK ADD  CONSTRAINT [FK_ServiceManagementStatusLog_ServiceManagementId] FOREIGN KEY([ServiceManagementId])
REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement])
GO

ALTER TABLE [dbo].[ServiceManagementStatusLog]  WITH CHECK ADD  CONSTRAINT [FK_ServiceManagementStatusLog_ServiceStatusIdOld] FOREIGN KEY([ServiceStatusIdOld])
REFERENCES [dbo].[CatServiceStatus] ([IdServiceStatus])
GO

ALTER TABLE [dbo].[ServiceManagementStatusLog]  WITH CHECK ADD  CONSTRAINT [FK_ServiceManagementStatusLog_ServiceStatusIdNew] FOREIGN KEY([ServiceStatusIdNew])
REFERENCES [dbo].[CatServiceStatus] ([IdServiceStatus])
GO

ALTER TABLE [dbo].[ServiceManagementStatusLog] ADD CONSTRAINT [df_ServiceManagementStatusLog_RowStatus] DEFAULT 'TRUE' FOR RowStatus;
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla ServiceManagementStatusLog.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagementStatusLog', @level2type=N'COLUMN',@level2name=N'IdServiceManagementStatusLog'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla ServiceManagement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagementStatusLog', @level2type=N'COLUMN',@level2name=N'ServiceManagementId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ServiceStatusId que tenía antes de la actualización, ID de la tabla CatServiceStatus.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagementStatusLog', @level2type=N'COLUMN',@level2name=N'ServiceStatusIdOld'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ServiceStatusId que se ha actualizado, ID de la tabla CatServiceStatus.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagementStatusLog', @level2type=N'COLUMN',@level2name=N'ServiceStatusIdNew'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagementStatusLog', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagementStatusLog', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagementStatusLog', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que modificó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagementStatusLog', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagementStatusLog', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar el log de cambio de ServiceStatus a un un servicio de recolección.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagementStatusLog'
GO