CREATE TABLE [dbo].[CreditCardTransactionByCustomerDetail] (
    [OrderNumber]   VARCHAR (50) NULL,
    [ProductNumber] INT          NULL,
    [SerieNumber]   VARCHAR (2)  NULL
);




GO
CREATE NONCLUSTERED INDEX [IX_CreditCardTransactionByCustomerDetail_ProductSerie]
    ON [dbo].[CreditCardTransactionByCustomerDetail]([ProductNumber] ASC, [SerieNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CreditCardTransactionByCustomerDetail_OrderNumber]
    ON [dbo].[CreditCardTransactionByCustomerDetail]([OrderNumber] ASC);

