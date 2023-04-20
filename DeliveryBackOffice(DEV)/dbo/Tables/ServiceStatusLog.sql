CREATE TABLE [dbo].[ServiceStatusLog] (
    [IdServiceStatusLog]  BIGINT         IDENTITY (1, 1) NOT NULL,
    [ServiceId]           BIGINT         NOT NULL,
    [ServiceStatusId]     INT            NOT NULL,
    [ServiceObservations] NVARCHAR (600) NULL,
    [RowStatus]           BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]         DATETIME       NOT NULL,
    [TokenCreated]        NVARCHAR (50)  NOT NULL,
    [DateUpdated]         DATETIME       NULL,
    [TokenUpdated]        NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdServiceStatusLog] ASC),
    CONSTRAINT [FK_ServiceStatusLog_Service] FOREIGN KEY ([ServiceId]) REFERENCES [dbo].[Service] ([IdService]),
    CONSTRAINT [FK_ServiceStatusLog_Status] FOREIGN KEY ([ServiceStatusId]) REFERENCES [dbo].[CatServiceStatus] ([IdServiceStatus])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceStatusLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceStatusLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceStatusLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceStatusLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceStatusLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Observaciones del cambio de estado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceStatusLog', @level2type = N'COLUMN', @level2name = N'ServiceObservations';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del estado de la tabla CatServiceStatus.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceStatusLog', @level2type = N'COLUMN', @level2name = N'ServiceStatusId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del servicio de la tabla Service.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceStatusLog', @level2type = N'COLUMN', @level2name = N'ServiceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceStatusLog', @level2type = N'COLUMN', @level2name = N'IdServiceStatusLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de bitácora de estados de servicios.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceStatusLog';

