CREATE TABLE [dbo].[ServiceManagementStatusLog] (
    [IdServiceManagementStatusLog] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ServiceManagementId]          INT           NOT NULL,
    [ServiceStatusIdOld]           INT           NOT NULL,
    [ServiceStatusIdNew]           INT           NOT NULL,
    [RowStatus]                    BIT           CONSTRAINT [df_ServiceManagementStatusLog_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]                 NVARCHAR (50) NOT NULL,
    [DateCreated]                  DATETIME      NOT NULL,
    [TokenUpdated]                 NVARCHAR (50) NULL,
    [DateUpdated]                  DATETIME      NULL,
    CONSTRAINT [PK_ServiceManagementStatusLog_IdServiceManagementStatusLog] PRIMARY KEY CLUSTERED ([IdServiceManagementStatusLog] ASC),
    CONSTRAINT [FK_ServiceManagementStatusLog_ServiceManagementId] FOREIGN KEY ([ServiceManagementId]) REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement]),
    CONSTRAINT [FK_ServiceManagementStatusLog_ServiceStatusIdNew] FOREIGN KEY ([ServiceStatusIdNew]) REFERENCES [dbo].[CatServiceStatus] ([IdServiceStatus]),
    CONSTRAINT [FK_ServiceManagementStatusLog_ServiceStatusIdOld] FOREIGN KEY ([ServiceStatusIdOld]) REFERENCES [dbo].[CatServiceStatus] ([IdServiceStatus])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar el log de cambio de ServiceStatus a un un servicio de recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementStatusLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla ServiceManagementStatusLog.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementStatusLog', @level2type = N'COLUMN', @level2name = N'IdServiceManagementStatusLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla ServiceManagement.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementStatusLog', @level2type = N'COLUMN', @level2name = N'ServiceManagementId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ServiceStatusId que tenía antes de la actualización, ID de la tabla CatServiceStatus.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementStatusLog', @level2type = N'COLUMN', @level2name = N'ServiceStatusIdOld';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ServiceStatusId que se ha actualizado, ID de la tabla CatServiceStatus.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementStatusLog', @level2type = N'COLUMN', @level2name = N'ServiceStatusIdNew';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementStatusLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementStatusLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementStatusLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementStatusLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementStatusLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';

