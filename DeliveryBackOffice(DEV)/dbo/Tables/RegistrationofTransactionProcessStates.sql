CREATE TABLE [dbo].[RegistrationofTransactionProcessStates] (
    [IdRegistrationofTransactionProcessStates] INT             IDENTITY (1, 1) NOT NULL,
    [AccountId]                                INT             NULL,
    [CustomerId]                               INT             NULL,
    [OrderNumber]                              NVARCHAR (50)   NOT NULL,
    [NameTax]                                  NVARCHAR (250)  NULL,
    [AddressTax]                               NVARCHAR (1000) NULL,
    [TaxId]                                    NVARCHAR (50)   NULL,
    [IsSuscription]                            BIT             NOT NULL,
    [GetRenovacionAutomatica]                  BIT             NOT NULL,
    [GetCardsCredit]                           INT             NOT NULL,
    [TokenCreated]                             NVARCHAR (50)   NOT NULL,
    [DateCreated]                              DATETIME        NOT NULL,
    [TokenUpdate]                              NVARCHAR (50)   NULL,
    [DateUpdate]                               DATETIME        NULL,
    [IdSalePackage]                            INT             NULL,
    [TypeSalePackage]                          NVARCHAR (25)   NULL,
    [Vaucher]                                  NVARCHAR (25)   NULL,
    [InvoiceEmail]                             NVARCHAR (50)   NULL,
    [ProductGiftShippingEmail]                 NVARCHAR (50)   NULL,
    [PaymentImageURL]                          NVARCHAR (600)  NULL,
    CONSTRAINT [PK_RegistrationofTransactionProcessStates] PRIMARY KEY CLUSTERED ([IdRegistrationofTransactionProcessStates] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'obtener últimos digitos de la tarjeta con la que se ejecuta el pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegistrationofTransactionProcessStates', @level2type = N'COLUMN', @level2name = N'GetCardsCredit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'indica si se requiere que el plan adquirido sea autorenobable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegistrationofTransactionProcessStates', @level2type = N'COLUMN', @level2name = N'GetRenovacionAutomatica';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si se esta adquiriendo una membresía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegistrationofTransactionProcessStates', @level2type = N'COLUMN', @level2name = N'IsSuscription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NIT de factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegistrationofTransactionProcessStates', @level2type = N'COLUMN', @level2name = N'TaxId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'dirección para facturar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegistrationofTransactionProcessStates', @level2type = N'COLUMN', @level2name = N'AddressTax';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nombre para facturar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegistrationofTransactionProcessStates', @level2type = N'COLUMN', @level2name = N'NameTax';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'el numero de orden esta compuesto por las iniciales MP que indican membership payment seguid de ceros y el nùmero de la susripciòn o memrbesìa adquirida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegistrationofTransactionProcessStates', @level2type = N'COLUMN', @level2name = N'OrderNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegistrationofTransactionProcessStates', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identioficador de cuenta de usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegistrationofTransactionProcessStates', @level2type = N'COLUMN', @level2name = N'AccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tabla para guardar los datos de un proceso de pago, asociación y certificación de factura de ser fallido permitir retomarlo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegistrationofTransactionProcessStates', @level2type = N'COLUMN', @level2name = N'IdRegistrationofTransactionProcessStates';

