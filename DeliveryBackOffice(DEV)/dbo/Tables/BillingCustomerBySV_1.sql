CREATE TABLE [dbo].[BillingCustomerBySV] (
    [Id]                             INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [IdCustomer]                     INT            NOT NULL,
    [DistrictId]                     INT            NULL,
    [StateId]                        INT            NULL,
    [ActivityId]                     INT            NULL,
    [NRC]                            NVARCHAR (20)  NULL,
    [Nirphone]                       NVARCHAR (5)   NULL,
    [Phone]                          NVARCHAR (20)  NULL,
    [RowStatus]                      BIT            NOT NULL,
    [TokenCreated]                   VARCHAR (50)   NOT NULL,
    [DateCreated]                    DATETIME       NOT NULL,
    [TokenUpdated]                   VARCHAR (50)   NULL,
    [DateUpdated]                    DATETIME       NULL,
    [IdProvince]                     INT            NULL,
    [IdTownship]                     INT            NULL,
    [TypeIdentificationDocumentCode] NVARCHAR (100) NULL,
    [IdDocument]                     NVARCHAR (100) NULL,
    [Inv_type]                       INT            NULL,
    CONSTRAINT [PK_BillingCustomerBySV] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_BillingCustomerBySV_Activity] FOREIGN KEY ([ActivityId]) REFERENCES [dbo].[CatEconomicActivityBySV] ([Id]),
    CONSTRAINT [FK_BillingCustomerBySV_CatTypeDocument] FOREIGN KEY ([Inv_type]) REFERENCES [dbo].[CatTypeDocument] ([IdRegister]),
    CONSTRAINT [FK_BillingCustomerBySV_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_BillingCustomerBySV_District] FOREIGN KEY ([DistrictId]) REFERENCES [dbo].[DistrictByBillingSV] ([Id]),
    CONSTRAINT [FK_BillingCustomerBySV_Province] FOREIGN KEY ([IdProvince]) REFERENCES [dbo].[Province] ([IdProvince]),
    CONSTRAINT [FK_BillingCustomerBySV_State] FOREIGN KEY ([StateId]) REFERENCES [dbo].[StateByBillingSV] ([Id]),
    CONSTRAINT [FK_BillingCustomerBySV_Township] FOREIGN KEY ([IdTownship]) REFERENCES [dbo].[Township] ([IdTownship])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de township relacionado a cliente para El Salvador', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'IdTownship';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de departamento asociado a cliente(Customer) para El Salvador', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'IdProvince';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de quien actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de quien creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1 = activo, 0 = inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de telefono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Prefijo de numero de telefono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'Nirphone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de registro de contribuyente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'NRC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referencia a catalogo de actividad económica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'ActivityId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea  (Referencia a StateByBillingSV)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'StateId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea (Referencia a DistrictByBillingSV)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'DistrictId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foránea al cliente(Customer)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'IdCustomer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la tabla', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV', @level2type = N'COLUMN', @level2name = N'Id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Relación de clientes con su municipio y departamentos para facturación en El Salvador', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingCustomerBySV';

