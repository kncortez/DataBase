CREATE TABLE [dbo].[InformationBuyerInvoice] (
    [Id]                             INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [InvoiceId]                      BIGINT         NOT NULL,
    [DistrictCode]                   NVARCHAR (100) NOT NULL,
    [StateCode]                      NVARCHAR (100) NOT NULL,
    [ActivityCode]                   NVARCHAR (100) NOT NULL,
    [ActivityDescription]            NVARCHAR (500) NOT NULL,
    [NRC]                            NVARCHAR (20)  NULL,
    [TypeIdentificationDocumentCode] NVARCHAR (100) NULL,
    [IdDocument]                     NVARCHAR (20)  NULL,
    [Phone]                          NVARCHAR (10)  NULL,
    [Rowstatus]                      BIT            NULL,
    [TokenCreated]                   NVARCHAR (50)  NULL,
    [DateCreated]                    DATETIME       NULL,
    [TokenUpdated]                   NVARCHAR (50)  NULL,
    [DateUpdated]                    DATETIME       NULL,
    [OperationConditionCode]         INT            NULL,
    CONSTRAINT [PK_InformationBuyerInvoice] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_InformationBuyerInvoice_invoiceHeader] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[invoiceHeader] ([inv_pk_id])
);




GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Tabla que almacena información del comprador relacionada a una factura', 
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador único del registro', 
    @level2type = N'COLUMN', @level2name = 'Id',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador de la factura asociada', 
    @level2type = N'COLUMN', @level2name = 'InvoiceId',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador del distrito', 
    @level2type = N'COLUMN', @level2name = 'DistrictCode',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador del estado', 
    @level2type = N'COLUMN', @level2name = 'StateCode',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Actividad económica del comprador', 
    @level2type = N'COLUMN', @level2name = 'ActivityCode',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Descripción de actividad económica', 
    @level2type = N'COLUMN', @level2name = 'ActivityDescription',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Número de Registro del Contribuyente (NRC)', 
    @level2type = N'COLUMN', @level2name = 'NRC',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';


GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Tipo de documento de identificación del comprador', 
    @level2type = N'COLUMN', @level2name = 'TypeIdentificationDocumentCode',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Número de identificación', 
    @level2type = N'COLUMN', @level2name = 'IdDocument',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';


GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Teléfono del comprador', 
    @level2type = N'COLUMN', @level2name = 'Phone',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Estado del registro (1 = activo, 0 = inactivo)', 
    @level2type = N'COLUMN', @level2name = 'Rowstatus',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Token del usuario que creó el registro', 
    @level2type = N'COLUMN', @level2name = 'TokenCreated',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha de creación del registro', 
    @level2type = N'COLUMN', @level2name = 'DateCreated',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Token del usuario que actualizó el registro', 
    @level2type = N'COLUMN', @level2name = 'TokenUpdated',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha de última actualización del registro', 
    @level2type = N'COLUMN', @level2name = 'DateUpdated',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'InformationBuyerInvoice';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de condición de operación(1 contado, 2 crédito)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'InformationBuyerInvoice',
    @level2type = N'COLUMN',
    @level2name = N'OperationConditionCode'