CREATE TABLE [dbo].[ServicesConfig] (
    [IdServicesConfig] BIGINT          IDENTITY (1, 1) NOT NULL,
    [ServiceName]      VARCHAR (500)   NOT NULL,
    [ServiceProcess]   VARCHAR (500)   NOT NULL,
    [TimeSchedule]     VARCHAR (4000)  NOT NULL,
    [RowStatus]        BIT             NOT NULL,
    [NotifyEmails]     NVARCHAR (2000) NOT NULL,
    [TokenCreated]     VARCHAR (50)    NOT NULL,
    [DateCreated]      DATETIME        NOT NULL,
    [TokenUpdated]     VARCHAR (50)    NULL,
    [DateUpdated]      DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdServicesConfig] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador primario de la tabla ServicesConfig', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicesConfig', @level2type = N'COLUMN', @level2name = N'IdServicesConfig';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del servicio al que pertenece la configuración', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicesConfig', @level2type = N'COLUMN', @level2name = N'ServiceName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del proceso que pertenece al servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicesConfig', @level2type = N'COLUMN', @level2name = N'ServiceProcess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Listado de horarios separados por coma , en el que se ejecutarán los procesos en el servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicesConfig', @level2type = N'COLUMN', @level2name = N'TimeSchedule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicesConfig', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Listado de correos electrónicos separados por coma, para poder notificar de ser necesario, cuando se ejecutó el proceso', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicesConfig', @level2type = N'COLUMN', @level2name = N'NotifyEmails';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario o sistema que creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicesConfig', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicesConfig', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario o sistema que actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicesConfig', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en que se actualiza el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicesConfig', @level2type = N'COLUMN', @level2name = N'DateUpdated';

