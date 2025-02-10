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
    [CatTMSalesPersonId]      INT            NULL,
    [CutOffDate]              DATETIME       NULL,
    [UpgradeDate]             DATETIME       NULL,
    [CustomerGoalQuantity]    INT            NULL,
    [CatBillingTimeId]        INT            NULL,
    [CatBillingVolumeId]      INT            NULL,
    [BillingCut_offDate]      DATE           NULL,
    [NumImgEvidence]          INT            NULL,
    [IsCOD]                   INT            NULL,
    [IsVoucherRequired]       INT            NULL,
    CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED ([IdCustomer] ASC),
    CONSTRAINT [FK_Customer_CatBankAccountType] FOREIGN KEY ([CODAccountTypeID]) REFERENCES [dbo].[CatBankAccountType] ([IdBankAccountType]),
    CONSTRAINT [FK_Customer_CatBillingTime] FOREIGN KEY ([CatBillingTimeId]) REFERENCES [dbo].[CatBillingTime] ([IdCatBillingTime]),
    CONSTRAINT [FK_Customer_CatBillingVolume] FOREIGN KEY ([CatBillingVolumeId]) REFERENCES [dbo].[CatBillingVolume] ([IdCatBillingVolume]),
    CONSTRAINT [FK_Customer_CatBusinessActivity] FOREIGN KEY ([BusinessActivityID]) REFERENCES [dbo].[CatBusinessActivity] ([IdBusinessActivity]),
    CONSTRAINT [FK_Customer_CatBusinessSegment] FOREIGN KEY ([BusinessSegmentID]) REFERENCES [dbo].[CatBusinessSegment] ([IdBusinessSegment]),
    CONSTRAINT [FK_Customer_CatCommercialSegment] FOREIGN KEY ([CommercialSegmentID]) REFERENCES [dbo].[CatCommercialSegment] ([IdCommercialSegment]),
    CONSTRAINT [FK_Customer_CatConditionOfPayment] FOREIGN KEY ([ConditionOfPaymentID]) REFERENCES [dbo].[CatConditionOfPayment] ([IdConditionOfPayment]),
    CONSTRAINT [FK_Customer_CatCountry] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    CONSTRAINT [FK_Customer_CatSaleAdvisor] FOREIGN KEY ([SaleAdvisorID]) REFERENCES [dbo].[CatSaleAdvisor] ([IdSaleAdvisor]),
    CONSTRAINT [FK_Customer_CatTMSalesPerson] FOREIGN KEY ([CatTMSalesPersonId]) REFERENCES [dbo].[CatTMSalesPerson] ([IdCatTMSalesPerson]),
    CONSTRAINT [FK_Customer_CatTypeOfBusiness] FOREIGN KEY ([TypeOfBusinessID]) REFERENCES [dbo].[CatTypeOfBusiness] ([IdTypeOfBusiness]),
    CONSTRAINT [FK_Customer_CustomerType] FOREIGN KEY ([IdCustomerType]) REFERENCES [dbo].[CustomerType] ([IdCustomerType]),
    CONSTRAINT [FK_Customer_DeliveryBank] FOREIGN KEY ([CODAccountBankID]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
    CONSTRAINT [FK_Customer_DeliveryCurrency] FOREIGN KEY ([CODCurrencyID]) REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id])
);


GO
CREATE NONCLUSTERED INDEX [idx_IdCustomerType_RowSatus]
ON [dbo].[Customer]([IdCustomerType] ASC, [RowSatus] ASC)
INCLUDE([Name], [ConditionOfPaymentID], [CustomerPhone], [ContactEmail], [InvoiceName], [TaxIdentificationNumber], [FiscalAddress], [InvoiceEmail], [CODAccountBankID], [CODAccountNumber], [CODAccountName], [CODAccountTypeID]);

GO
CREATE NONCLUSTERED INDEX [IDX_Customer_CODContactEmail]
ON [dbo].[Customer]([CODContactEmail] ASC, [RegexEmail] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_idCustomer_sphdGetCustomer]
    ON [dbo].[Customer]([IdCustomerType] ASC)
    INCLUDE([Name], [Abbreviation], [CountryID], [RowSatus], [SAPCardCode]);

GO
CREATE NONCLUSTERED INDEX [IDX_Customer_IVR_A]
    ON [dbo].[Customer]([IsVoucherRequired] ASC, [Abbreviation] ASC);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id para la tabla Customer ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'IdCustomer'
