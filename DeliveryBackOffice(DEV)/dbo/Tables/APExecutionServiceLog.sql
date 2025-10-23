CREATE TABLE [dbo].[APExecutionServiceLog] (
    [IdAPExecutionServiceLog]   BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [APExecutionScheduleId]     INT             NOT NULL,
    [CountryCode]               NVARCHAR(2)     NOT NULL,
    [APServiceDate]             DATETIME        NOT NULL DEFAULT GETDATE(),
    [Status]                    NVARCHAR(20)    NOT NULL,
    [Message]                   NVARCHAR(500)   NULL,
    [DurationMs]                INT             NULL,
    [RowStatus]                 BIT             DEFAULT ((1)) NOT NULL,
    [TokenCreated]              NVARCHAR (50)   NOT NULL,
    [DateCreated]               DATETIME        NOT NULL,
    [TokenUpdated]              NVARCHAR (50)   NULL,
    [DateUpdated]               DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdAPExecutionServiceLog] ASC),
    CONSTRAINT [FK_ExecutionLog_Schedule] FOREIGN KEY ([APExecutionScheduleId]) REFERENCES [dbo].[APExecutionSchedule] ([IdAPExecutionSchedule])
);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que almacena las ejecuciones del servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'IdAPExecutionServiceLog';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID del schedule de ejecución relacionado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'APExecutionScheduleId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de país (formato ISO 2 caracteres)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'CountryCode';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de ejecución del servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'APServiceDate';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la ejecución (Running, Success, Failed)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'Status';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mensaje descriptivo del resultado de la ejecución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'Message';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Duración de la ejecución en milisegundos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'DurationMs';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1=Activo, 0=Inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro en el sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foránea que referencia la tabla APExecutionSchedule', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'CONSTRAINT', @level2name = N'FK_ExecutionLog_Schedule';
GO