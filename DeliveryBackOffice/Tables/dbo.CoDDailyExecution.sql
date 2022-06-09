USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CoDDailyExecution]    Script Date: 6/7/2022 11:00:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CoDDailyExecution](
	[IdCoDDailyExecution] [int] IDENTITY(1,1) NOT NULL,
	[CodDailyScheduleId] [int] NOT NULL,
	[ExecutionDate] [date] NOT NULL,
	[CoDProcessName] [nvarchar](100) NOT NULL,
	[DeliveryBankId] [int] NOT NULL,
	[ExecutionTime] [time](7) NOT NULL,
	[ProcessPriority] [int] NOT NULL,
	[ProcessPending] [bit] NOT NULL,
	[ProcessStarted] [bit] NOT NULL,
	[ProcessFinished] [bit] NOT NULL,
	[ProcessRetries] [int] NULL,
	[ProcessError] [nvarchar](4000) NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdCoDDailyExecution] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CoDDailyExecution] ADD  DEFAULT ((0)) FOR [ProcessPending]
GO

ALTER TABLE [dbo].[CoDDailyExecution] ADD  DEFAULT ((0)) FOR [ProcessStarted]
GO

ALTER TABLE [dbo].[CoDDailyExecution] ADD  DEFAULT ((0)) FOR [ProcessFinished]
GO

ALTER TABLE [dbo].[CoDDailyExecution] ADD  DEFAULT ((1)) FOR [RowStatus]
GO

ALTER TABLE [dbo].[CoDDailyExecution]  WITH CHECK ADD  CONSTRAINT [FK_CoDDailyExectuion_CoDDailySchedule] FOREIGN KEY([CodDailyScheduleId])
REFERENCES [dbo].[CatCoDDailySchedule] ([IdCatCoDDailySchedule])
GO

ALTER TABLE [dbo].[CoDDailyExecution] CHECK CONSTRAINT [FK_CoDDailyExectuion_CoDDailySchedule]
GO

ALTER TABLE [dbo].[CoDDailyExecution]  WITH CHECK ADD  CONSTRAINT [FK_CoDDailyExectuion_DeliveryBank] FOREIGN KEY([DeliveryBankId])
REFERENCES [dbo].[DeliveryBank] ([Id_bank])
GO

ALTER TABLE [dbo].[CoDDailyExecution] CHECK CONSTRAINT [FK_CoDDailyExectuion_DeliveryBank]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'IdCoDDailyExecution'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del horario preestablecido de la tabla CatCoDDailySchedule.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'CodDailyScheduleId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de ejecución del proceso.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'ExecutionDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre que identifica al proceso de CoD a ejecutar.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'CoDProcessName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del banco objetivo de la tabla DelvieryBank.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'DeliveryBankId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hora especifica en la cual debe ejecutarse el proceso en el servicio de CoD.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'ExecutionTime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifica si el proceso esta pendiente de ejecutar (Si ya es posible ejecutarlo).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'ProcessPending'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifica si el proceso ha iniciado su ejecución.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'ProcessStarted'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifica si el proceso ha sido completado exitosamente.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'ProcessFinished'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifica la cantidad de veces que se ha reintentado un proceso.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'ProcessRetries'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Describe el último error ocurrido en la ejecución del proceso.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'ProcessError'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Último token de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última fecha de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identifica la prioridad para ejecutar los procesos, utilizado para ordenar la ejecución (A mayor prioridad, sube en la cola de ejecución).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution', @level2type=N'COLUMN',@level2name=N'ProcessPriority'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de procesos de servicio de CoD ejecutados diariamente, sirviendo también como una bitácora de la ejecución del servicio durante el día.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CoDDailyExecution'
GO


