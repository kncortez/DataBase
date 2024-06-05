CREATE TABLE [dbo].[InOutOfMoneyDetail] (
    [io_type]                      INT           NOT NULL,
    [io_vpCodeOfReferences]        INT           NOT NULL,
    [io_ticket]                    VARCHAR (100) NULL,
    [io_amount]                    MONEY         NOT NULL,
    [io_status]                    INT           NOT NULL,
    [io_invoice]                   BIGINT        NULL,
    [io_registryToken]             VARCHAR (50)  NOT NULL,
    [io_registryDate]              DATETIME      NOT NULL,
    [io_updateToken]               VARCHAR (50)  NULL,
    [io_updateDate]                DATETIME      NULL,
    [io_pk_id]                     INT           IDENTITY (1, 1) NOT NULL,
    [inv_SAPDocEntryPaymentDetail] INT           NULL,
    [io_SAPDocEntryPaymentDetail]  INT           NULL,
    [io_SAPErrorPaymentDetail]     VARCHAR (500) NULL,
    [io_canceledInSAP]             BIT           NULL,
    [io_canceledInSAPDescription]  VARCHAR (200) NULL,
    CONSTRAINT [pk_InOutOfMoneyDetail] PRIMARY KEY CLUSTERED ([io_pk_id] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_InOutOfMoneyDetail]
    ON [dbo].[InOutOfMoneyDetail]([io_invoice] ASC);


GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de factura pagada (factura electronica o nota de credito)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_type'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de referencia sobre el punto de visita del pago de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_vpCodeOfReferences'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena el numero de voucher de pago por tarjeta de credito' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_ticket'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Precio unitario efectuado sobre pago de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_amount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado actual de registro de pagos (1: aun no se manda a SAP, 2: cuando se genero un error, 3: se envio la factura exitosamente)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_status'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Relacion de pago con factura en tabla InvoiceHeader ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_invoice'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de registro sobre pago de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_registryToken'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de registro sobre pago de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_registryDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizacion sobre el pago de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_updateToken'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion sobre el pago de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_updateDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador unico del pago de factura registrado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_pk_id'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Detalle de Pago sobre codigo SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'inv_SAPDocEntryPaymentDetail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Detalle de Pago sobre codigo SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_SAPDocEntryPaymentDetail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Detalle de pago sobre error en SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_SAPErrorPaymentDetail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Registro de cancelacion SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_canceledInSAP'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion de cancelacion SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail', @level2type=N'COLUMN',@level2name=N'io_canceledInSAPDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de registro para el pago de facturas' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InOutOfMoneyDetail'
GO
