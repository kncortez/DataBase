CREATE TABLE [dbo].[APExecutionSchedule] (
    [IdAPExecutionSchedule] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CountryCode]           NVARCHAR (2)   NOT NULL,
    [StartTime]             TIME (7)       NOT NULL,
    [Description]           NVARCHAR (100) NULL,
    [AeroPostIdByCountry]   INT            NOT NULL,
    [CodeOfReference]       INT            NOT NULL,
    [RowStatus]             BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]          NVARCHAR (50)  NOT NULL,
    [DateCreated]           DATETIME       NOT NULL,
    [TokenUpdated]          NVARCHAR (50)  NULL,
    [DateUpdated]           DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdAPExecutionSchedule] ASC),
    CONSTRAINT [FK_APExecutionSchedule_Customer] FOREIGN KEY ([AeroPostIdByCountry]) REFERENCES [dbo].[Customer] ([IdCustomer])
);



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que almacena los horarios de ejecución del servicio de creación de guías de Aeropost', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'IdAPExecutionSchedule';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código del país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'CountryCode';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Horario de ejecución del servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'StartTime';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del horario de ejecución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'Description';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1=Activo, 0=Inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id de cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'AeroPostIdByCountry';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'codigo de referencia del visit point', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'CodeOfReference';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro en el sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'DateUpdated';
GO
