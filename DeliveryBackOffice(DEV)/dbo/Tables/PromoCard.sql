CREATE TABLE [dbo].[PromoCard] (
    [IdPromoCard]       INT             IDENTITY (1, 1) NOT NULL,
    [PromoCardNumber]   VARCHAR (50)    NOT NULL,
    [PromoCardName]     VARCHAR (100)   NOT NULL,
    [CustomerId]        INT             NULL,
    [RedeemTypeId]      INT             NULL,
    [AcumulationTypeId] INT             NULL,
    [ClientPortfolioId] BIGINT          NULL,
    [Balance]           DECIMAL (12, 2) NULL,
    [RowStatus]         BIT             NOT NULL,
    [TokenCreated]      VARCHAR (50)    NOT NULL,
    [DateCreated]       DATETIME        NOT NULL,
    [TokenUpdated]      VARCHAR (50)    NULL,
    [DateUpdated]       DATETIME        NULL,
    [CurrencyId]        INT             NULL,
    PRIMARY KEY CLUSTERED ([IdPromoCard] ASC),
    CONSTRAINT [FKAcumularionPromo] FOREIGN KEY ([AcumulationTypeId]) REFERENCES [dbo].[AcumulationPointType] ([IdAcumulationPoint]),
    CONSTRAINT [FKCustomerPromo] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[CustomerParser] ([IdCustomer]),
    CONSTRAINT [FKPromoCurrency] FOREIGN KEY ([CurrencyId]) REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id]),
    CONSTRAINT [FKRedeemPromo] FOREIGN KEY ([RedeemTypeId]) REFERENCES [dbo].[RedeemType] ([IdRedeem]),
    UNIQUE NONCLUSTERED ([PromoCardNumber] ASC)
);

