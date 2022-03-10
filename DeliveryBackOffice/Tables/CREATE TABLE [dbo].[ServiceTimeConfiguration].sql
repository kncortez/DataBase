USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ServiceTimeConfiguration]    Script Date: 3/7/2022 4:46:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ServiceTimeConfiguration](
	[IdServiceTimeConfiguration] [int] IDENTITY(1,1) NOT NULL,
	[CatConfigurableServiceId] [int] NOT NULL,
	[StartingTime] [time](7) NOT NULL,
	[FinishingTime] [time](7) NOT NULL,
	[TimeStep] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdServiceTimeConfiguration] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ServiceTimeConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_ServiceTimeConfiguration_CatConfigurableService] FOREIGN KEY([CatConfigurableServiceId])
REFERENCES [dbo].[CatConfigurableService] ([IdCatConfigurableService])
GO

ALTER TABLE [dbo].[ServiceTimeConfiguration] CHECK CONSTRAINT [FK_ServiceTimeConfiguration_CatConfigurableService]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTimeConfiguration', @level2type=N'COLUMN',@level2name=N'IdServiceTimeConfiguration'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del servicio en la tabla CatConfigurableService' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTimeConfiguration', @level2type=N'COLUMN',@level2name=N'CatConfigurableServiceId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tiempo de inicio del servicio (Formato 24horas)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTimeConfiguration', @level2type=N'COLUMN',@level2name=N'StartingTime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tiempo de finalización del servicio (Formato 24horas)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTimeConfiguration', @level2type=N'COLUMN',@level2name=N'FinishingTime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Intervalo de tiempo de ejecución (En minutos)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTimeConfiguration', @level2type=N'COLUMN',@level2name=N'TimeStep'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTimeConfiguration', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTimeConfiguration', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTimeConfiguration', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTimeConfiguration', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTimeConfiguration', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de tiempo de ejecución de servicios configurables' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceTimeConfiguration'
GO


