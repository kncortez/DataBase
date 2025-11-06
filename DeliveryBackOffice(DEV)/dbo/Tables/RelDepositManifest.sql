CREATE TABLE [dbo].[RelDepositManifest]
(
	[IdRelDepositManifest]			BIGINT			IDENTITY PRIMARY KEY,
	[IdDeposit]						BIGINT			NOT NULL,
	[DeliveryOrderBySettlementId]	BIGINT			NOT NULL,
	[AmountApplied]					DECIMAL(19,4)	NOT NULL,
	[RowStatus]						BIT				NOT NULL,
	[TokenCreated]					NVARCHAR(100)	NOT NULL,
	[DateCreated]					DATETIME		NOT NULL,
	[TokenUpdated]					NVARCHAR(100)	NULL,
	[DateUpdated]					DATETIME		NULL,
	CONSTRAINT [FK_Rel_Deposit] FOREIGN KEY ([IdDeposit]) REFERENCES [dbo].[Deposit]([IdDeposit]),
	CONSTRAINT [FK_Rel_DOBSettlement] FOREIGN KEY ([DeliveryOrderBySettlementId]) REFERENCES [dbo].[DeliveryOrderBySettlement]([ID])
)

GO
CREATE INDEX IX_Rel_Settlement ON dbo.RelDepositManifest(DeliveryOrderBySettlementId);
    
GO
CREATE INDEX IX_Rel_Deposit_Settlement ON dbo.RelDepositManifest (IdDeposit, DeliveryOrderBySettlementId) INCLUDE (AmountApplied, RowStatus, DateCreated);

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla puente N–a–N entre depósitos y manifiestos.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la relación (PK).', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'IdRelDepositManifest';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'FK al depósito (Deposit.IdDeposit).', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'IdDeposit';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'FK al manifiesto (DeliveryOrderBySettlement.ID).', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'DeliveryOrderBySettlementId';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Importe del depósito aplicado al manifiesto.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'AmountApplied';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico: 1=Activo, 0=Inactivo.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'RowStatus';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha/hora de creación del registro.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de última actualización.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha/hora de la última actualización.', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'DateUpdated';
