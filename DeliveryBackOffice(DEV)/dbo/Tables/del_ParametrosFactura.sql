CREATE TABLE [dbo].[del_ParametrosFactura](
	[dpf_VpCodeOfReference] [int] NOT NULL,
	[dpf_FELRequestor] [varchar](200) NOT NULL,
	[dpf_FELTransaction] [varchar](200) NOT NULL,
	[dpf_FELCountry] [varchar](10) NOT NULL,
	[dpf_FELEntity] [varchar](20) NOT NULL,
	[dpf_FELUser] [varchar](200) NOT NULL,
	[dpf_FELUserName] [varchar](50) NOT NULL,
	[dpf_FELData1] [varchar](50) NOT NULL,
	[dpf_FELData3] [varchar](10) NOT NULL,
	[dpf_FELCorreo] [varchar](50) NOT NULL,
	[dpf_FELAsuntoCorreoFactura] [varchar](200) NOT NULL,
	[dpf_FELAsuntoCorreoNotaCredito] [varchar](200) NOT NULL,
	[dpf_FELEstablecimiento] [varchar](15) NOT NULL,
	[dpf_FELCorreoCCO] [varchar](50) NOT NULL,
	[dpf_SAPServidorLicencias] [varchar](50) NOT NULL,
	[dpf_SAPCompania] [varchar](50) NOT NULL,
	[dpf_SAPUsuario] [varchar](50) NOT NULL,
	[dpf_SAPContrasenia] [nvarchar](100) NOT NULL,
	[dpf_SAPServidor] [varchar](50) NOT NULL,
	[dpf_SAPUsuarioBD] [varchar](50) NOT NULL,
	[dpf_SAPContraseniaBD] [nvarchar](100) NOT NULL,
	[dpf_SAPserieFactura] [varchar](50) NOT NULL,
	[dpf_SAPserieNC] [varchar](50) NOT NULL,
	[dpf_SAPseriePago] [varchar](50) NOT NULL,
	[dpf_SAPcardCode] [varchar](50) NOT NULL,
	[dpf_SAParticulo] [varchar](50) NOT NULL,
	[dpf_SAPvendor] [varchar](50) NOT NULL,
	[dpf_SAPcreditCard] [varchar](50) NOT NULL,
	[dpf_OcrCode] [nvarchar](50) NULL,
	[dpf_OcrCode2] [nvarchar](50) NULL,
	[dpf_StatusFACE] [nvarchar](1) NULL,
	[dpf_WarehouseCode] [int] NULL,
 CONSTRAINT [PK_del_ParametrosFactura] PRIMARY KEY CLUSTERED 
(
	[dpf_VpCodeOfReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO




EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo relacionado con el codigo de punto de visita o express center' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_VpCodeOfReference'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Parametros de configuracion ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_FELRequestor'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de transaccion FEL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_FELTransaction'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pais FEL Registrado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_FELCountry'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entidad FEL registrada' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_FELEntity'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario FEL registrado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_FELUser'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de usuario FEL registrado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_FELUserName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Parametros de configuracion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_FELData1'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Parametros de configuracion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_FELData3'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correo FEL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_FELCorreo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Asunto para correo de factura electronica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_FELAsuntoCorreoFactura'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Asunto para correo electronico de nota de credito' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_FELAsuntoCorreoNotaCredito'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de establecimiento asociado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_FELEstablecimiento'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correo asociado al express center' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_FELCorreoCCO'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Configuracion de licencia de servidor SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAPServidorLicencias'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion de compañia SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAPCompania'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario para sistemas SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAPUsuario'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contraseña para sistemas SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAPContrasenia'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'servidor de sistemas SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAPServidor'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de base de datos para sistemas SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAPUsuarioBD'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contraseña de base de datos para sistemas SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAPContraseniaBD'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de factura para sistemas SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAPserieFactura'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de Serie SAP para nota de credito' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAPserieNC'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de serie de pago para SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAPseriePago'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de carta SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAPcardCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de articulo para SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAParticulo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Configuracion de parametros SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAPvendor'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'configuracion de tarjeta de credito SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_SAPcreditCard'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo ocr' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_OcrCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo ocr 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_OcrCode2'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'parametro de configuracion para facturas' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_StatusFACE'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo para almacenar código de almacen de Express Center.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura', @level2type=N'COLUMN',@level2name=N'dpf_WarehouseCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla con parametros para facturacion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'del_ParametrosFactura'
GO


