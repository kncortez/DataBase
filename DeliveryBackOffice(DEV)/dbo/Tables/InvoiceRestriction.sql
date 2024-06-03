CREATE TABLE [dbo].[InvoiceRestriction] (
    [InvIdRestriction] BIGINT       IDENTITY (1, 1) NOT NULL,
    [inv_pk_id]        BIGINT       NOT NULL,
    [inv_SAPDocEntry]  INT          NOT NULL,
    [invRetries]       INT          NOT NULL,
    [invRowStatus]     BIT          NOT NULL,
    [invTokenCreated]  VARCHAR (50) NOT NULL,
    [invDateCreated]   DATETIME     NOT NULL,
    [invOperationDate] DATETIME     NOT NULL,
    PRIMARY KEY CLUSTERED ([InvIdRestriction] ASC),
    CONSTRAINT [FKInvoiceHeader] FOREIGN KEY ([inv_pk_id]) REFERENCES [dbo].[invoiceHeader] ([inv_pk_id])
);




GO
CREATE NONCLUSTERED INDEX [idx_inv_pk_id]
    ON [dbo].[InvoiceRestriction]([inv_pk_id] ASC);


GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador unico de la restriccion de la factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceRestriction', @level2type=N'COLUMN',@level2name=N'InvIdRestriction'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'registro asociado a la factura (llave foranea)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceRestriction', @level2type=N'COLUMN',@level2name=N'inv_pk_id'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceRestriction', @level2type=N'COLUMN',@level2name=N'inv_SAPDocEntry'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de intentos que se a intentado registrar la factura a SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceRestriction', @level2type=N'COLUMN',@level2name=N'invRetries'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado que representa si la factura fue recibida a SAP con exito o no' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceRestriction', @level2type=N'COLUMN',@level2name=N'invRowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token creado para la restriccion de la factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceRestriction', @level2type=N'COLUMN',@level2name=N'invTokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creacion del registro de restriccion de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceRestriction', @level2type=N'COLUMN',@level2name=N'invDateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de operacion de SAP para el registro de restriccion de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceRestriction', @level2type=N'COLUMN',@level2name=N'invOperationDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de restricciones para facturas' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceRestriction'
GO
