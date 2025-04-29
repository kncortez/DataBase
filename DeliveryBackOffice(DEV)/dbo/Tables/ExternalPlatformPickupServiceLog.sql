CREATE TABLE [dbo].[ExternalPlatformPickupServiceLog] (
    [IdExternalPlatformPickupServiceLog] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CatExternalPlatformId]              INT           NOT NULL,
    [ServiceManagementId]                INT           NOT NULL,
    [IsInExternalPlatform]               BIT           NOT NULL,
    [RowStatus]                          BIT           NOT NULL,
    [TokenCreated]                       NVARCHAR (50) NOT NULL,
    [DateCreated]                        DATETIME      NOT NULL,
    [TokenUpdated]                       NVARCHAR (50) NULL,
    [DateUpdated]                        DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdExternalPlatformPickupServiceLog] ASC),
    CONSTRAINT [FK_ExternalPlatformPickupServiceLog_CatExternalPlatformId] FOREIGN KEY ([CatExternalPlatformId]) REFERENCES [dbo].[CatExternalPlatform] ([IdExternalPlatform])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformPickupServiceLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que actualizó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformPickupServiceLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformPickupServiceLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que generó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformPickupServiceLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformPickupServiceLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicador de envío exitoso a plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformPickupServiceLog', @level2type = N'COLUMN', @level2name = N'IsInExternalPlatform';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del servicio de recolección al cuál pertenece el registro | Tabla ServiceManagement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformPickupServiceLog', @level2type = N'COLUMN', @level2name = N'ServiceManagementId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la plataforma externa destino | Tabla CatExternalPlatform', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformPickupServiceLog', @level2type = N'COLUMN', @level2name = N'CatExternalPlatformId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformPickupServiceLog', @level2type = N'COLUMN', @level2name = N'IdExternalPlatformPickupServiceLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para guardar log de recolecciones programadas enviadas a SimpliRoute', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformPickupServiceLog';

