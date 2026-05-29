CREATE TABLE [dbo].[CreditCardTransactionByCustomerDetail] (
    [OrderNumber]         VARCHAR (50) NULL,
    [ProductNumber]       INT          NULL,
    [SerieNumber]         VARCHAR (2)  NULL,
    [IdTransactionDetail] INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    CONSTRAINT [PK_CreditCardTransactionByCustomerDetail] PRIMARY KEY CLUSTERED ([IdTransactionDetail] ASC)
);








GO
CREATE NONCLUSTERED INDEX [idx_OrderNumber]
    ON [dbo].[CreditCardTransactionByCustomerDetail]([OrderNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_ProductNumber_Include]
    ON [dbo].[CreditCardTransactionByCustomerDetail]([ProductNumber] ASC)
    INCLUDE([SerieNumber]);

