USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatCoDDailySchedule]    Script Date: 6/7/2022 10:59:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatCoDDailySchedule](
	[IdCatCoDDailySchedule] [int] IDENTITY(1,1) NOT NULL,
	[CoDProcessName] [nvarchar](100) NOT NULL,
	[DeliveryBankId] [int] NOT NULL,
	[ExecutionTime] [time](7) NOT NULL,
	[ProcessPriority] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdCatCoDDailySchedule] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatCoDDailySchedule] ADD  DEFAULT ((1)) FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatCoDDailySchedule]  WITH CHECK ADD  CONSTRAINT [FK_CatCoDDailySchedule_DeliveryBank] FOREIGN KEY([DeliveryBankId])
REFERENCES [dbo].[DeliveryBank] ([Id_bank])
GO

ALTER TABLE [dbo].[CatCoDDailySchedule] CHECK CONSTRAINT [FK_CatCoDDailySchedule_DeliveryBank]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCoDDailySchedule', @level2type=N'COLUMN',@level2name=N'IdCatCoDDailySchedule'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre que identifica al proceso de CoD a ejecutar.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCoDDailySchedule', @level2type=N'COLUMN',@level2name=N'CoDProcessName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del banco objetivo de la tabla DelvieryBank.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCoDDailySchedule', @level2type=N'COLUMN',@level2name=N'DeliveryBankId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hora especifica en la cual debe ejecutarse el proceso en el servicio de CoD.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCoDDailySchedule', @level2type=N'COLUMN',@level2name=N'ExecutionTime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCoDDailySchedule', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCoDDailySchedule', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCoDDailySchedule', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Último token de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCoDDailySchedule', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última fecha de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCoDDailySchedule', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifica la prioridad para ejecutar los procesos, utilizado para ordenar la ejecución (A mayor prioridad, sube en la cola de ejecución).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCoDDailySchedule', @level2type=N'COLUMN',@level2name=N'ProcessPriority'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Catálogo de procesos de CoD a ejecutar con su respectivo horario y banco objetivo.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCoDDailySchedule'
GO


