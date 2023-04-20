CREATE TABLE [dbo].[ServiceAssignmentAttempt] (
    [IdServiceAssignmentAttempt] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ServiceId]                  BIGINT        NOT NULL,
    [CourierId]                  INT           NOT NULL,
    [RowStatus]                  BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]                DATETIME      NOT NULL,
    [TokenCreated]               NVARCHAR (50) NOT NULL,
    [DateUpdated]                DATETIME      NULL,
    [TokenUpdated]               NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdServiceAssignmentAttempt] ASC),
    CONSTRAINT [FK_ServiceAssignmentAttempt_Courier] FOREIGN KEY ([CourierId]) REFERENCES [dbo].[SenderReceiver] ([ID]),
    CONSTRAINT [FK_ServiceAssignmentAttempt_Service] FOREIGN KEY ([ServiceId]) REFERENCES [dbo].[Service] ([IdService])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceAssignmentAttempt', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceAssignmentAttempt', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceAssignmentAttempt', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceAssignmentAttempt', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceAssignmentAttempt', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del courier de la tabla SenderReceiver.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceAssignmentAttempt', @level2type = N'COLUMN', @level2name = N'CourierId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del servicio de la tabla Service.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceAssignmentAttempt', @level2type = N'COLUMN', @level2name = N'ServiceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceAssignmentAttempt', @level2type = N'COLUMN', @level2name = N'IdServiceAssignmentAttempt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de bitácora para guardar los intentos de asignación de servicios a couriers.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceAssignmentAttempt';

