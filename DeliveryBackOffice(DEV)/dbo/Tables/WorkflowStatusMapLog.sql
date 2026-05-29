CREATE TABLE [dbo].[WorkflowStatusMapLog] (
    [WorkflowStatusMapLogId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [WorkflowId]             BIGINT        NOT NULL,
    [StatusOrderId]          TINYINT       NOT NULL,
    [OperationType]          TINYINT       NOT NULL,
    [DateCreated]            DATETIME      NOT NULL,
    [TokenCreated]           NVARCHAR (50) NOT NULL,
    [RowStatus]              BIT           DEFAULT ((1)) NOT NULL,
    [CountryId]              NVARCHAR (2)  NULL,
    CONSTRAINT [PK_WorkflowStatusMapLog] PRIMARY KEY CLUSTERED ([WorkflowStatusMapLogId] ASC),
    CONSTRAINT [FK_WorkflowStatusMapLog_StatusOrder] FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder] ([StatusOrderId]),
    CONSTRAINT [FK_WorkflowStatusMapLog_Workflow] FOREIGN KEY ([WorkflowId]) REFERENCES [dbo].[Workflow] ([WorkflowId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorkflowStatusMapLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorkflowStatusMapLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorkflowStatusMapLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de operacion: 0 deshabilitado, 1 habilitado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorkflowStatusMapLog', @level2type = N'COLUMN', @level2name = N'OperationType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de StatusOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorkflowStatusMapLog', @level2type = N'COLUMN', @level2name = N'StatusOrderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de Workflow.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorkflowStatusMapLog', @level2type = N'COLUMN', @level2name = N'WorkflowId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorkflowStatusMapLog', @level2type = N'COLUMN', @level2name = N'WorkflowStatusMapLogId';

