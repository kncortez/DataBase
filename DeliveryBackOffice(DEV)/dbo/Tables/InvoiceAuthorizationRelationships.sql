CREATE TABLE [dbo].[InvoiceAuthorizationRelationships](
    [IdInvoiceAuthorizationRelationships]    [int] IDENTITY(1,1) NOT NULL,
    [CodeOfReference]                        [int] NOT NULL,
    [InvoiceAuthorizationHeaderId]           [int] NOT NULL,
    [RowStatus]                              [bit] NOT NULL,
    [TokenCreated]                           [nvarchar](100) NOT NULL,
    [DateCreated]                            [datetime] NOT NULL,
    [TokenUpdated]                           [nvarchar](100) NULL,
    [DateUpdated]                            [datetime] NULL,
    CONSTRAINT [PK_InvoiceAuthorizationRelationships] PRIMARY KEY CLUSTERED ([IdInvoiceAuthorizationRelationships] ASC),
    CONSTRAINT [FK_InvoiceAuthorizationRelationships_InvoiceAuthorizationRelationships] FOREIGN KEY ([IdInvoiceAuthorizationRelationships]) REFERENCES [dbo].[InvoiceAuthorizationRelationships] ([IdInvoiceAuthorizationRelationships]),
);
GO


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria de la tabla', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationRelationships', @level2type = N'COLUMN', @level2name = N'IdInvoiceAuthorizationRelationships';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Codigo del punto de venta activo para generación de facturas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationRelationships', @level2type = N'COLUMN', @level2name = N'odeOfReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de la autorización asignada al punto de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationRelationships', @level2type = N'COLUMN', @level2name = N'InvoiceAuthorizationHeaderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de generación del token', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationRelationships', @level2type = N'COLUMN', @level2name = N'StartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de vencimiento del token', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationRelationships', @level2type = N'COLUMN', @level2name = N'EndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationRelationships', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationRelationships', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationRelationships', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationRelationships', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationRelationships', @level2type = N'COLUMN', @level2name = N'DateUpdated';


