CREATE TABLE [dbo].[CatSaleAdvisor] (
    [IdSaleAdvisor]          INT           IDENTITY (1, 1) NOT NULL,
    [SaleAdvisorCode]        NVARCHAR (12) NOT NULL,
    [SaleAdvisorDescription] NVARCHAR (50) NOT NULL,
    [EmployeID]              INT           NOT NULL,
    [SAPSellerID]            INT           NULL,
    [CountryID]              VARCHAR (2)   NOT NULL,
    [SaleAdvisorStatus]      BIT           NOT NULL,
    [TokenCreated]           NVARCHAR (50) NOT NULL,
    [DateCreated]            DATETIME      NOT NULL,
    [TokenUpdated]           NVARCHAR (50) NULL,
    [DateUpdated]            DATETIME      NULL,
    CONSTRAINT [PK_CatSaleAdvisor] PRIMARY KEY CLUSTERED ([IdSaleAdvisor] ASC),
    CONSTRAINT [FK_CatSaleAdvisor_CatCountry] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que contiene informacion del asesor de ventas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSaleAdvisor';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion de fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSaleAdvisor', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSaleAdvisor', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de SAP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSaleAdvisor', @level2type = N'COLUMN', @level2name = N'SAPSellerID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 activo, 0 inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSaleAdvisor', @level2type = N'COLUMN', @level2name = N'SaleAdvisorStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripcion del asesor de ventas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSaleAdvisor', @level2type = N'COLUMN', @level2name = N'SaleAdvisorDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Codigo del asesor de ventas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSaleAdvisor', @level2type = N'COLUMN', @level2name = N'SaleAdvisorCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del asesor de ventas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSaleAdvisor', @level2type = N'COLUMN', @level2name = N'IdSaleAdvisor';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de empleado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSaleAdvisor', @level2type = N'COLUMN', @level2name = N'EmployeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion de fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSaleAdvisor', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion de fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSaleAdvisor', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del pais relacionado con el asesor de ventas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSaleAdvisor', @level2type = N'COLUMN', @level2name = N'CountryID';

