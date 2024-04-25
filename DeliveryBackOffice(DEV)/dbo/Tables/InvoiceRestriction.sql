CREATE TABLE [dbo].[InvoiceRestriction](
	[InvIdRestriction] [bigint] IDENTITY(1,1) NOT NULL,
	[inv_pk_id] [bigint] NOT NULL,
	[inv_SAPDocEntry] [int] NOT NULL,
	[invRetries] [int] NOT NULL,
	[invRowStatus] [bit] NOT NULL,
	[invTokenCreated] [varchar](50) NOT NULL,
	[invDateCreated] [datetime] NOT NULL,
	[invOperationDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[InvIdRestriction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[InvoiceRestriction]  WITH CHECK ADD  CONSTRAINT [FKInvoiceHeader] FOREIGN KEY([inv_pk_id])
REFERENCES [dbo].[invoiceHeader] ([inv_pk_id])
GO

ALTER TABLE [dbo].[InvoiceRestriction] CHECK CONSTRAINT [FKInvoiceHeader]
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


