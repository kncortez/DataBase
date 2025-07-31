CREATE TABLE [dbo].[InvoiceDataFixHN] (
    [Id]                       INT           IDENTITY (1, 1) NOT NULL,
    [Id_row]                   BIGINT        NOT NULL,
    [inv_pk_id]                BIGINT        NOT NULL,
    [Id_Lote_old]              INT           NOT NULL,
    [ProcessedCorrelative_old] VARCHAR (20)  NOT NULL,
    [inv_numberFEL_old]        VARCHAR (50)  NOT NULL,
    [inv_serieFEL_old]         VARCHAR (200) NOT NULL,
    [inv_certificationFEL_old] VARCHAR (200) NOT NULL,
    [Id_Lote_new]              INT           NOT NULL,
    [ProcessedCorrelative_new] VARCHAR (20)  NOT NULL,
    [inv_numberFEL_new]        VARCHAR (50)  NOT NULL,
    [inv_serieFEL_new]         VARCHAR (200) NOT NULL,
    [inv_certificationFEL_new] VARCHAR (200) NOT NULL,
    [TokenUpdated]             NVARCHAR (50) NOT NULL,
    [DateOld]                  DATETIME2 (3) NOT NULL,
    [DateNew]                  DATETIME2 (3) NOT NULL
);

