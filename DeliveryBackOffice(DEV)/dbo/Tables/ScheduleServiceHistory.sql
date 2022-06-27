CREATE TABLE [dbo].[ScheduleServiceHistory] (
    [ScheduleServiceHistoryId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [Name]                     VARCHAR (200) NOT NULL,
    [Description]              VARCHAR (MAX) NOT NULL,
    [SSHRowStatus]             BIT           NOT NULL,
    [SSHTokenCreated]          VARCHAR (50)  NOT NULL,
    [SSHDateCreated]           DATETIME      NOT NULL,
    [SSHTokenUpdated]          VARCHAR (50)  NULL,
    [SSHDateUpdated]           DATETIME      NULL,
    [TimeSchedule]             VARCHAR (250) NULL,
    [ServicesConfigId]         BIGINT        NULL,
    [LogType]                  INT           NULL,
    PRIMARY KEY CLUSTERED ([ScheduleServiceHistoryId] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Horario en que se ejecutó el proceso del servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ScheduleServiceHistory', @level2type = N'COLUMN', @level2name = N'TimeSchedule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la configuración del servicio, que tiene en la tabla ServiceConfig', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ScheduleServiceHistory', @level2type = N'COLUMN', @level2name = N'ServicesConfigId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de log, siendo 1 el log de inicio de ejecución del proceso y 2 el log de finalización del proceso', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ScheduleServiceHistory', @level2type = N'COLUMN', @level2name = N'LogType';

