CREATE TABLE [dbo].[RateEstimate] (
    [IdRateEstimated]       BIGINT          IDENTITY (1, 1) NOT NULL,
    [IdSource]              BIGINT          NULL,
    [IdDestiny]             BIGINT          NULL,
    [ObjectType]            NVARCHAR (50)   NULL,
    [CountPieces]           INT             NULL,
    [UnitValue]             DECIMAL (5, 2)  NULL,
    [IdUnit]                INT             NULL,
    [CodeCredit]            NVARCHAR (10)   NULL,
    [IdRate]                INT             NULL,
    [BaseRate]              DECIMAL (18, 2) NULL,
    [EstimateTotalAmount]   DECIMAL (18, 2) NULL,
    [IdCustomer]            INT             NULL,
    [IdEcommerce]           INT             NULL,
    [DateService]           DATETIME        NULL,
    [EstimatedStatus]       BIT             NULL,
    [TokenCreated]          NVARCHAR (50)   NULL,
    [DateCreated]           DATETIME        NULL,
    [TokenUpdated]          NVARCHAR (50)   NULL,
    [DateUpdated]           DATETIME        NULL,
    [DateEcommerceSale]     DATETIME        NULL,
    [DateEcommercePickUp]   DATETIME        NULL,
    [DateCarrierDelivery]   DATETIME        NULL,
    [IdCurrency]            INT             NULL,
    [IdCountry]             NVARCHAR (2)    NULL,
    [IdRateCategory]        INT             NULL,
    [RatePlanDescription]   NVARCHAR (50)   NULL,
    [EcomValueAmmount]      DECIMAL (18, 2) NULL,
    [EcomValueCurrency]     NVARCHAR (3)    NULL,
    [EcomValueRateExchange] MONEY           NULL,
    [IdTownshipSource]      INT             NULL,
    [IdTownshipDestiny]     INT             NULL,
    CONSTRAINT [PK_RateEstimate] PRIMARY KEY CLUSTERED ([IdRateEstimated] ASC),
    CONSTRAINT [FK_RateEstimate_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_RateEstimate_Ecommerce] FOREIGN KEY ([IdEcommerce]) REFERENCES [dbo].[Ecommerce] ([IdEcommerce]),
    CONSTRAINT [FK_RateEstimate_RateCategory] FOREIGN KEY ([IdRateCategory]) REFERENCES [dbo].[RateCategory] ([IdRateCategory]),
    CONSTRAINT [FK_RateEstimate_Settlement] FOREIGN KEY ([IdDestiny]) REFERENCES [dbo].[Settlement] ([IdSettlement]),
    CONSTRAINT [FKRateTwonshipDestiny] FOREIGN KEY ([IdTownshipDestiny]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FKRateTwonshipSource] FOREIGN KEY ([IdTownshipSource]) REFERENCES [dbo].[Township] ([IdTownship])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description of the object to Transport', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateEstimate', @level2type = N'COLUMN', @level2name = N'ObjectType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Value of Unit Mass Lbs Weight', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateEstimate', @level2type = N'COLUMN', @level2name = N'UnitValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mass Lbs', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateEstimate', @level2type = N'COLUMN', @level2name = N'IdUnit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'date when created the estimate rate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateEstimate', @level2type = N'COLUMN', @level2name = N'DateService';

