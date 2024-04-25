CREATE TABLE [dbo].[tmpManualInvoice](
	[Guide] [int] NOT NULL,
	[BusinessName] [nvarchar](100) NULL,
	[Signature] [nvarchar](100) NULL,
	[Nit] [nvarchar](50) NULL,
 CONSTRAINT [PK_tmpManualInvoice] PRIMARY KEY CLUSTERED 
(
	[Guide] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de guia' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tmpManualInvoice', @level2type=N'COLUMN',@level2name=N'Guide'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de empresa o cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tmpManualInvoice', @level2type=N'COLUMN',@level2name=N'BusinessName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Firma o Certificado FEL del cliente o empresa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tmpManualInvoice', @level2type=N'COLUMN',@level2name=N'Signature'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'NIT de empresa o cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tmpManualInvoice', @level2type=N'COLUMN',@level2name=N'Nit'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para el registro de guias para facturacion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tmpManualInvoice'
GO


