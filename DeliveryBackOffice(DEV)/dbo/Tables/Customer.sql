CREATE TABLE [dbo].[Customer] (
    [IdCustomer]              INT            IDENTITY (1, 1) NOT NULL,
    [Name]                    NVARCHAR (100) NOT NULL,
    [Description]             NVARCHAR (100) NULL,
    [Domain]                  NVARCHAR (50)  NOT NULL,
    [RegexSubject]            NVARCHAR (100) NOT NULL,
    [RegexEmail]              NVARCHAR (100) NOT NULL,
    [RegexFilename]           NVARCHAR (100) NOT NULL,
    [Abbreviation]            NVARCHAR (25)  NOT NULL,
    [IdCustomerType]          INT            NULL,
    [ConditionOfPaymentID]    INT            NULL,
    [CountryID]               VARCHAR (2)    NULL,
    [CommercialName]          NVARCHAR (50)  NULL,
    [CustomerPhone]           NVARCHAR (50)  NULL,
    [WebsiteURI]              NVARCHAR (50)  NULL,
    [ContactName]             NVARCHAR (50)  NULL,
    [ContactEmail]            NVARCHAR (50)  NULL,
    [NotificationAddress]     NVARCHAR (200) NULL,
    [SaleAdvisorID]           INT            NULL,
    [DateUpService]           DATETIME       NULL,
    [DateDownService]         DATETIME       NULL,
    [TypeOfBusinessID]        INT            NULL,
    [BusinessSegmentID]       INT            NULL,
    [BusinessActivityID]      INT            NULL,
    [CommercialSegmentID]     INT            NULL,
    [OperationContactName]    NVARCHAR (50)  NULL,
    [OperationContactPhone]   NVARCHAR (50)  NULL,
    [OperationContactEmail]   NVARCHAR (50)  NULL,
    [LegalSponsorName]        NVARCHAR (50)  NULL,
    [LegalSponsorLastName]    NVARCHAR (50)  NULL,
    [LegalSponsorDPI]         NVARCHAR (50)  NULL,
    [HasAgreement]            BIT            NULL,
    [AgreementNumber]         NVARCHAR (50)  NULL,
    [AgreementDateStart]      DATETIME       NULL,
    [AgreementDateEnd]        DATETIME       NULL,
    [InvoiceName]             NVARCHAR (100) NULL,
    [TaxIdentificationNumber] NVARCHAR (50)  NULL,
    [FiscalAddress]           NVARCHAR (200) NULL,
    [InvoiceEmail]            NVARCHAR (50)  NULL,
    [InvoiceContactName]      NVARCHAR (50)  NULL,
    [InvoiceContactPhone]     NVARCHAR (50)  NULL,
    [InvoiceContactEmail]     NVARCHAR (50)  NULL,
    [CODAccountBankID]        INT            NULL,
    [CODAccountNumber]        NVARCHAR (50)  NULL,
    [CODAccountName]          NVARCHAR (50)  NULL,
    [CODAccountTypeID]        INT            NULL,
    [CODCurrencyID]           INT            NULL,
    [CODContactName]          NVARCHAR (50)  NULL,
    [CODContactPhone]         NVARCHAR (50)  NULL,
    [CODContactEmail]         NVARCHAR (50)  NULL,
    [RowSatus]                BIT            NULL,
    [TokenCreated]            NVARCHAR (50)  NULL,
    [DateCreated]             DATETIME       NULL,
    [TokenUpdated]            NVARCHAR (50)  NULL,
    [DateUpdated]             DATETIME       NULL,
    [SAPCardCode]             NVARCHAR (50)  NULL,
    [ExcludePriceShippingCOD] BIT            NULL,
    [ExcludeCommissionCOD]    BIT            NULL,
    [CatBatchTypeCODId]       BIGINT         NULL,
    [CatBatchFrequencyCODId]  BIGINT         NULL,
    [DCBAID]                  INT            NULL,
    PRIMARY KEY CLUSTERED ([IdCustomer] ASC),
    CONSTRAINT [FK_Customer_CatBankAccountType2] FOREIGN KEY ([CODAccountTypeID]) REFERENCES [dbo].[CatBankAccountType] ([IdBankAccountType]),
    CONSTRAINT [FK_Customer_CatBusinessActivity2] FOREIGN KEY ([BusinessActivityID]) REFERENCES [dbo].[CatBusinessActivity] ([IdBusinessActivity]),
    CONSTRAINT [FK_Customer_CatBusinessSegment2] FOREIGN KEY ([BusinessSegmentID]) REFERENCES [dbo].[CatBusinessSegment] ([IdBusinessSegment]),
    CONSTRAINT [FK_Customer_CatCommercialSegment2] FOREIGN KEY ([CommercialSegmentID]) REFERENCES [dbo].[CatCommercialSegment] ([IdCommercialSegment]),
    CONSTRAINT [FK_Customer_CatConditionOfPayment2] FOREIGN KEY ([ConditionOfPaymentID]) REFERENCES [dbo].[CatConditionOfPayment] ([IdConditionOfPayment]),
    CONSTRAINT [FK_Customer_CatCountry2] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    CONSTRAINT [FK_Customer_CatSaleAdvisor2] FOREIGN KEY ([SaleAdvisorID]) REFERENCES [dbo].[CatSaleAdvisor] ([IdSaleAdvisor]),
    CONSTRAINT [FK_Customer_CatTypeOfBusiness2] FOREIGN KEY ([TypeOfBusinessID]) REFERENCES [dbo].[CatTypeOfBusiness] ([IdTypeOfBusiness]),
    CONSTRAINT [FK_Customer_CustomerType2] FOREIGN KEY ([IdCustomerType]) REFERENCES [dbo].[CustomerType] ([IdCustomerType]),
    CONSTRAINT [FK_Customer_DCBA] FOREIGN KEY ([DCBAID]) REFERENCES [dbo].[DeliveryCustomerBankAccount] ([DCBA_Id]),
    CONSTRAINT [FK_Customer_DeliveryBank2] FOREIGN KEY ([CODAccountBankID]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
    CONSTRAINT [FK_Customer_DeliveryCurrency2] FOREIGN KEY ([CODCurrencyID]) REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id para la tabla Customer ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer', @level2type = N'COLUMN', @level2name = N'IdCustomer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de la tabla CatBatchTypeCOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer', @level2type = N'COLUMN', @level2name = N'CatBatchTypeCODId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id para la tabla CatBatchFrequencyCOD ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer', @level2type = N'COLUMN', @level2name = N'CatBatchFrequencyCODId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referencia al identificador de la tabla DeliveryCustomerBankAccount.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer', @level2type = N'COLUMN', @level2name = N'DCBAID';

