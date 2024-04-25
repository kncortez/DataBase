CREATE TABLE [dbo].[ctg_statusInvoice](
	[ist_pk_id] [int] NOT NULL,
	[ist_nombre] [varchar](50) NOT NULL,
	[ist_descripcion] [varchar](1000) NOT NULL,
	[ist_dateInsert] [datetime] NOT NULL,
	[ist_tokenInsert] [varchar](50) NOT NULL,
	[ist_dateUpdate] [datetime] NULL,
	[ist_tokenUpdate] [varchar](50) NULL,
 CONSTRAINT [PK_ctg_statusInvoice] PRIMARY KEY CLUSTERED 
(
	[ist_pk_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador unico del tipo de estado de la factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ctg_statusInvoice', @level2type=N'COLUMN',@level2name=N'ist_pk_id'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del estado de la factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ctg_statusInvoice', @level2type=N'COLUMN',@level2name=N'ist_nombre'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion del estado de la factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ctg_statusInvoice', @level2type=N'COLUMN',@level2name=N'ist_descripcion'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de registro del estado de la factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ctg_statusInvoice', @level2type=N'COLUMN',@level2name=N'ist_dateInsert'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de registro del estado de la factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ctg_statusInvoice', @level2type=N'COLUMN',@level2name=N'ist_tokenInsert'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion del estado de la factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ctg_statusInvoice', @level2type=N'COLUMN',@level2name=N'ist_dateUpdate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizacion del estado de la factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ctg_statusInvoice', @level2type=N'COLUMN',@level2name=N'ist_tokenUpdate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla que describe el tipo de estado de las facturas' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ctg_statusInvoice'
GO


