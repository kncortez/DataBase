USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ServicesConfig]    Script Date: 20/04/2022 3:08:31 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ServicesConfig](
	[IdServicesConfig] [bigint] IDENTITY(1,1) NOT NULL,
	[ServiceName] [varchar](500) NOT NULL,
	[ServiceProcess] [varchar](500) NOT NULL,
	[TimeSchedule] [varchar](4000) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[NotifyEmails] [nvarchar](2000) NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdServicesConfig] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador primario de la tabla ServicesConfig' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicesConfig', @level2type=N'COLUMN',@level2name=N'IdServicesConfig'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del servicio al que pertenece la configuración' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicesConfig', @level2type=N'COLUMN',@level2name=N'ServiceName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del proceso que pertenece al servicio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicesConfig', @level2type=N'COLUMN',@level2name=N'ServiceProcess'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Listado de horarios separados por coma , en el que se ejecutarán los procesos en el servicio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicesConfig', @level2type=N'COLUMN',@level2name=N'TimeSchedule'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicesConfig', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Listado de correos electrónicos separados por coma, para poder notificar de ser necesario, cuando se ejecutó el proceso' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicesConfig', @level2type=N'COLUMN',@level2name=N'NotifyEmails'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token del usuario o sistema que creó el registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicesConfig', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicesConfig', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token del usuario o sistema que actualizó el registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicesConfig', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en que se actualiza el registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicesConfig', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO


