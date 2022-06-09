CREATE TABLE [dbo].[PaymentCommissionCOD] (
    [IdPaymentCommissionCOD] INT             IDENTITY (1, 1) NOT NULL,
    [invoiceHeaderId]        BIGINT          NOT NULL,
    [CatTypeProductId]       INT             NULL,
    [TotalAmount]            DECIMAL (18, 2) NULL,
    [PaymentDate]            DATETIME        NULL,
    [CatModuleId]            INT             NULL,
    [TotalAmountPaid]        DECIMAL (12, 2) NULL,
    [RowStatus]              BIT             CONSTRAINT [DF_PaymentCommissionCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]           VARCHAR (50)    NOT NULL,
    [DateCreated]            DATETIME        NOT NULL,
    [TokenUpdated]           VARCHAR (50)    NULL,
    [DateUpdated]            DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdPaymentCommissionCOD] ASC),
    CONSTRAINT [FK_PaymentCommissionCOD_CatModuleId] FOREIGN KEY ([CatModuleId]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FK_PaymentCommissionCOD_CatTypeProductId] FOREIGN KEY ([CatTypeProductId]) REFERENCES [dbo].[CatTypeProduct] ([IdTypeProduct]),
    CONSTRAINT [FK_PaymentCommissionCOD_inv_pk_id] FOREIGN KEY ([invoiceHeaderId]) REFERENCES [dbo].[invoiceHeader] ([inv_pk_id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar los pagos de Comisión COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador PaymentCommissionCOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCOD', @level2type = N'COLUMN', @level2name = N'IdPaymentCommissionCOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foránea de tabla invoiceHeader', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCOD', @level2type = N'COLUMN', @level2name = N'invoiceHeaderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foránea de tabla  CatTypeProduct', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCOD', @level2type = N'COLUMN', @level2name = N'CatTypeProductId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de la comisión COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCOD', @level2type = N'COLUMN', @level2name = N'TotalAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCOD', @level2type = N'COLUMN', @level2name = N'PaymentDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foránea de tabla  CatModule', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCOD', @level2type = N'COLUMN', @level2name = N'CatModuleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total pagado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCOD', @level2type = N'COLUMN', @level2name = N'TotalAmountPaid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCOD', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCOD', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación de fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCOD', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualizó fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCOD', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentCommissionCOD', @level2type = N'COLUMN', @level2name = N'DateUpdated';

