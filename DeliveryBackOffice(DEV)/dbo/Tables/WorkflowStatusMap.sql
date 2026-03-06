
CREATE TABLE [dbo].[WorkflowStatusMap] (
    [WorkflowStatusMapId]	BIGINT	IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [WorkflowId]			BIGINT			NOT NULL,
	[StatusOrderId]         TINYINT			NOT NULL,
    [DateCreated]           DATETIME		NOT NULL,
    [TokenCreated]          NVARCHAR (50)	NOT NULL,
    [DateUpdated]           DATETIME		NULL,
    [TokenUpdated]          NVARCHAR (50)	NULL,
	[RowStatus]             BIT 			NOT NULL DEFAULT ((1)),
	CONSTRAINT PK_WorkflowStatusMap PRIMARY KEY (WorkflowStatusMapId),
	CONSTRAINT FK_WorkflowStatusMap_Workflow FOREIGN KEY (WorkflowId) REFERENCES dbo.Workflow(WorkflowId),
	CONSTRAINT FK_WorkflowStatusMap_StatusOrder FOREIGN KEY (StatusOrderId) REFERENCES dbo.StatusOrder(StatusOrderId)
);

GO
CREATE UNIQUE INDEX UQ_WorkflowStatusMap_Workflow_Status_Active ON dbo.WorkflowStatusMap (WorkflowId, StatusOrderId) WHERE RowStatus = 1;

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Identificador del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'WorkflowStatusMap',
	@level2type = N'COLUMN',
	@level2name = N'WorkflowStatusMapId';

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
