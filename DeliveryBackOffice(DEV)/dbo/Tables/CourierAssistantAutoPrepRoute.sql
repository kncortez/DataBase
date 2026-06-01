CREATE TABLE [dbo].[CourierAssistantAutoPrepRoute] (
    [CourierAssistantAutoPrepRouteId] INT IDENTITY(1,1) NOT NULL,
	[RoutePreparationId]	INT				NOT NULL,
    [CourierAssistantId]	INT				NOT NULL,
    [TokenCreated]			VARCHAR (50)	NOT NULL,
    [DateCreated]      		DATETIME		NOT NULL,
    [TokenUpdated]     		VARCHAR (50)	NULL,
    [DateUpdated]      		DATETIME		NULL,
	[RowStatus]             BIT				DEFAULT ((1)) NOT NULL,
	CONSTRAINT PK_CourierAssistantAutoPrepRoute PRIMARY KEY (CourierAssistantAutoPrepRouteId),
	CONSTRAINT FK_CourierAssistantAutoPrepRoute_ManifestId FOREIGN KEY (RoutePreparationId) REFERENCES dbo.RoutePreparation(IdRoutePreparation),
	CONSTRAINT FK_CourierAssistantAutoPrepRoute_AssistantId FOREIGN KEY (CourierAssistantId) REFERENCES dbo.SenderReceiver(ID)
);

EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'PK de esta tabla.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'CourierAssistantAutoPrepRoute',
	@level2type = N'COLUMN',
	@level2name = N'CourierAssistantAutoPrepRouteId';

EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'PK tabla preparación de ruta.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'CourierAssistantAutoPrepRoute',
	@level2type = N'COLUMN',
	@level2name = N'RoutePreparationId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'PK de Courier de tipo 6 (CatTypeSenderReceiverId).',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'CourierAssistantAutoPrepRoute',
	@level2type = N'COLUMN',
	@level2name = N'CourierAssistantId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Fecha de creación del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'CourierAssistantAutoPrepRoute',
	@level2type = N'COLUMN',
	@level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Token de creación del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'CourierAssistantAutoPrepRoute',
	@level2type = N'COLUMN',
	@level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Última fecha de actualización del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'CourierAssistantAutoPrepRoute',
	@level2type = N'COLUMN',
	@level2name = N'DateUpdated';

GO
EXECUTE sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Último token de actualización del registro.', 
	@level0type = N'SCHEMA', 
	@level0name = N'dbo', 
	@level1type = N'TABLE', 
	@level1name = N'CourierAssistantAutoPrepRoute', 
	@level2type = N'COLUMN', 
	@level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Estado lógico del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'CourierAssistantAutoPrepRoute',
	@level2type = N'COLUMN',
	@level2name = N'RowStatus';
