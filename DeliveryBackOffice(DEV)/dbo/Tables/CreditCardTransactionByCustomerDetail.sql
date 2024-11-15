CREATE TABLE [dbo].[CreditCardTransactionByCustomerDetail] (
    [OrderNumber]   VARCHAR (50) NULL,
    [ProductNumber] INT          NULL,
    [SerieNumber]   VARCHAR (2)  NULL
);




GO
CREATE NONCLUSTERED INDEX [idx_OrderNumber]
    ON [dbo].[CreditCardTransactionByCustomerDetail]([OrderNumber] ASC);

