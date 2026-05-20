CREATE TABLE [dbo].[DeliveryManifestAssistantAssignment] (
	[DeliveryManifestId]	BIGINT			NOT NULL,
    [CourierAssistantId]	INT				NOT NULL,
    [TokenCreated]			VARCHAR (50)	NOT NULL,
    [DateCreated]      		DATETIME		NOT NULL,
    [TokenUpdated]     		VARCHAR (50)	NULL,
    [DateUpdated]      		DATETIME		NULL,
	[RowStatus]             BIT				DEFAULT ((1)) NOT NULL,
	CONSTRAINT PK_DeliveryManifestAssistantAssignment PRIMARY KEY (DeliveryManifestId, CourierAssistantId),
	CONSTRAINT FK_DeliveryManifestAssistantAssignment_ManifestId FOREIGN KEY (DeliveryManifestId) REFERENCES dbo.DeliveryOrderBySettlement(ID),
	CONSTRAINT FK_DeliveryManifestAssistantAssignment_AssistantId FOREIGN KEY (CourierAssistantId) REFERENCES dbo.SenderReceiver(ID)
);

EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'PK y manifiesto de despacho de entregas.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'DeliveryManifestAssistantAssignment',
	@level2type = N'COLUMN',
	@level2name = N'DeliveryManifestId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'PK de Courier de tipo 6 (CatTypeSenderReceiverId).',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'DeliveryManifestAssistantAssignment',
	@level2type = N'COLUMN',
	@level2name = N'CourierAssistantId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Fecha de creación del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'DeliveryManifestAssistantAssignment',
	@level2type = N'COLUMN',
	@level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Token de creación del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'DeliveryManifestAssistantAssignment',
	@level2type = N'COLUMN',
	@level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Última fecha de actualización del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'DeliveryManifestAssistantAssignment',
	@level2type = N'COLUMN',
	@level2name = N'DateUpdated';

GO
EXECUTE sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Último token de actualización del registro.', 
	@level0type = N'SCHEMA', 
	@level0name = N'dbo', 
	@level1type = N'TABLE', 
	@level1name = N'DeliveryManifestAssistantAssignment', 
	@level2type = N'COLUMN', 
	@level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Estado lógico del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'DeliveryManifestAssistantAssignment',
	@level2type = N'COLUMN',
	@level2name = N'RowStatus';
