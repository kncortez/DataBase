CREATE TABLE [dbo].[ServiceTimeConfiguration] (
    [IdServiceTimeConfiguration] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CatConfigurableServiceId]   INT           NOT NULL,
    [StartingTime]               TIME (7)      NOT NULL,
    [FinishingTime]              TIME (7)      NOT NULL,
    [TimeStep]                   INT           NOT NULL,
    [RowStatus]                  BIT           NOT NULL,
    [TokenCreated]               NVARCHAR (50) NOT NULL,
    [DateCreated]                DATETIME      NOT NULL,
    [TokenUpdated]               NVARCHAR (50) NULL,
    [DateUpdated]                DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdServiceTimeConfiguration] ASC),
    CONSTRAINT [FK_ServiceTimeConfiguration_CatConfigurableService] FOREIGN KEY ([CatConfigurableServiceId]) REFERENCES [dbo].[CatConfigurableService] ([IdCatConfigurableService])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de tiempo de ejecución de servicios configurables', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceTimeConfiguration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceTimeConfiguration', @level2type = N'COLUMN', @level2name = N'IdServiceTimeConfiguration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del servicio en la tabla CatConfigurableService', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceTimeConfiguration', @level2type = N'COLUMN', @level2name = N'CatConfigurableServiceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tiempo de inicio del servicio (Formato 24horas)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceTimeConfiguration', @level2type = N'COLUMN', @level2name = N'StartingTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tiempo de finalización del servicio (Formato 24horas)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceTimeConfiguration', @level2type = N'COLUMN', @level2name = N'FinishingTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Intervalo de tiempo de ejecución (En minutos)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceTimeConfiguration', @level2type = N'COLUMN', @level2name = N'TimeStep';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceTimeConfiguration', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceTimeConfiguration', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceTimeConfiguration', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceTimeConfiguration', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceTimeConfiguration', @level2type = N'COLUMN', @level2name = N'DateUpdated';

