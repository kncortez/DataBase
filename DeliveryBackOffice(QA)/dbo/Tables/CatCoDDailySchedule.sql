CREATE TABLE [dbo].[CatCoDDailySchedule] (
    [IdCatCoDDailySchedule] INT            IDENTITY (1, 1) NOT NULL,
    [CoDProcessName]        NVARCHAR (100) NOT NULL,
    [DeliveryBankId]        INT            NOT NULL,
    [ExecutionTime]         TIME (7)       NOT NULL,
    [ProcessPriority]       INT            NOT NULL,
    [RowStatus]             BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]          NVARCHAR (50)  NOT NULL,
    [DateCreated]           DATETIME       NOT NULL,
    [TokenUpdated]          NVARCHAR (50)  NULL,
    [DateUpdated]           DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdCatCoDDailySchedule] ASC),
    CONSTRAINT [FK_CatCoDDailySchedule_DeliveryBank] FOREIGN KEY ([DeliveryBankId]) REFERENCES [dbo].[DeliveryBank] ([Id_bank])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCoDDailySchedule', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCoDDailySchedule', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCoDDailySchedule', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCoDDailySchedule', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCoDDailySchedule', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica la prioridad para ejecutar los procesos, utilizado para ordenar la ejecución (A mayor prioridad, sube en la cola de ejecución).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCoDDailySchedule', @level2type = N'COLUMN', @level2name = N'ProcessPriority';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hora especifica en la cual debe ejecutarse el proceso en el servicio de CoD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCoDDailySchedule', @level2type = N'COLUMN', @level2name = N'ExecutionTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del banco objetivo de la tabla DelvieryBank.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCoDDailySchedule', @level2type = N'COLUMN', @level2name = N'DeliveryBankId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre que identifica al proceso de CoD a ejecutar.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCoDDailySchedule', @level2type = N'COLUMN', @level2name = N'CoDProcessName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCoDDailySchedule', @level2type = N'COLUMN', @level2name = N'IdCatCoDDailySchedule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogo de procesos de CoD a ejecutar con su respectivo horario y banco objetivo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCoDDailySchedule';

