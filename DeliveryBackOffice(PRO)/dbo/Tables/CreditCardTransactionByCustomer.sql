CREATE TABLE [dbo].[CreditCardTransactionByCustomer] (
    [IdTransaction]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [System]               INT             NOT NULL,
    [CardNumber]           NVARCHAR (50)   NOT NULL,
    [TypeCardNumber]       NVARCHAR (5)    NOT NULL,
    [Currency]             INT             NOT NULL,
    [Ammount]              DECIMAL (18, 2) NULL,
    [OrderNumber]          NVARCHAR (38)   NOT NULL,
    [Signature]            NVARCHAR (100)  NULL,
    [CustomerReference]    INT             NOT NULL,
    [ReferenceNumber]      VARCHAR (50)    NOT NULL,
    [ECIIndicator]         VARCHAR (2)     NOT NULL,
    [Authenticationresult] VARCHAR (1)     NOT NULL,
    [TransactionStain]     VARCHAR (50)    NOT NULL,
    [CAVV]                 NVARCHAR (50)   NOT NULL,
    [ReasonCode]           NVARCHAR (50)   NULL,
    [ReasonDescription]    NVARCHAR (100)  NULL,
    [StatusSend]           INT             NULL,
    [RowStatus]            BIT             NOT NULL,
    [TokenCreated]         NVARCHAR (50)   NOT NULL,
    [DateCreated]          DATETIME        NOT NULL,
    [TokenUpdated]         NVARCHAR (50)   NULL,
    [DateUpdated]          DATETIME        NULL,
    [Token]                NVARCHAR (50)   NULL,
    CONSTRAINT [PK_CreditCardTransactionByCustomer] PRIMARY KEY CLUSTERED ([IdTransaction] ASC),
    FOREIGN KEY ([CustomerReference]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    FOREIGN KEY ([CustomerReference]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    FOREIGN KEY ([System]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    FOREIGN KEY ([System]) REFERENCES [dbo].[CatSystem] ([SysIdSystem])
);


GO
CREATE NONCLUSTERED INDEX [idx_OrderNumber]
    ON [dbo].[CreditCardTransactionByCustomer]([OrderNumber] ASC);

