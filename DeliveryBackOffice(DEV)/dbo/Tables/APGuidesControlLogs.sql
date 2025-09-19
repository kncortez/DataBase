CREATE TABLE [dbo].[APGuidesControlLogs] (
    [IdAPGuidesControlLog]      BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TrackingCode]              NVARCHAR(50)    NULL,
    [ProcessName]               NVARCHAR(100)   NOT NULL,
    [ErrorMessage]              NVARCHAR(1000)  NOT NULL,
    [ErrorDetails]              NVARCHAR(MAX)   NULL,
    [RequestData]               NVARCHAR(MAX)   NULL,
    [ResponseData]              NVARCHAR(MAX)   NULL,
    [RowStatus]                 BIT             DEFAULT ((1)) NOT NULL,
    [TokenCreated]              NVARCHAR (50)   NOT NULL,
    [DateCreated]               DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([IdAPGuidesControlLog] ASC)
);

GO
CREATE NONCLUSTERED INDEX [IDX_APGuidesControlLogs_DateCreated]
    ON [dbo].[APGuidesControlLogs]([DateCreated] ASC);

GO
CREATE NONCLUSTERED INDEX [IDX_APGuidesControlLogs_ProcessName]
    ON [dbo].[APGuidesControlLogs]([ProcessName] ASC);

GO
CREATE NONCLUSTERED INDEX [IDX_APGuidesControlLogs_TrackingCode]
    ON [dbo].[APGuidesControlLogs]([TrackingCode] ASC);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que almacena los logs de errores del proceso de creación de guías de Aeropost', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro de log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'IdAPGuidesControlLog';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de tracking relacionado al error', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'TrackingCode';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del proceso que generó el error', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'ProcessName';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mensaje de error descriptivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'ErrorMessage';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Detalles técnicos del error (stack trace, etc.)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'ErrorDetails';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Datos de la request que generó el error', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'RequestData';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Datos de la response (si aplica)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'ResponseData';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1=Activo, 0=Inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario/sistema que generó el log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'DateCreated';