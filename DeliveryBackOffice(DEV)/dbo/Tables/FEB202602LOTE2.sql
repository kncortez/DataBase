CREATE TABLE [dbo].[FEB202602LOTE2] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [inv_pk_id]          INT           NULL,
    [DocType]            VARCHAR (50)  NULL,
    [DocDate]            VARCHAR (8)   NULL,
    [DocDueDate]         VARCHAR (8)   NULL,
    [CardCode]           VARCHAR (50)  NULL,
    [DocTotal]           MONEY         NULL,
    [Comments]           VARCHAR (200) NULL,
    [SlpCode]            INT           NULL,
    [Series]             VARCHAR (50)  NULL,
    [TaxDate]            VARCHAR (8)   NULL,
    [U_Rfactura]         VARCHAR (50)  NULL,
    [U_ESTADO_FACE]      VARCHAR (5)   NULL,
    [U_FIRMA_ELETRONICA] VARCHAR (300) NULL,
    [U_NUMERO_DOCUMENTO] VARCHAR (50)  NULL,
    [U_FACTURA_SERIE]    VARCHAR (50)  NULL,
    [U_FacNit]           VARCHAR (50)  NULL,
    [U_FacNom]           VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

