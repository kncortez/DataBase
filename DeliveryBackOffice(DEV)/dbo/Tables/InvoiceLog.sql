CREATE TABLE [dbo].[InvoiceLog](
	[InvoiceLogId] [bigint] IDENTITY(1,1) NOT NULL,
	[InvIdRestriction] [bigint] NOT NULL,
	[inv_pk_id] [bigint] NOT NULL,
	[inv_DataSent] [nvarchar](max) NULL,
	[inv_DataReceived] [nvarchar](max) NULL,
	[ErrorDesc] [nvarchar](max) NULL,
	[Date] [datetime] NOT NULL,
	[TransactionStatus] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[InvoiceLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[InvoiceLog]  WITH CHECK ADD  CONSTRAINT [FKIRestrictionInvoiceLog] FOREIGN KEY([InvIdRestriction])
REFERENCES [dbo].[InvoiceRestriction] ([InvIdRestriction])
GO

ALTER TABLE [dbo].[InvoiceLog] CHECK CONSTRAINT [FKIRestrictionInvoiceLog]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador unico para los logs de facturas' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceLog', @level2type=N'COLUMN',@level2name=N'InvoiceLogId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de restriccion aplicada al registro almacenado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceLog', @level2type=N'COLUMN',@level2name=N'InvIdRestriction'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador asociado a la factura con el registro log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceLog', @level2type=N'COLUMN',@level2name=N'inv_pk_id'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Trama o informacion enviada' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceLog', @level2type=N'COLUMN',@level2name=N'inv_DataSent'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Trama o informacion recibida' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceLog', @level2type=N'COLUMN',@level2name=N'inv_DataReceived'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion del error registrada en el log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceLog', @level2type=N'COLUMN',@level2name=N'ErrorDesc'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de registro del log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceLog', @level2type=N'COLUMN',@level2name=N'Date'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor que representa el estado del registro log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceLog', @level2type=N'COLUMN',@level2name=N'TransactionStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla que almacena el historial de operaciones para facturas' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceLog'
GO


