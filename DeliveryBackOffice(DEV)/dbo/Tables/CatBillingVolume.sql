CREATE TABLE [dbo].[CatBillingVolume] (
    [IdCatBillingVolume]       INT            IDENTITY (1, 1) NOT NULL,
    [NameBillingVolume]        NVARCHAR (50)  NOT NULL,
    [DescriptionBillingVolume] NVARCHAR (200) NOT NULL,
    [RowStatus]                BIT            NOT NULL,
    [TokenCreated]             NVARCHAR (50)  NOT NULL,
    [DateCreated]              DATETIME       NOT NULL,
    [TokenUpdated]             NVARCHAR (50)  NULL,
    [DateUpdated]              NVARCHAR (50)  NULL,
    CONSTRAINT [PK_CatBillingVolume] PRIMARY KEY CLUSTERED ([IdCatBillingVolume] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha y hora de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBillingVolume', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de usuario que crea el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBillingVolume', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'indica si el articulo esta activo o inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBillingVolume', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'descripción del articulo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBillingVolume', @level2type = N'COLUMN', @level2name = N'DescriptionBillingVolume';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nombre del articulo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBillingVolume', @level2type = N'COLUMN', @level2name = N'NameBillingVolume';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de articulo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBillingVolume', @level2type = N'COLUMN', @level2name = N'IdCatBillingVolume';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Codigo de quien modifico el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatBillingVolume',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificacion',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatBillingVolume',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de pais (Referencia a IdCountry de la tabla CatCountry)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatBillingVolume',
    @level2type = N'COLUMN',
    @level2name = N'IdCountry'