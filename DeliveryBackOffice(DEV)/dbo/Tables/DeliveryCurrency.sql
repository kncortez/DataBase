CREATE TABLE [dbo].[DeliveryCurrency] (
    [Currency_Id]           INT            NOT NULL,
    [Currency_Name]         NVARCHAR (50)  NOT NULL,
    [Currency_Symbol]       NVARCHAR (10)  NOT NULL,
    [Currency_Description]  NVARCHAR (255) NULL,
    [Currency_Order]        INT            NOT NULL,
    [Currency_IdCountry]    NVARCHAR (10)  NOT NULL,
    [Currency_Status]       INT            NOT NULL,
    [Currency_TokenCreated] NVARCHAR (50)  NOT NULL,
    [Currency_DateCreated]  DATETIME       NOT NULL,
    [Currency_TokenUpdate]  NVARCHAR (50)  NULL,
    [Currency_DateUpdate]   DATETIME       NULL,
    [IdCurrencyCOD]         INT            NULL,
    [DefaultPerCountry]     INT            NULL,
    CONSTRAINT [PK_CMS_PRM_TYPE_OF_CURRENCY] PRIMARY KEY CLUSTERED ([Currency_Id] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'Currency_Id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de la divisa',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'Currency_Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Simbolo de la divisa',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'Currency_Symbol'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripcion de la divisa',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'Currency_Description'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Orden de la divisa',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'Currency_Order'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Codigo de pais al que pertenece',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'Currency_IdCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'Currency_Status'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Codigo de quien creo el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'Currency_TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creacion',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'Currency_DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Codigo de quien modifico el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'Currency_TokenUpdate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificacion',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'Currency_DateUpdate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia al id de la tabla catCurrencyCOD',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'IdCurrencyCOD'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Moneda por defecto por pais',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'DefaultPerCountry'