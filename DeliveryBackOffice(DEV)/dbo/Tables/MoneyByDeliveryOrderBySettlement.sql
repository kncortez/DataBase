CREATE TABLE [dbo].[MoneyByDeliveryOrderBySettlement] (
    [CatMoneyId]                  INT    NOT NULL,
    [DeliveryOrderBySettlementId] BIGINT NOT NULL,
    [Quantity]                    INT    NOT NULL,
    CONSTRAINT [PK_MoneyByDeliveryOrderBySettlement_CatMoneyId_DeliveryOrderBySettlementId] PRIMARY KEY CLUSTERED ([CatMoneyId] ASC, [DeliveryOrderBySettlementId] ASC),
    CONSTRAINT [FK_MoneyByDeliveryOrderBySettlement_CatMoneyId] FOREIGN KEY ([CatMoneyId]) REFERENCES [dbo].[CatMoney] ([IdCatMoney]),
    CONSTRAINT [FK_MoneyByDeliveryOrderBySettlement_DeliveryOrderBySettlementId] FOREIGN KEY ([DeliveryOrderBySettlementId]) REFERENCES [dbo].[DeliveryOrderBySettlement] ([ID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que relaciona una denominación con un manifiesto de liquidación de última milla.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MoneyByDeliveryOrderBySettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatMoney, que indica el id de la denominación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MoneyByDeliveryOrderBySettlement', @level2type = N'COLUMN', @level2name = N'CatMoneyId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla DeliveryOrderBySettlement, que indica el id del manifiesto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MoneyByDeliveryOrderBySettlement', @level2type = N'COLUMN', @level2name = N'DeliveryOrderBySettlementId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de la denominación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MoneyByDeliveryOrderBySettlement', @level2type = N'COLUMN', @level2name = N'Quantity';

