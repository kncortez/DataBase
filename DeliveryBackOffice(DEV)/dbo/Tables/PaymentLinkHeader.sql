CREATE TABLE [dbo].[PaymentLinkHeader] (
    [IdPaymentLinkHeader] INT            IDENTITY (1, 1) NOT NULL,
    [PaymentLink]         NVARCHAR (MAX) NOT NULL,
    [PaymentLinkStatus]   NVARCHAR (20)  NOT NULL,
    [PaymentLinkTitle]    NVARCHAR (50)  NULL,
    [AuthorizationNumber] NVARCHAR (200) NULL,
    [AuthorizationDate]   DATETIME       NULL,
    [PaymentLinkRequest]  NVARCHAR (MAX) NOT NULL,
    [PaymentLinkRespose]  NVARCHAR (MAX) NOT NULL,
    [CustomerId]          INT            NULL,
    [RowStatus]           BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]        NVARCHAR (50)  NOT NULL,
    [DateCreated]         DATETIME       NOT NULL,
    [TokenUpdated]        NVARCHAR (50)  NULL,
    [DateUpdated]         DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdPaymentLinkHeader] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de cliente de la tabla Customer.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Respuesta de proveedor de la creación de link de pago.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'PaymentLinkRespose';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Petición realizada a proveedor para generar link de pago.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'PaymentLinkRequest';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de autorización de pago de link.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'AuthorizationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Autorización de link representando exitosamente su pago.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'AuthorizationNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la transacción de pago con link.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'PaymentLinkTitle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado registrado de link de pago.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'PaymentLinkStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Link generado por proveedor para realizar el pago de servicios.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'PaymentLink';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader', @level2type = N'COLUMN', @level2name = N'IdPaymentLinkHeader';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Encabezado de pagos con link.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkHeader';

