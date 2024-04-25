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




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que describe el tipo de estado de las facturas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ctg_statusInvoice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion del estado de la factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ctg_statusInvoice', @level2type = N'COLUMN', @level2name = N'ist_tokenUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de registro del estado de la factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ctg_statusInvoice', @level2type = N'COLUMN', @level2name = N'ist_tokenInsert';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador unico del tipo de estado de la factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ctg_statusInvoice', @level2type = N'COLUMN', @level2name = N'ist_pk_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del estado de la factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ctg_statusInvoice', @level2type = N'COLUMN', @level2name = N'ist_nombre';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripcion del estado de la factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ctg_statusInvoice', @level2type = N'COLUMN', @level2name = N'ist_descripcion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion del estado de la factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ctg_statusInvoice', @level2type = N'COLUMN', @level2name = N'ist_dateUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de registro del estado de la factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ctg_statusInvoice', @level2type = N'COLUMN', @level2name = N'ist_dateInsert';

