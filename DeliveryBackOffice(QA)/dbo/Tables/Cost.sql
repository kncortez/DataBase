CREATE TABLE [dbo].[Cost] (
    [IdCost]          INT             IDENTITY (1, 1) NOT NULL,
    [IdProduct]       INT             NULL,
    [ProductNumber]   VARCHAR (100)   NULL,
    [IdTypeCharge]    INT             NULL,
    [TotalAmount]     DECIMAL (18, 2) NULL,
    [PaymentDate]     DATETIME        NULL,
    [IdModule]        INT             NULL,
    [RowStatus]       BIT             NULL,
    [TokenCreated]    VARCHAR (50)    NOT NULL,
    [DateCreated]     DATETIME        NOT NULL,
    [TokenUpdated]    VARCHAR (50)    NULL,
    [DateUpdated]     DATETIME        NULL,
    [TotalAmountPaid] DECIMAL (12, 2) NULL,
    [CODAmount]       DECIMAL (12, 2) NULL,
    [ReturnAmount]    DECIMAL (12, 2) NULL,
    [ReturnPaid]      DECIMAL (12, 2) NULL,
    PRIMARY KEY CLUSTERED ([IdCost] ASC),
    CONSTRAINT [FKCostCharge] FOREIGN KEY ([IdTypeCharge]) REFERENCES [dbo].[CatTypeCharge] ([IdTypeCharge]),
    CONSTRAINT [FKCostModule] FOREIGN KEY ([IdModule]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FKCostProduct] FOREIGN KEY ([IdProduct]) REFERENCES [dbo].[CatTypeProduct] ([IdTypeProduct])
);




GO
CREATE NONCLUSTERED INDEX [IDX_product_number_cost]
    ON [dbo].[Cost]([IdProduct] ASC, [ProductNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_ProductNumber]
    ON [dbo].[Cost]([ProductNumber] ASC)
    INCLUDE([TotalAmountPaid], [CODAmount]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor que se debe pagar por devolución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'ReturnAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor que se debe pagar por devolución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Cost', @level2type = N'COLUMN', @level2name = N'ReturnPaid';


GO
CREATE NONCLUSTERED INDEX [IDX_RowStatus]
    ON [dbo].[Cost]([RowStatus] ASC)
    INCLUDE([ProductNumber], [TotalAmountPaid], [CODAmount]);

