
CREATE TABLE [dbo].[Workflow] (
    [WorkflowId]   BIGINT	IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]                  NVARCHAR (50) NOT NULL,
    [DateCreated]           DATETIME      NOT NULL,
    [TokenCreated]          NVARCHAR (50) NOT NULL,
    [DateUpdated]           DATETIME      NULL,
    [TokenUpdated]          NVARCHAR (50) NULL,
	[RowStatus]             BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([WorkflowId] ASC)
);

GO
CREATE NONCLUSTERED INDEX [IDX_Workflow_Name] ON [dbo].[Workflow]([Name]);

--para que el nombre sea unico solo cuando la tupla este activa
GO
CREATE UNIQUE INDEX [UQ_Workflow_Name_Active] ON [dbo].[Workflow]([Name]) WHERE RowStatus = 1;

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Identificador del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'Workflow',
	@level2type = N'COLUMN',
	@level2name = N'WorkflowId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Nombre del flujo de trabajo.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'Workflow',
	@level2type = N'COLUMN',
	@level2name = N'Name';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Fecha de creación del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'Workflow',
	@level2type = N'COLUMN',
	@level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Token de creación del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'Workflow',
	@level2type = N'COLUMN',
	@level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Última fecha de actualización del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'Workflow',
	@level2type = N'COLUMN',
	@level2name = N'DateUpdated';

GO
EXECUTE sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Último token de actualización del registro.', 
	@level0type = N'SCHEMA', 
	@level0name = N'dbo', 
	@level1type = N'TABLE', 
	@level1name = N'Workflow', 
	@level2type = N'COLUMN', 
	@level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Estado lógico del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'Workflow',
	@level2type = N'COLUMN',
	@level2name = N'RowStatus';
