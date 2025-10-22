CREATE TABLE [dbo].[SchedulePickupStatusLog] (
    [IdSchedulePickupStatusLog] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SchedulePickupId]          BIGINT        NOT NULL,
    [SchedulePickupStatus]      BIT           NOT NULL,
    [RowStatus]                 BIT           CONSTRAINT [df_SchedulePickupStatusLog_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]              NVARCHAR (50) NOT NULL,
    [DateCreated]               DATETIME      NOT NULL,
    [TokenUpdated]              NVARCHAR (50) NULL,
    [DateUpdated]               DATETIME      NULL,
    CONSTRAINT [PK_SchedulePickupStatusLog_IdSchedulePickupStatusLog] PRIMARY KEY CLUSTERED ([IdSchedulePickupStatusLog] ASC),
    CONSTRAINT [FK_SchedulePickupStatusLog_SchedulePickupId] FOREIGN KEY ([SchedulePickupId]) REFERENCES [dbo].[SchedulePickup] ([SchedulePickupId])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar el log de cambio de estado a una solicitud de recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupStatusLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla SchedulePickupStatusLog.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupStatusLog', @level2type = N'COLUMN', @level2name = N'IdSchedulePickupStatusLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla SchedulePickup.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupStatusLog', @level2type = N'COLUMN', @level2name = N'SchedulePickupId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor que se ha guardado, 1=Habilitado 0=Cancelado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupStatusLog', @level2type = N'COLUMN', @level2name = N'SchedulePickupStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupStatusLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupStatusLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupStatusLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupStatusLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupStatusLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';

