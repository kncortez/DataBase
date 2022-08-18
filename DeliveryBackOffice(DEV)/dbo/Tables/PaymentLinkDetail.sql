CREATE TABLE [dbo].[PaymentLinkDetail] (
    [IdPaymentLinkDetail]   INT             IDENTITY (1, 1) NOT NULL,
    [PaymentLinkHeaderId]   INT             NOT NULL,
    [GuideSerie]            NVARCHAR (2)    NOT NULL,
    [GuideNumber]           INT             NOT NULL,
    [GuideTotalFinalAmount] DECIMAL (18, 2) NOT NULL,
    [RowStatus]             BIT             DEFAULT ((1)) NOT NULL,
    [TokenCreated]          NVARCHAR (50)   NOT NULL,
    [DateCreated]           DATETIME        NOT NULL,
    [TokenUpdated]          NVARCHAR (50)   NULL,
    [DateUpdated]           DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdPaymentLinkDetail] ASC),
    CONSTRAINT [FK_PaymentLinkDetail_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_PaymentLinkDetail_PaymentLinkHeader] FOREIGN KEY ([PaymentLinkHeaderId]) REFERENCES [dbo].[PaymentLinkHeader] ([IdPaymentLinkHeader]),
    UNIQUE NONCLUSTERED ([GuideSerie] ASC, [GuideNumber] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto final de la guía posterior a aplicar el recargo por pagar con link.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkDetail', @level2type = N'COLUMN', @level2name = N'GuideTotalFinalAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía asociada al pago con link de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía asociada al pago con link de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Encabezado de link de pago.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkDetail', @level2type = N'COLUMN', @level2name = N'PaymentLinkHeaderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkDetail', @level2type = N'COLUMN', @level2name = N'IdPaymentLinkDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Detalle de servicios relacionados a un pago con link.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentLinkDetail';

