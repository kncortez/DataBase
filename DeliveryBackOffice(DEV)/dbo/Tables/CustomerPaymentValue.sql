CREATE TABLE [dbo].[CustomerPaymentValue] (
    [IdCustomerPaymentValue]  INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [AccountId]               BIGINT         NULL,
    [CustomerId]              INT            NOT NULL,
    [VisitPointId]            INT            NULL,
    [TokenizedToken]          NVARCHAR (100) NOT NULL,
    [TokenizedExpirationDate] NVARCHAR (50)  NOT NULL,
    [TokenizedCVV]            NVARCHAR (50)  NOT NULL,
    [DisplayText]             NVARCHAR (25)  NOT NULL,
    [IsDefault]               BIT            CONSTRAINT [DF_CustomerPaymentValue_IsDefault] DEFAULT ((0)) NOT NULL,
    [Type]                    NVARCHAR (2)   NOT NULL,
    [RowStatus]               BIT            CONSTRAINT [DF_CustomerPaymentValue_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]            NVARCHAR (50)  NOT NULL,
    [DateCreated]             DATETIME       NOT NULL,
    [TokenUpdated]            NVARCHAR (50)  NULL,
    [DateUpdated]             DATETIME       NULL,
    [Holder]                  NVARCHAR (50)  NULL,
    [FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[Nirphone] [nvarchar](5) NULL,
	[Address] [nvarchar](150) NULL,
	[Phone] [nvarchar](15) NULL,
	[IsoCode] [nvarchar](3) NULL,
	[PaymentGateway] [nvarchar](25) NULL,
    CONSTRAINT [PK_CustomerPaymentValue] PRIMARY KEY CLUSTERED ([IdCustomerPaymentValue] ASC),
    CONSTRAINT [FK_CustomerPaymentValue_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_CustomerPaymentValue_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_CustomerPaymentValue_VisitPointClient] FOREIGN KEY ([VisitPointId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre titular', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'Holder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de actualización de la tarjeta de crédito/débito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de modificación de la tarjeta de crédito/débito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de creación de la tarjeta de crédito/débito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de la tarjeta de crédito/débito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la tarjeta de crédito/débito 1=ACTIVA 0=ELIMINADA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'El tipo de tarjeta V: Visa; A, American Express, C: Master Card', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'Type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si es la tarjeta de crédito/débito por defecto del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'IsDefault';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cómo si visualiza el número de tarjeta de crédito/débito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'DisplayText';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de CVV de tarjeta de crédito/débito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'TokenizedCVV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de fecha de expiración de tarjeta de crédito/débito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'TokenizedExpirationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de la tarjeta de crédito/débito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'TokenizedToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CodeOfReference de la tabla VisitpointClient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'VisitPointId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de la tabla Customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de la tabla Account', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerPaymentValue', @level2type = N'COLUMN', @level2name = N'AccountId';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de tarjeta para pasarela de pago PayWayOne' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'FirstName'

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Apellido de tarjeta para pasarela de pago PayWayOne' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'LastName'

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Area de teléfono  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'Nirphone'

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Dirección para campo obligatorio de pasarela de pago ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'Address'

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Teléfono de tarjeta de crédito' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'Phone'

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'código de país ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'IsoCode'

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Pasarela de pago que se útiliza ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'PaymentGateway'

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar datos de TC de clientes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue'






