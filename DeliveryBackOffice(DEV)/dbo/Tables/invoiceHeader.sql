CREATE TABLE [dbo].[invoiceHeader] (
    [inv_pk_id]               BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [inv_vpCodeOfReferences]  INT            NOT NULL,
    [inv_cmp_name]            VARCHAR (500)  NULL,
    [inv_cmp_nameComercial]   VARCHAR (500)  NULL,
    [inv_cmp_adress]          VARCHAR (1000) NULL,
    [inv_cmp_nit]             VARCHAR (100)  NOT NULL,
    [inv_cli_name]            VARCHAR (500)  NOT NULL,
    [inv_cli_adress]          VARCHAR (1000) NOT NULL,
    [inv_cli_nit]             VARCHAR (100)  NOT NULL,
    [inv_cli_email]           VARCHAR (500)  NOT NULL,
    [inv_date]                DATETIME       NOT NULL,
    [inv_documentSend]        VARCHAR (MAX)  NULL,
    [inv_documentRecieved]    VARCHAR (MAX)  NULL,
    [inv_certificationFEL]    VARCHAR (200)  NULL,
    [inv_serieFEL]            VARCHAR (200)  NULL,
    [inv_numberFEL]           VARCHAR (50)   NULL,
    [inv_descriptionFEL]      VARCHAR (500)  NULL,
    [inv_RequestorFEL]        VARCHAR (250)  NULL,
    [inv_TransactionFEL]      VARCHAR (100)  NULL,
    [inv_CountryFEL]          VARCHAR (4)    NULL,
    [inv_EntityFEL]           VARCHAR (50)   NULL,
    [inv_UserFEL]             VARCHAR (150)  NULL,
    [inv_UserName]            VARCHAR (150)  NULL,
    [inv_Data1FEL]            VARCHAR (150)  NULL,
    [inv_Data3FEL]            VARCHAR (150)  NULL,
    [inv_MailSendFEL]         VARCHAR (150)  NULL,
    [inv_subjectFEL]          VARCHAR (150)  NULL,
    [inv_IVA]                 MONEY          NULL,
    [inv_amount]              MONEY          NULL,
    [inv_status]              INT            NOT NULL,
    [inv_dateRegister]        DATETIME       NOT NULL,
    [inv_tokenRegister]       VARCHAR (200)  NOT NULL,
    [inv_dateUpdate]          DATETIME       NULL,
    [inv_tokenUpdate]         VARCHAR (200)  NULL,
    [inv_type]                INT            NOT NULL,
    [inv_invoiceOfCreditNote] INT            NULL,
    [inv_motiveCreditNote]    VARCHAR (200)  NULL,
    [inv_dateOriginDocument]  DATETIME       NULL,
    [inv_documentOriginFEL]   VARCHAR (500)  NULL,
    [inv_creditNote]          INT            NULL,
    [inv_establecimientoFEL]  VARCHAR (5)    NULL,
    [inv_cmp_nameFEL]         VARCHAR (2000) NULL,
    [inv_FechaHoraFEL]        VARCHAR (50)   NULL,
    [inv_SAPDocEntry]         INT            NULL,
    [inv_SAPError]            VARCHAR (300)  NULL,
    [systemOperation]         INT            NULL,
    [IsManualInvoice]         BIT            NULL,
    [inv_dateFEL]             DATETIME       NULL,
    [CatInvoiceTypeId]        INT            NULL,
    [Retries]                 INT            DEFAULT ((1)) NULL,
    [IdCurrency]              INT            NULL,
    [IdCountry]               VARCHAR (2)    NULL,
    CONSTRAINT [PK_invoiceHeader] PRIMARY KEY CLUSTERED ([inv_pk_id] ASC),
    FOREIGN KEY ([systemOperation]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [FK_IdCountryInvH_CatCountry] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    CONSTRAINT [FK_IdCurrencyInvH_CatCurrencyCOD] FOREIGN KEY ([IdCurrency]) REFERENCES [dbo].[CatCurrencyCOD] ([IdCatCurrencyCOD])
);



















GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si factura es manual TRUE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'invoiceHeader', @level2type = N'COLUMN', @level2name = N'IsManualInvoice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la cual FEL finalizo y se actualizo el registro con la respuesta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'invoiceHeader', @level2type = N'COLUMN', @level2name = N'inv_dateFEL';


GO



GO
CREATE NONCLUSTERED INDEX [IX_invoiceHeaderRDL]
    ON [dbo].[invoiceHeader]([inv_pk_id] ASC, [inv_certificationFEL] ASC, [inv_creditNote] ASC, [inv_motiveCreditNote] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_inv_type_inv_creditNote_inv_date]
    ON [dbo].[invoiceHeader]([inv_type] ASC, [inv_creditNote] ASC, [inv_date] ASC)
    INCLUDE([inv_pk_id], [inv_vpCodeOfReferences]);


GO
CREATE NONCLUSTERED INDEX [idx_inv_status_inv_dateRegister_inv_type_inv_SAPDocEntry]
    ON [dbo].[invoiceHeader]([inv_status] ASC, [inv_dateRegister] ASC, [inv_type] ASC, [inv_SAPDocEntry] ASC)
    INCLUDE([inv_vpCodeOfReferences], [inv_certificationFEL], [inv_invoiceOfCreditNote]);


GO
CREATE NONCLUSTERED INDEX [IDX_id_status_certification_seriefel_]
    ON [dbo].[invoiceHeader]([inv_pk_id] ASC, [inv_certificationFEL] ASC, [inv_serieFEL] ASC, [inv_status] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_inv_numberFEL_inv_numberFEL]
    ON [dbo].[invoiceHeader]([inv_numberFEL] ASC)
    INCLUDE([inv_certificationFEL], [inv_serieFEL], [inv_UserName], [inv_SAPDocEntry]);

GO
CREATE NONCLUSTERED INDEX [IDX_CatInvoiceTypeId_Retries]
    ON [dbo].[invoiceHeader] ([CatInvoiceTypeId],[Retries])
    INCLUDE ([inv_descriptionFEL])

GO
CREATE NONCLUSTERED INDEX [idx_inv_pk_id_CatInvoiceTypeId]
    ON [dbo].[invoiceHeader]( [CatInvoiceTypeId]);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del pais registrado para la factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'invoiceHeader', @level2type = N'COLUMN', @level2name = N'IdCountry';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de moneda de la factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'invoiceHeader', @level2type = N'COLUMN', @level2name = N'IdCurrency';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar el tipo de factura.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'invoiceHeader', @level2type = N'COLUMN', @level2name = N'CatInvoiceTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar los int�ntos de la generaci�n de una factura.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'invoiceHeader', @level2type = N'COLUMN', @level2name = N'Retries';




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

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de cabecera de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceHeader'
GO
CREATE NONCLUSTERED INDEX [idx_inv_vpCodeOfReferences]
    ON [dbo].[invoiceHeader]([inv_vpCodeOfReferences] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_inv_dateRegister_inv_type_inv_SAPDocEntry_include]
    ON [dbo].[invoiceHeader]([inv_dateRegister] ASC, [inv_type] ASC, [inv_SAPDocEntry] ASC)
    INCLUDE([inv_vpCodeOfReferences], [inv_date], [inv_status], [inv_invoiceOfCreditNote], [IdCountry]);

