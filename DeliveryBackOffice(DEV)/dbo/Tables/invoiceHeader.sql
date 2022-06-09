CREATE TABLE [dbo].[invoiceHeader] (
    [inv_pk_id]               BIGINT         IDENTITY (1, 1) NOT NULL,
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
    [IsPaid]                  BIT            NULL,
    CONSTRAINT [PK_invoiceHeader] PRIMARY KEY CLUSTERED ([inv_pk_id] ASC),
    FOREIGN KEY ([systemOperation]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [FK_InvoiceHeader_CatInvoiceTypeId] FOREIGN KEY ([CatInvoiceTypeId]) REFERENCES [dbo].[CatInvoiceType] ([IdCatInvoiceType])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si factura es manual TRUE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'invoiceHeader', @level2type = N'COLUMN', @level2name = N'IsManualInvoice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la cual FEL finalizo y se actualizo el registro con la respuesta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'invoiceHeader', @level2type = N'COLUMN', @level2name = N'inv_dateFEL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar el tipo de factura.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'invoiceHeader', @level2type = N'COLUMN', @level2name = N'CatInvoiceTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar si la factura debe ser pagada en el servicio de SAP.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'invoiceHeader', @level2type = N'COLUMN', @level2name = N'IsPaid';

