CREATE TABLE [dbo].[InvoiceSequenceByEstablishment] (
    [IdInvoiceSequenceByEstablishment] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Establishment]                    VARCHAR (50)  NOT NULL,
    [TypeDocument]                     INT           NULL,
    [Sequence]                         VARCHAR (500) NULL,
    [RowStatus]                        BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]                      DATETIME      NOT NULL,
    [TokenCreated]                     NVARCHAR (50) NOT NULL,
    [DateUpdated]                      DATETIME      NULL,
    [TokenUpdated]                     NVARCHAR (50) NULL,
    CONSTRAINT [PK_InvoiceSequenceByEstablishment] PRIMARY KEY CLUSTERED ([IdInvoiceSequenceByEstablishment] ASC),
    CONSTRAINT [FK_InvoiceSequenceByEstablishment_CatTypeDocument] FOREIGN KEY ([TypeDocument]) REFERENCES [dbo].[CatTypeDocument] ([IdRegister])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token o identificador del usuario/sistema que realizó la última actualización. NULL si nunca ha sido modificado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceSequenceByEstablishment', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de la última actualización del registro. NULL si nunca ha sido modificado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceSequenceByEstablishment', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token o identificador único del usuario/sistema que creó el registro. Permite trazabilidad completa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceSequenceByEstablishment', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora exacta de creación del registro. Campo obligatorio para auditoría.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceSequenceByEstablishment', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Maneja el estado de los registros, activo o inactivo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceSequenceByEstablishment', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Maneja el correlativo de los documentos, a nivel de Establecimiento y tipo de Documento.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceSequenceByEstablishment', @level2type = N'COLUMN', @level2name = N'Sequence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de Tipo de documento a nivel de facturacion Forza.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceSequenceByEstablishment', @level2type = N'COLUMN', @level2name = N'TypeDocument';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código del establecimiento a nivel de Digifact.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceSequenceByEstablishment', @level2type = N'COLUMN', @level2name = N'Establishment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único autoincremental.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceSequenceByEstablishment', @level2type = N'COLUMN', @level2name = N'IdInvoiceSequenceByEstablishment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Correlativos por Establecimiento para la facturación de El Salvador', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceSequenceByEstablishment';

