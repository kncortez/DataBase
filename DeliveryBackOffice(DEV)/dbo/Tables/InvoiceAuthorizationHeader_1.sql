CREATE TABLE [dbo].[InvoiceAuthorizationHeader] (
    [IdInvoiceAuthorizationHeader] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Authorization]                NVARCHAR (512) NOT NULL,
    [StartDate]                    DATETIME       NOT NULL,
    [EndDate]                      DATETIME       NOT NULL,
    [RowStatus]                    BIT            NOT NULL,
    [TokenCreated]                 NVARCHAR (100) NOT NULL,
    [DateCreated]                  DATETIME       NOT NULL,
    [TokenUpdated]                 NVARCHAR (100) NULL,
    [DateUpdated]                  DATETIME       NULL,
    CONSTRAINT [PK_InvoiceAuthorizationHeader] PRIMARY KEY CLUSTERED ([IdInvoiceAuthorizationHeader] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationHeader', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationHeader', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationHeader', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationHeader', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationHeader', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de vencimiento del token', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationHeader', @level2type = N'COLUMN', @level2name = N'EndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de generación del token', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationHeader', @level2type = N'COLUMN', @level2name = N'StartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token JWT generado por Digifact para autenticar la transacciones realizadas, tiene 30 días duración', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationHeader', @level2type = N'COLUMN', @level2name = N'Authorization';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria de la tabla', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceAuthorizationHeader', @level2type = N'COLUMN', @level2name = N'IdInvoiceAuthorizationHeader';

