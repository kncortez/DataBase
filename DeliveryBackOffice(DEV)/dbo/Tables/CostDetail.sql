CREATE TABLE [dbo].[CostDetail] (
    [IdCostDetail]         INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [IdCost]               INT             NULL,
    [IdTypeOfMoney]        INT             NULL,
    [Amount]               DECIMAL (18, 2) NULL,
    [Voucher]              VARCHAR (300)   NULL,
    [RowStatus]            BIT             NULL,
    [TokenCreated]         VARCHAR (50)    NOT NULL,
    [DateCreated]          DATETIME        NOT NULL,
    [TokenUpdated]         VARCHAR (50)    NULL,
    [DateUpdated]          DATETIME        NULL,
    [Responsible]          NVARCHAR (100)  NULL,
    [IdTypeOfMoneyCOD]     INT             NULL,
    [IdTypeOfMoneyCollect] INT             NULL,
    [VoucherPath]          NVARCHAR (500)  NULL,
    PRIMARY KEY CLUSTERED ([IdCostDetail] ASC),
    CONSTRAINT [FK_CostDetail_TypeOfMoneyCOD] FOREIGN KEY ([IdTypeOfMoneyCOD]) REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id]),
    CONSTRAINT [FK_CostDetail_TypeOfMoneyCollect] FOREIGN KEY ([IdTypeOfMoneyCollect]) REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id]),
    CONSTRAINT [FKCostDetCost] FOREIGN KEY ([IdCost]) REFERENCES [dbo].[Cost] ([IdCost]),
    CONSTRAINT [FKCostDetTypeMoney] FOREIGN KEY ([IdTypeOfMoney]) REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id])
);














GO
CREATE NONCLUSTERED INDEX [idx_IdCost]
    ON [dbo].[CostDetail]([IdCost] ASC);


GO



GO
CREATE NONCLUSTERED INDEX [idx_idcost_amount_voucher]
    ON [dbo].[CostDetail]([IdCost] ASC, [Amount] ASC, [Voucher] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_Voucher]
    ON [dbo].[CostDetail]([Voucher] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ruta de almacenamiento del comprobante de transacción de entrega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CostDetail', @level2type = N'COLUMN', @level2name = N'VoucherPath';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de medio de pago de collect', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CostDetail', @level2type = N'COLUMN', @level2name = N'IdTypeOfMoneyCollect';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de medio de pago de COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CostDetail', @level2type = N'COLUMN', @level2name = N'IdTypeOfMoneyCOD';

