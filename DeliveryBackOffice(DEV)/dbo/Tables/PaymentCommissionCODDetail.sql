CREATE TABLE [dbo].[PaymentCommissionCODDetail] (
    [IdPaymentCommissionCODDetail] INT             IDENTITY (1, 1) NOT NULL,
    [PaymentCommissionCODId]       INT             NOT NULL,
    [ctgTypeOfInOutOfMoneyId]      INT             NULL,
    [Amount]                       DECIMAL (18, 2) NULL,
    [Voucher]                      VARCHAR (300)   NULL,
    [RowStatus]                    BIT             CONSTRAINT [DF_PaymentCommissionCODDetail_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]                 VARCHAR (50)    NOT NULL,
    [DateCreated]                  DATETIME        NOT NULL,
    [TokenUpdated]                 VARCHAR (50)    NULL,
    [DateUpdated]                  DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdPaymentCommissionCODDetail] ASC),
    CONSTRAINT [FK_PaymentCommissionCODDetail_ctgTypeOfInOutOfMoneyId] FOREIGN KEY ([ctgTypeOfInOutOfMoneyId]) REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id]),
    CONSTRAINT [FK_PaymentCommissionCODDetail_PaymentCommissionCODId] FOREIGN KEY ([PaymentCommissionCODId]) REFERENCES [dbo].[PaymentCommissionCOD] ([IdPaymentCommissionCOD])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCODDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualizó fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCODDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación de fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCODDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCODDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCODDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Voucher de la transacción si es pago con tarjeta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCODDetail', @level2type = N'COLUMN', @level2name = N'Voucher';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de la comisión COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCODDetail', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foránea de tabla  ctgTypeOfInOutOfMoney', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCODDetail', @level2type = N'COLUMN', @level2name = N'ctgTypeOfInOutOfMoneyId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foránea de tabla PaymentCommissionCOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCODDetail', @level2type = N'COLUMN', @level2name = N'PaymentCommissionCODId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador PaymentCommissionCODDetail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCODDetail', @level2type = N'COLUMN', @level2name = N'IdPaymentCommissionCODDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar el detalle de los pagos de Comisión COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCODDetail';

