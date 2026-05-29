CREATE TABLE [dbo].[SAPHeader] (
    [DocNum]              BIGINT        NULL,
    [inv_pk_id]           BIGINT        NOT NULL,
    [DocType]             VARCHAR (15)  NOT NULL,
    [DocDate]             VARCHAR (8)   NULL,
    [DocDueDate]          VARCHAR (8)   NULL,
    [CardCode]            VARCHAR (50)  NULL,
    [DocTotal]            MONEY         NULL,
    [Comments]            VARCHAR (46)  NOT NULL,
    [SlpCode]             VARCHAR (1)   NOT NULL,
    [Series]              VARCHAR (50)  NULL,
    [TaxDate]             VARCHAR (8)   NULL,
    [U_Rfactura]          VARCHAR (21)  NOT NULL,
    [inv_IVA]             MONEY         NULL,
    [CodeISO]             NVARCHAR (3)  NOT NULL,
    [dpf_OcrCode]         NVARCHAR (50) NULL,
    [dpf_OcrCode2]        NVARCHAR (50) NULL,
    [U_FIRMA_ELECTRONICA] VARCHAR (200) NULL,
    [U_NUMERO_DOCUMENTO]  VARCHAR (50)  NULL,
    [U_FACTURA_SERIE]     VARCHAR (200) NULL,
    [U_FECHA_FACE]        VARCHAR (8)   NULL,
    [U_MOTIVO_RECHAZO]    VARCHAR (17)  NOT NULL
);

