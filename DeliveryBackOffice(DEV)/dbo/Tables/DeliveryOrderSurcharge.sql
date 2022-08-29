CREATE TABLE [dbo].[DeliveryOrderSurcharge] (
    [IdDeliveryOrderSurcharge]         INT             IDENTITY (1, 1) NOT NULL,
    [GuideSerie]                       NVARCHAR (2)    NOT NULL,
    [GuideNumber]                      INT             NOT NULL,
    [GuideOriginalPriceShipment]       DECIMAL (14, 2) NOT NULL,
    [GuideOriginalCollectOnDelivery]   DECIMAL (14, 2) NOT NULL,
    [TotalSurcharge]                   DECIMAL (14, 2) NOT NULL,
    [InternalSurchargeAmount]          DECIMAL (14, 2) NOT NULL,
    [ExternalSurchargeAmount]          DECIMAL (14, 2) NOT NULL,
    [GuideSurchargedShipment]          DECIMAL (14, 2) NOT NULL,
    [GuideSurchargedCollectOnDelivery] DECIMAL (14, 2) NOT NULL,
    [GuidePaymentLink]                 INT             NULL,
    [RowStatus]                        BIT             CONSTRAINT [DF_DeliveryOrderSurcharge_RowStatus] DEFAULT ((1)) NOT NULL,
    [DateCreated]                      DATETIME        NOT NULL,
    [TokenCreated]                     NVARCHAR (50)   NOT NULL,
    [DateUpdated]                      DATETIME        NULL,
    [TokenUpdated]                     NVARCHAR (50)   NULL,
    CONSTRAINT [PK_DeliveryOrderSurcharge] PRIMARY KEY CLUSTERED ([IdDeliveryOrderSurcharge] ASC),
    CONSTRAINT [FK_DeliveryOrderSurcharge_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_DeliveryOrderSurcharge_PaymentLinkHeader] FOREIGN KEY ([GuidePaymentLink]) REFERENCES [dbo].[PaymentLinkHeader] ([IdPaymentLinkHeader])
);


GO
CREATE NONCLUSTERED INDEX [IX_DeliveryOrderSurcharge]
    ON [dbo].[DeliveryOrderSurcharge]([GuideSerie] ASC, [GuideNumber] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creo la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foranea de la tabla PaymentLinkHeader', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'GuidePaymentLink';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'COD con el recargo aplicado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'GuideSurchargedCollectOnDelivery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio de la guía con el recargo aplicado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'GuideSurchargedShipment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Recargo para VisaOnLink 2.5%', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'ExternalSurchargeAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Recargo que queda interno 2.5%', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'InternalSurchargeAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Recargo total por pago por VisaOnLink (Servicio y COD) 5%', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'TotalSurcharge';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio original del COD sin recargos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'GuideOriginalCollectOnDelivery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio original de la guía sin recargos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'GuideOriginalPriceShipment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía, foranea de DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía, foranea de DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de tabla DeliveryOrderSurcharge', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge', @level2type = N'COLUMN', @level2name = N'IdDeliveryOrderSurcharge';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar los cálculo de los recargos que se hagan por pago por VisaOnLink', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderSurcharge';

