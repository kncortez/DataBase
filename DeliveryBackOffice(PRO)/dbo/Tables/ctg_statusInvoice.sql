CREATE TABLE [dbo].[ctg_statusInvoice] (
    [ist_pk_id]       INT            NOT NULL,
    [ist_nombre]      VARCHAR (50)   NOT NULL,
    [ist_descripcion] VARCHAR (1000) NOT NULL,
    [ist_dateInsert]  DATETIME       NOT NULL,
    [ist_tokenInsert] VARCHAR (50)   NOT NULL,
    [ist_dateUpdate]  DATETIME       NULL,
    [ist_tokenUpdate] VARCHAR (50)   NULL,
    CONSTRAINT [PK_ctg_statusInvoice] PRIMARY KEY CLUSTERED ([ist_pk_id] ASC)
);

