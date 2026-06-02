
CREATE TABLE [dbo].[WorkflowStatusMap] (
    [WorkflowId]    BIGINT        NOT NULL,
    [StatusOrderId] TINYINT       NOT NULL,
    [DateCreated]   DATETIME      NOT NULL,
    [TokenCreated]  NVARCHAR (50) NOT NULL,
    [DateUpdated]   DATETIME      NULL,
    [TokenUpdated]  NVARCHAR (50) NULL,
    [RowStatus]     BIT           DEFAULT ((1)) NOT NULL,
    [CountryId]     NVARCHAR (2)  NULL,
    CONSTRAINT [FK_WorkflowStatusMap_StatusOrder] FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder] ([StatusOrderId]),
    CONSTRAINT [FK_WorkflowStatusMap_Workflow] FOREIGN KEY ([WorkflowId]) REFERENCES [dbo].[Workflow] ([WorkflowId])
);



GO
CREATE UNIQUE INDEX UQ_WorkflowStatusMap_Workflow_Status_Active ON dbo.WorkflowStatusMap (WorkflowId, StatusOrderId) WHERE RowStatus = 1;

GO


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'ID de Workflow.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'WorkflowStatusMap',
	@level2type = N'COLUMN',
	@level2name = N'WorkflowId';

EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'ID de StatusOrder.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'WorkflowStatusMap',
	@level2type = N'COLUMN',
	@level2name = N'StatusOrderId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Fecha de creación del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'WorkflowStatusMap',
	@level2type = N'COLUMN',
	@level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Token de creación del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'WorkflowStatusMap',
	@level2type = N'COLUMN',
	@level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Última fecha de actualización del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'WorkflowStatusMap',
	@level2type = N'COLUMN',
	@level2name = N'DateUpdated';

GO
EXECUTE sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Último token de actualización del registro.', 
	@level0type = N'SCHEMA', 
	@level0name = N'dbo', 
	@level1type = N'TABLE', 
	@level1name = N'WorkflowStatusMap', 
	@level2type = N'COLUMN', 
	@level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Estado lógico del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'WorkflowStatusMap',
	@level2type = N'COLUMN',
	@level2name = N'RowStatus';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de Workflow.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorkflowStatusMap', @level2type = N'COLUMN', @level2name = N'WorkflowId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de StatusOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorkflowStatusMap', @level2type = N'COLUMN', @level2name = N'StatusOrderId';

