CREATE TABLE [dbo].[InvoiceDailyExecution] (
    [IdInvoiceDailyExecution] INT             IDENTITY (1, 1) NOT NULL,
    [InvoiceDailyScheduleId]  INT             NOT NULL,
    [ExecutionDate]           DATE            NOT NULL,
    [InvoiceProcessName]      NVARCHAR (100)  NOT NULL,
    [ExecutionTime]           TIME (7)        NOT NULL,
    [ProcessPriority]         INT             NOT NULL,
    [ProcessPending]          BIT             DEFAULT ((0)) NOT NULL,
    [ProcessStarted]          BIT             DEFAULT ((0)) NOT NULL,
    [ProcessFinished]         BIT             DEFAULT ((0)) NOT NULL,
    [ProcessRetries]          INT             NULL,
    [ProcessError]            NVARCHAR (4000) NULL,
    [RowStatus]               BIT             DEFAULT ((1)) NOT NULL,
    [TokenCreated]            NVARCHAR (50)   NOT NULL,
    [DateCreated]             DATETIME        NOT NULL,
    [TokenUpdated]            NVARCHAR (50)   NULL,
    [DateUpdated]             DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdInvoiceDailyExecution] ASC),
    CONSTRAINT [FK_InvoiceDailyExecution_InvoiceDailySchedule] FOREIGN KEY ([InvoiceDailyScheduleId]) REFERENCES [dbo].[CatInvoiceDailySchedule] ([IdCatInvoiceDailySchedule])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Describe el último error ocurrido en la ejecución del proceso.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'ProcessError';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica la cantidad de veces que se ha reintentado un proceso.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'ProcessRetries';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica si el proceso ha sido completado exitosamente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'ProcessFinished';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica si el proceso ha iniciado su ejecución.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'ProcessStarted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica si el proceso esta pendiente de ejecutar (Si ya es posible ejecutarlo).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'ProcessPending';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica la prioridad para ejecutar los procesos, utilizado para ordenar la ejecución (A mayor prioridad, sube en la cola de ejecución).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'ProcessPriority';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hora especifica en la cual debe ejecutarse el proceso en el servicio de CoD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'ExecutionTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre que identifica al proceso de facturación a ejecutar.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'InvoiceProcessName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de ejecución del proceso.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'ExecutionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del horario preestablecido de la tabla CatInvoiceDailySchedule.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'InvoiceDailyScheduleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution', @level2type = N'COLUMN', @level2name = N'IdInvoiceDailyExecution';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de procesos de servicio de facturación ejecutados diariamente, sirviendo también como una bitácora de la ejecución del servicio durante el día.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceDailyExecution';

