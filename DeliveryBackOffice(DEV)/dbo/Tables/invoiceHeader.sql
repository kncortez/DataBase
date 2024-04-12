CREATE TABLE [dbo].[invoiceHeader](
	[inv_pk_id] [bigint] IDENTITY(1,1) NOT NULL,
	[inv_vpCodeOfReferences] [int] NOT NULL,
	[inv_cmp_name] [varchar](500) NULL,
	[inv_cmp_nameComercial] [varchar](500) NULL,
	[inv_cmp_adress] [varchar](1000) NULL,
	[inv_cmp_nit] [varchar](100) NOT NULL,
	[inv_cli_name] [varchar](500) NOT NULL,
	[inv_cli_adress] [varchar](1000) NOT NULL,
	[inv_cli_nit] [varchar](100) NOT NULL,
	[inv_cli_email] [varchar](500) NOT NULL,
	[inv_date] [datetime] NOT NULL,
	[inv_documentSend] [varchar](max) NULL,
	[inv_documentRecieved] [varchar](max) NULL,
	[inv_certificationFEL] [varchar](200) NULL,
	[inv_serieFEL] [varchar](200) NULL,
	[inv_numberFEL] [varchar](50) NULL,
	[inv_descriptionFEL] [varchar](500) NULL,
	[inv_RequestorFEL] [varchar](250) NULL,
	[inv_TransactionFEL] [varchar](100) NULL,
	[inv_CountryFEL] [varchar](4) NULL,
	[inv_EntityFEL] [varchar](50) NULL,
	[inv_UserFEL] [varchar](150) NULL,
	[inv_UserName] [varchar](150) NULL,
	[inv_Data1FEL] [varchar](150) NULL,
	[inv_Data3FEL] [varchar](150) NULL,
	[inv_MailSendFEL] [varchar](150) NULL,
	[inv_subjectFEL] [varchar](150) NULL,
	[inv_IVA] [money] NULL,
	[inv_amount] [money] NULL,
	[inv_status] [int] NOT NULL,
	[inv_dateRegister] [datetime] NOT NULL,
	[inv_tokenRegister] [varchar](200) NOT NULL,
	[inv_dateUpdate] [datetime] NULL,
	[inv_tokenUpdate] [varchar](200) NULL,
	[inv_type] [int] NOT NULL,
	[inv_invoiceOfCreditNote] [int] NULL,
	[inv_motiveCreditNote] [varchar](200) NULL,
	[inv_dateOriginDocument] [datetime] NULL,
	[inv_documentOriginFEL] [varchar](500) NULL,
	[inv_creditNote] [int] NULL,
	[inv_establecimientoFEL] [varchar](5) NULL,
	[inv_cmp_nameFEL] [varchar](2000) NULL,
	[inv_FechaHoraFEL] [varchar](50) NULL,
	[inv_SAPDocEntry] [int] NULL,
	[inv_SAPError] [varchar](300) NULL,
	[systemOperation] [int] NULL,
	[IsManualInvoice] [bit] NULL,
	[inv_dateFEL] [datetime] NULL,
	[CatInvoiceTypeId] [int] NULL,
	[Retries] [int] NULL,
 CONSTRAINT [PK_invoiceHeader] PRIMARY KEY CLUSTERED 
(
	[inv_pk_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[invoiceHeader] ADD  DEFAULT ((1)) FOR [Retries]
GO

ALTER TABLE [dbo].[invoiceHeader]  WITH CHECK ADD FOREIGN KEY([systemOperation])
REFERENCES [dbo].[CatSystem] ([SysIdSystem])
GO





EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador principal de cabecera de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_pk_id'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de referencia con Punto de visita o express center, con tabla VisitPointClient (Llave foranea)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_vpCodeOfReferences'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de forza para encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_cmp_name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre comerial de forza para encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_cmp_nameComercial'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dirección de forza para encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_cmp_adress'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nit de forza para encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_cmp_nit'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del cliente para encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_cli_name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Direccion de cliente para encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_cli_adress'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nit del cliente para encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_cli_nit'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correo de cliente para encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_cli_email'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de registro de encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_date'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Informacion de peticion que se envia sobre el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_documentSend'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Informacion de peticion que se recibe sobre el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_documentRecieved'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Certificacion FEL del encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_certificationFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie FEL registrada al encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_serieFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de orden FEL para encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_numberFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion FEL registrada para encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_descriptionFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Parametros de factura relacionados con el certificador, traidos de la tabla del_ParametrosFactura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_RequestorFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de transaccion FEL para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_TransactionFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pais FEL registrado para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_CountryFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entidad FEL registrada para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_EntityFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario FEL Registrado para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_UserFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de usuario registrado para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_UserName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Parametros de configuracion para certificador, se encuentra en tabla del_ParametrosFactura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_Data1FEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Parametros de configuracion para certificador, se encuentra en tabla del_ParametrosFactura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_Data3FEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correo de envio FEL registrado para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_MailSendFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de facturacion registrada para el encabezado de factura (Nota de credito o factura electronica)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_subjectFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IVA aplicado que se registro para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_IVA'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total registrado para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_amount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Representado el estado de la factura actual' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_status'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de registro para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_dateRegister'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token registrado para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_tokenRegister'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_dateUpdate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizacion para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_tokenUpdate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de facturacion generada para el encabezado de factura (1: factura electronica, 2: nota de credito)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_type'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de factura de nota de credito registrado para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_invoiceOfCreditNote'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion de anulacion para nota de credito registrado para el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_motiveCreditNote'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de origen de la nota de credito registrada en el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_dateOriginDocument'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo FEL registrado para la nota de credito en el encabezado de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_documentOriginFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo relacionado con la nota de credito' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_creditNote'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Parametros de configuracion para certificador, se encuentra en tabla del_ParametrosFactura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_establecimientoFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Parametros de configuracion para certificador, se encuentra en tabla del_ParametrosFactura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_cmp_nameFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Parametros de configuracion para certificador, se encuentra en tabla del_ParametrosFactura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_FechaHoraFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Documento SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_SAPDocEntry'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Error SAP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_SAPError'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Operacion del Sistema' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'systemOperation'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Si factura es manual TRUE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'IsManualInvoice'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la cual FEL finalizo y se actualizo el registro con la respuesta.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'inv_dateFEL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo para poder registrar el tipo de factura.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'CatInvoiceTypeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo para poder registrar los int�ntos de la generaci�n de una factura.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader', @level2type=N'COLUMN',@level2name=N'Retries'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de cabecera de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader'
GO


