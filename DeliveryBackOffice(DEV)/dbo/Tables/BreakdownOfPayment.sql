CREATE TABLE [dbo].[BreakdownOfPayment] (
    [IdBreakdownOfPayment]     INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [IdCost]                   INT             NULL,
    [Description]              VARCHAR (100)   NULL,
    [Amount]                   DECIMAL (18, 2) NULL,
    [ModIdModule]              INT             NULL,
    [RowStatus]                BIT             NULL,
    [TokenCreated]             VARCHAR (50)    NOT NULL,
    [DateCreated]              DATETIME        NOT NULL,
    [TokenUpdated]             VARCHAR (50)    NULL,
    [DateUpdated]              DATETIME        NULL,
    [PromoCouponId]            INT             NULL,
    [BreakdownOfPaymentTypeId] INT             NULL,
    PRIMARY KEY CLUSTERED ([IdBreakdownOfPayment] ASC),
    CONSTRAINT [FK_BreakdownOfPayment_PromoCoupon] FOREIGN KEY ([PromoCouponId]) REFERENCES [dbo].[PromoCoupon] ([IdPromoCoupon]),
    CONSTRAINT [FK_BreakdownOfPaymentTypeId_TypeId] FOREIGN KEY ([BreakdownOfPaymentTypeId]) REFERENCES [dbo].[CatBreakdownOfPaymentType] ([IdCatBreakdownOfPaymentType]),
    CONSTRAINT [FKCost] FOREIGN KEY ([IdCost]) REFERENCES [dbo].[Cost] ([IdCost]),
    CONSTRAINT [FKCostDetCatModule] FOREIGN KEY ([ModIdModule]) REFERENCES [dbo].[CatModule] ([ModIdModule])
);














GO
CREATE NONCLUSTERED INDEX [IDX_product_description]
    ON [dbo].[BreakdownOfPayment]([IdCost] ASC, [Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cupón, si el registro estuviese relacionado a un descuento por cupón.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BreakdownOfPayment', @level2type = N'COLUMN', @level2name = N'PromoCouponId';




GO



GO
CREATE NONCLUSTERED INDEX [idx_IdCost_RowStatus_Amount]
    ON [dbo].[BreakdownOfPayment]([IdCost] ASC, [RowStatus] ASC, [Amount] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de detalle de la tabla CatBreakdownOfPaymentType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BreakdownOfPayment', @level2type = N'COLUMN', @level2name = N'BreakdownOfPaymentTypeId';


GO
CREATE NONCLUSTERED INDEX [idx_IdCost]
    ON [dbo].[BreakdownOfPayment]([IdCost] ASC);


GO
