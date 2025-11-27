CREATE TABLE [dbo].[CoDDailyExecution] (
    [IdCoDDailyExecution] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CodDailyScheduleId]  INT             NOT NULL,
    [ExecutionDate]       DATE            NOT NULL,
    [CoDProcessName]      NVARCHAR (100)  NOT NULL,
    [DeliveryBankId]      INT             NOT NULL,
    [ExecutionTime]       TIME (7)        NOT NULL,
    [ProcessPriority]     INT             NOT NULL,
    [ProcessPending]      BIT             DEFAULT ((0)) NOT NULL,
    [ProcessStarted]      BIT             DEFAULT ((0)) NOT NULL,
    [ProcessFinished]     BIT             DEFAULT ((0)) NOT NULL,
    [ProcessRetries]      INT             NULL,
    [ProcessError]        NVARCHAR (4000) NULL,
    [RowStatus]           BIT             DEFAULT ((1)) NOT NULL,
    [TokenCreated]        NVARCHAR (50)   NOT NULL,
    [DateCreated]         DATETIME        NOT NULL,
    [TokenUpdated]        NVARCHAR (50)   NULL,
    [DateUpdated]         DATETIME        NULL,
    [IdCountry]           VARCHAR (2)     DEFAULT ('GT') NULL,
    PRIMARY KEY CLUSTERED ([IdCoDDailyExecution] ASC),
    CONSTRAINT [FK_CoDDailyExectuion_CoDDailySchedule] FOREIGN KEY ([CodDailyScheduleId]) REFERENCES [dbo].[CatCoDDailySchedule] ([IdCatCoDDailySchedule]),
    CONSTRAINT [FK_CoDDailyExectuion_DeliveryBank] FOREIGN KEY ([DeliveryBankId]) REFERENCES [dbo].[DeliveryBank] ([Id_bank])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Describe el último error ocurrido en la ejecución del proceso.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'ProcessError';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica la cantidad de veces que se ha reintentado un proceso.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'ProcessRetries';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica si el proceso ha sido completado exitosamente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'ProcessFinished';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica si el proceso ha iniciado su ejecución.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'ProcessStarted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica si el proceso esta pendiente de ejecutar (Si ya es posible ejecutarlo).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'ProcessPending';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica la prioridad para ejecutar los procesos, utilizado para ordenar la ejecución (A mayor prioridad, sube en la cola de ejecución).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'ProcessPriority';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hora especifica en la cual debe ejecutarse el proceso en el servicio de CoD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'ExecutionTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del banco objetivo de la tabla DelvieryBank.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'DeliveryBankId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre que identifica al proceso de CoD a ejecutar.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'CoDProcessName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de ejecución del proceso.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'ExecutionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del horario preestablecido de la tabla CatCoDDailySchedule.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'CodDailyScheduleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'IdCoDDailyExecution';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pais de ejecucion de proceso de servicio COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution', @level2type = N'COLUMN', @level2name = N'IdCountry';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de procesos de servicio de CoD ejecutados diariamente, sirviendo también como una bitácora de la ejecución del servicio durante el día.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CoDDailyExecution';

