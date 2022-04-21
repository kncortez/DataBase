ALTER TABLE dbo.ScheduleServiceHistory
ADD TimeSchedule VARCHAR(250) NULL
GO

ALTER TABLE dbo.ScheduleServiceHistory
ADD ServicesConfigId BIGINT NULL
GO

ALTER TABLE dbo.ScheduleServiceHistory
ADD LogType INT NULL
GO


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Horario en que se ejecutó el proceso del servicio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleServiceHistory', @level2type=N'COLUMN',@level2name=N'TimeSchedule'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la configuración del servicio, que tiene en la tabla ServiceConfig' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleServiceHistory', @level2type=N'COLUMN',@level2name=N'ServicesConfigId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de log, siendo 1 el log de inicio de ejecución del proceso y 2 el log de finalización del proceso' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ScheduleServiceHistory', @level2type=N'COLUMN',@level2name=N'LogType'
GO