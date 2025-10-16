CREATE TABLE [dbo].[SchedulePickupDuplicateLog] (
    [IdSchedulePickupDuplicateLog] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SchedulePickupIdOld]          BIGINT        NOT NULL,
    [SchedulePickupIdNew]          BIGINT        NOT NULL,
    [RowStatus]                    BIT           NOT NULL,
    [TokenCreated]                 NVARCHAR (50) NOT NULL,
    [DateCreated]                  DATETIME      NOT NULL,
    [TokenUpdated]                 NVARCHAR (50) NULL,
    [DateUpdated]                  DATETIME      NULL,
    CONSTRAINT [PK_SchedulePickupDuplicateLog_IdSchedulePickupDuplicateLog] PRIMARY KEY CLUSTERED ([IdSchedulePickupDuplicateLog] ASC),
    CONSTRAINT [FK_SchedulePickupDuplicateLog_SchedulePickupIdNew] FOREIGN KEY ([SchedulePickupIdNew]) REFERENCES [dbo].[SchedulePickup] ([SchedulePickupId]),
    CONSTRAINT [FK_SchedulePickupDuplicateLog_SchedulePickupIdOld] FOREIGN KEY ([SchedulePickupIdOld]) REFERENCES [dbo].[SchedulePickup] ([SchedulePickupId])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupDuplicateLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupDuplicateLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupDuplicateLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupDuplicateLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupDuplicateLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SchedulePickupId del servicio duplicado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupDuplicateLog', @level2type = N'COLUMN', @level2name = N'SchedulePickupIdNew';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SchedulePickupId del servicio que se está duplicando.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupDuplicateLog', @level2type = N'COLUMN', @level2name = N'SchedulePickupIdOld';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla SchedulePickupDuplicateLog.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupDuplicateLog', @level2type = N'COLUMN', @level2name = N'IdSchedulePickupDuplicateLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar el log de confirmación de duplicar servicios de recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupDuplicateLog';

