CREATE TABLE [dbo].[RetroactiveReconciliation](
    [IdRetroactiveReconciliation] [int] IDENTITY(1,1) NOT NULL,
    [GuideDate] [date] NOT NULL,
    [Guide] [nvarchar](25) NOT NULL,
    [CustomerId] [int] NOT NULL,
    [CustomerName] [nvarchar](128) NOT NULL,
    [TypeSaleId] [int] NOT NULL,
    [TypeSale] [nvarchar](64) NOT NULL,
    [StatusId] [int] NOT NULL,
    [Status] [nvarchar](64) NOT NULL,
    [SystemId]   [int] NOT NULL,
    [SystemName] [nvarchar](64) NOT NULL,
    [PaymentMethodId] [int] NOT NULL,
    [PaymentMethod]   [nvarchar](64) NOT NULL,
    [TypePurchaseId]  [int] NOT NULL,
    [TypePurchase]    [nvarchar](64) NOT NULL,
    [Sender] [nvarchar](128) NOT NULL,
    [Invoice] [nvarchar](128) NOT NULL,
    [Attempt] [int] NOT NULL,
    [Overweight] [decimal](16, 2) NOT NULL,
    [CountryId]  [nvarchar](4) NOT NULL,
    [Amount] [decimal](14,2) NOT NULL,    

    CONSTRAINT [PK_RetroactiveReconciliation] PRIMARY KEY CLUSTERED ([IdRetroactiveReconciliation] ASC)
);

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Fecha de emisión de la guía', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'GuideDate';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Serie y Correlativo de guía', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'Guide';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Código de cliente', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'CustomerId';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Nombre del cliente', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'CustomerName';


GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Código de tipo de venta', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'TypeSaleId';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Tipo de Venta', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'TypeSale';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Id del estado de guía', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'StatusId';


GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Estado de la guía, estado terminal', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'Status';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Id del sistema donde se emitió la guía', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'SystemId';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Sistema donde se emite la guía', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'System';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Nombre de quien envia el paquete', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'Sender';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Id del metodo de pago de la guía', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'PaymentMethodId';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Metodo de pago de la guía', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'Paymentmethod';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Id del tipo de compra de la guía', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'TypePurchaseId';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Tipo de compra de la guía', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'TypePurchase';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Factura asociada a la guía', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'Invoice';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Intentos de envío de la guía', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'Attempt';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Pago por sobrepeso', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'Overweight';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'País de origen de la guía', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'CountryId';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Monto de la guía', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation', 
        @level2type = N'COLUMN', 
        @level2name = N'Amount';

GO
EXECUTE sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Datos para reporte de Reconciliación Retro Activa', 
        @level0type = N'SCHEMA', 
        @level0name = N'dbo', 
        @level1type = N'TABLE', 
        @level1name = N'RetroactiveReconciliation';