GO


EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'Name'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion que complementa el nombre del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'Description'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado que indica si el cliente esta autorizado para guías COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'IsCOD'
GO


EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Es el dominio que utiliza el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'Domain'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Expresion regular para la solicitud del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'RegexSubject'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Expresion regular para el correo del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'RegexEmail'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Expresion regular para nombre del archivo del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'RegexFilename'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Abreviatura del nombre del cliente con el que se identifica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'Abbreviation'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de cliente segun clasificatoria interna de Forza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'IdCustomerType'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de condicion de pago que tiene el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'ConditionOfPaymentID'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Ciudad a la que pertenece el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CountryID'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre comercial del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CommercialName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Telefono del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CustomerPhone'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Sitio web del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'WebsiteURI'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del contacto que se tiene del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'ContactName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Correo de contacto que se tiene del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'ContactEmail'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Direccion del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'NotificationAddress'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Asesor de venta del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'SaleAdvisorID'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en que se levanta el servicio para el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'DateUpService'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en que se baja el servicio para el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'DateDownService'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de negocio al que pertenece el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'TypeOfBusinessID'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Segmento de negocio al que pertenece el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'BusinessSegmentID'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Actividad que realiza el negocio del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'BusinessActivityID'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Segmento cormercial o mercado objetivo del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CommercialSegmentID'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del contacto de operaciones del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'OperationContactName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Telefono del contacto de operaciones del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'OperationContactPhone'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Correo electronico del contacto de operaciones del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'OperationContactEmail'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de la persona que asume la responsabilidad legal del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'LegalSponsorName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Apellido de la persona que asume la responsabilidad legal del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'LegalSponsorLastName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Documento de identificacion personal de la persona que asume la responsabilidad legal del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'LegalSponsorDPI'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Campo que indica si el cliente tiene o no acuerdos con la empresa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'HasAgreement'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de acuerdo que se tiene con el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'AgreementNumber'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de inicio del acuerdo que se tiene con el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'AgreementDateStart'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de finalizacion del acuerdo que se tiene con el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'AgreementDateEnd'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre que se le asigna a la factura del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'InvoiceName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de identificacion fiscal del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'TaxIdentificationNumber'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Direccion fiscal del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'FiscalAddress'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Correo electronico de facturacion del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'InvoiceEmail'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del contacto de facturacion del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'InvoiceContactName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Telefono del contacto de facturacion del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'InvoiceContactPhone'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Correo electronico del contacto de facturacion del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'InvoiceContactEmail'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Banco al que pertenece la cuenta del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODAccountBankID'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de cuenta de banco del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODAccountNumber'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de la cuenta de banco del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODAccountName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de cuenta de banco del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODAccountTypeID'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Moneda que maneja el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODCurrencyID'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del contacto de COD del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODContactName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Telefono del contacto de COD del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODContactPhone'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Correo electronico del contacto de COD del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODContactEmail'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila habilitado o deshabilitado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'RowSatus'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creacion de la fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creacion de la fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizacion de la fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion de la fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de tarjeta de SAP asociado al cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'SAPCardCode'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Bandera para indicar si se excluye el precio de envio.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'ExcludePriceShippingCOD'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Bandera para indicar si se excluye la comision.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'ExcludeCommissionCOD'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Id de la tabla CatBatchTypeCOD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CatBatchTypeCODId'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Id para la tabla CatBatchFrequencyCOD ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CatBatchFrequencyCODId'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del vendedor de telemercadeo asociado al cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CatTMSalesPersonId'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de corte para los clientes de tipo PYMES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CutOffDate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización de tipo de cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'UpgradeDate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Meta de envíos para cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CustomerGoalQuantity'
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de el tiempo en que se requiere la facturación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer', @level2type = N'COLUMN', @level2name = N'CatBillingTimeId';


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador que indica volumen de facturación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer', @level2type = N'COLUMN', @level2name = N'CatBillingVolumeId';


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fechad e corte de facturación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Customer', @level2type = N'COLUMN', @level2name = N'BillingCut_offDate';


GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Almacenar cantidad de imagenes de evidencias permitidas' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'NumImgEvidence'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identifica si con el cliente desplegara o no constancia de Entrega' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'IsVoucherRequired'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'La tabla Cliente almacena informacon relacionada con los clientes de la empresa Forza Delivery' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer'
GO


