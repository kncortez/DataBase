
CREATE TABLE [dbo].[IncidentStatus] (
    [IncidentStatusId] INT IDENTITY(1,1) NOT NULL,
	[Name] 			NVARCHAR (50)	NOT NULL,
	[DateCreated] 	DATETIME NOT 	NULL,
    [TokenCreated] 	NVARCHAR(50)	NOT NULL,
	[DateUpdated]   DATETIME		NULL,
	[TokenUpdated]	NVARCHAR (50)	NULL,
	[RowStatus] BIT NOT NULL DEFAULT 1
	PRIMARY KEY CLUSTERED ([IncidentStatusId] ASC)
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Identificador del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'IncidentStatus',
	@level2type = N'COLUMN',
	@level2name = N'IncidentStatusId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Nombre del estado del incidente.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'IncidentStatus',
	@level2type = N'COLUMN',
	@level2name = N'Name';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Fecha de creación del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'IncidentStatus',
	@level2type = N'COLUMN',
	@level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Token de creación del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'IncidentStatus',
	@level2type = N'COLUMN',
	@level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Fecha de actualización del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'IncidentStatus',
	@level2type = N'COLUMN',
	@level2name = N'DateUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Token de actualización del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'IncidentStatus',
	@level2type = N'COLUMN',
	@level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Estado lógico del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'IncidentStatus',
	@level2type = N'COLUMN',
	@level2name = N'RowStatus';