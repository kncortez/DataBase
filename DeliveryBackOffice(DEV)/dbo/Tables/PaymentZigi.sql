CREATE TABLE [dbo].[PaymentZigi] (
    [ZigiPaymentId]             INT             IDENTITY (1, 1) NOT NULL,
    [GuideNumber]               INT             NOT NULL,
    [GuideSerie]                NVARCHAR (2)    NOT NULL,
    [ZigiLinkStatus]            NVARCHAR (20)   NOT NULL,
    [ZigiLink]                  NVARCHAR (MAX)  NULL,
    [ZigiTransactionId]         NVARCHAR (100)  NULL,
    [ZigiReference]             NVARCHAR (100)  NULL,
    [ZigiPaymentLinkId]         NVARCHAR (100)  NULL,
    [PaidAmount]                DECIMAL (10, 2) NULL,
    [CollectValue]              DECIMAL (10, 2) NULL,
    [CODValue]                  DECIMAL (10, 2) NULL,
    [PaymentId]                 NVARCHAR (100)  NULL,
    [DateTimeStamp]             DATETIME        NULL,
    [RowStatus]                 BIT             CONSTRAINT [DF_PaymentZigi_RowStatus] DEFAULT ((1)) NOT NULL,
    [DateCreated]               DATETIME        NOT NULL,
    [TokenCreated]              NVARCHAR (50)   NOT NULL,
    [DateUpdated]               DATETIME        NULL,
    [TokenUpdated]              NVARCHAR (50)   NULL,
    [AuthorizationNumberByUser] NVARCHAR (100)  NULL,
    [LinkRequestSent]           BIT             CONSTRAINT [DF_PaymentZigi_LinkRequestSent] DEFAULT ((0)) NOT NULL,
    [PaymentConfirmSent]        BIT             CONSTRAINT [DF_PaymentZigi_PaymentConfirmSent] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PaymentZigi] PRIMARY KEY CLUSTERED ([ZigiPaymentId] ASC),
    CONSTRAINT [FK_PaymentZigi_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);


GO
CREATE NONCLUSTERED INDEX [IX_PaymentZigi_GuideSerie_GuideNumber_ZigiReference]
    ON [dbo].[PaymentZigi]([GuideSerie] ASC, [GuideNumber] ASC, [ZigiReference] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de autorizacion de pago brindado por cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'AuthorizationNumberByUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que actualizó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de la última modificación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado (1 Activo, 0 inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la que cambio el estado del link', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'DateTimeStamp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de pago realizado con link', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'PaymentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor COD correspondiente al pedido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'CODValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor a recaudar asociado al envío.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'CollectValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto pagado a través del enlace de Zigi.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'PaidAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del enlace de pago generado en Zigi.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'ZigiPaymentLinkId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referencia generada el pago en Zigi. Forma parte del link', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'ZigiReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la transacción proporcionado por Zigi(AuthorizationCode)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'ZigiTransactionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Enlace de pago generado por la plataforma Zigi.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'ZigiLink';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del vínculo generado por Zigi (ej. pendiente, pagado, expirado).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'ZigiLinkStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía asociada al pago.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía asociado al pago.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del registro de pago en Zigi.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'ZigiPaymentId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si se envió el WhatsApp para solicitar el link de Zigi (1=Enviado, 0=No enviado).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'LinkRequestSent';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si se envió el WhatsApp de confirmación de pago de Zigi (1=Enviado, 0=No enviado).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'PaymentConfirmSent';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registro de pagos realizados a través de la plataforma Zigi.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador unico proporcionado por Zigi para diferenciar el usuario que hace el pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'ZigiBuyerId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de cuenta bancaria donde Zigi relaciona el pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigi', @level2type = N'COLUMN', @level2name = N'ZigiBankAccount';