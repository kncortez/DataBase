CREATE TABLE [dbo].[Cost] (
    [IdCost]                      INT             IDENTITY (1, 1) NOT NULL,
    [IdProduct]                   INT             NULL,
    [ProductNumber]               VARCHAR (100)   NULL,
    [IdTypeCharge]                INT             NULL,
    [TotalAmount]                 DECIMAL (18, 2) NULL,
    [PaymentDate]                 DATETIME        NULL,
    [IdModule]                    INT             NULL,
    [RowStatus]                   BIT             NULL,
    [TokenCreated]                VARCHAR (50)    NOT NULL,
    [DateCreated]                 DATETIME        NOT NULL,
    [TokenUpdated]                VARCHAR (50)    NULL,
    [DateUpdated]                 DATETIME        NULL,
    [TotalAmountPaid]             DECIMAL (12, 2) NULL,
    [CODAmount]                   DECIMAL (12, 2) NULL,
    [ReturnAmount]                DECIMAL (12, 2) NULL,
    [ReturnPaid]                  DECIMAL (12, 2) NULL,
    [GuideSerie]                  NVARCHAR (2)    NULL,
    [GuideNumber]                 INT             NULL,
    [ShippingCurrency]            INT             NULL,
    [ShippingExchangeRate]        DECIMAL(12, 4)  NULL,
    [CodCurrency]                 INT             NULL,
    [CodExchangeRate]             DECIMAL(12, 4)  NULL,
    [DeliveryPaymentCurrency]     INT             NULL,
    [DeliveryPaymentExchangeRate] DECIMAL(12, 4)  NULL,
    [CODPaymentCurrency]          INT             NULL,
    [CODPaymentExchangeRate]      DECIMAL(12, 4)  NULL,
    PRIMARY KEY CLUSTERED ([IdCost] ASC),
    CONSTRAINT [FK_Cost_Guide] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FKCostCharge] FOREIGN KEY ([IdTypeCharge]) REFERENCES [dbo].[CatTypeCharge] ([IdTypeCharge]),
    CONSTRAINT [FKCostModule] FOREIGN KEY ([IdModule]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FKCostProduct] FOREIGN KEY ([IdProduct]) REFERENCES [dbo].[CatTypeProduct] ([IdTypeProduct]),
    CONSTRAINT [FK_ShippingCurrency_CatCurrencyCOD] FOREIGN KEY (ShippingCurrency) REFERENCES [dbo].[CatCurrencyCOD](IdCatCurrencyCOD),
    CONSTRAINT [FK_CodCurrency_CatCurrencyCOD] FOREIGN KEY (CodCurrency) REFERENCES [dbo].[CatCurrencyCOD](IdCatCurrencyCOD),
    CONSTRAINT [FK_DeliveryPaymentCurrency_CatCurrencyCOD] FOREIGN KEY (DeliveryPaymentCurrency) REFERENCES [dbo].[CatCurrencyCOD](IdCatCurrencyCOD),
    CONSTRAINT [FK_CODPaymentCurrency_CatCurrencyCOD] FOREIGN KEY (CODPaymentCurrency) REFERENCES [dbo].[CatCurrencyCOD](IdCatCurrencyCOD)
);

GO
CREATE NONCLUSTERED INDEX [IDX_product_number_cost]
    ON [dbo].[Cost]([IdProduct] ASC, [ProductNumber] ASC);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor que se debe pagar por devolución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'ReturnAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor que se debe pagar por devolución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'ReturnPaid';

GO
CREATE NONCLUSTERED INDEX [IDX_RowStatus]
    ON [dbo].[Cost]([RowStatus] ASC)
    INCLUDE([ProductNumber], [TotalAmountPaid], [CODAmount]);

GO
CREATE NONCLUSTERED INDEX [IDX_ProductNumber]
    ON [dbo].[Cost]([ProductNumber] ASC)
    INCLUDE([TotalAmountPaid], [CODAmount]);

GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_GuideSerie_GuideNumber]
    ON [dbo].[Cost]([GuideSerie] ASC, [GuideNumber] ASC) WHERE ([GuideSerie] IS NOT NULL AND [GuideNumber] IS NOT NULL);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía de la tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'GuideSerie';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de la guía de la tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'GuideNumber';

GO
CREATE NONCLUSTERED INDEX [IDX_RowStatus_Included]
    ON [dbo].[Cost]([RowStatus] ASC)
    INCLUDE([IdCost], [ProductNumber], [DateCreated], [GuideSerie], [GuideNumber]);

GO
CREATE NONCLUSTERED INDEX [IDX_RowStatus_DateCreated]
    ON [dbo].[Cost]([RowStatus] ASC, [DateCreated] DESC)
    INCLUDE([IdCost], [ProductNumber], [GuideSerie], [GuideNumber]);

GO
CREATE NONCLUSTERED INDEX [IDX_ProductNumber_RowStatus]
    ON [dbo].[Cost]([ProductNumber] ASC, [RowStatus] ASC)
    INCLUDE([TotalAmountPaid], [CODAmount]);

GO
CREATE NONCLUSTERED INDEX [idx_IdProduct_GuideSerie_GuideNumber]
    ON [dbo].[Cost]([IdProduct] ASC, [GuideSerie] ASC, [GuideNumber] ASC)
    INCLUDE([IdCost]);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de moneda de envio para la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'ShippingCurrency';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tasa de cambio de envio para la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'ShippingExchangeRate';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de moneda de COD para la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'CodCurrency';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tasa de cambio de COD para la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'CodExchangeRate';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de moneda de pago de envio ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'DeliveryPaymentCurrency';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tasa de cambio del pago de envio ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'DeliveryPaymentExchangeRate';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de moneda de pago para COD ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'CODPaymentCurrency';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tasa de cambio del pago del COD ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'CODPaymentExchangeRate';
