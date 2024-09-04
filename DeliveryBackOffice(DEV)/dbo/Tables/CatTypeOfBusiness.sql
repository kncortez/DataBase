CREATE TABLE [dbo].[CatTypeOfBusiness] (
    [IdTypeOfBusiness]          INT            IDENTITY (1, 1) NOT NULL,
    [TypeOfBusinessName]        NVARCHAR (50)  NULL,
    [TypeOfBusinessDescription] NVARCHAR (200) NULL,
    [CountryID]                 VARCHAR (2)    NULL,
    [RowStatus]                 BIT            NULL,
    [TokenCreated]              NVARCHAR (50)  NULL,
    [DateCreated]               DATETIME       NULL,
    [TokenUpdated]              NVARCHAR (50)  NULL,
    [DateUpdated]               DATETIME       NULL,
    CONSTRAINT [PK_CatTypeOfBusiness] PRIMARY KEY CLUSTERED ([IdTypeOfBusiness] ASC)
);

GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del tipo de negocio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeOfBusiness', @level2type=N'COLUMN',@level2name=N'IdTypeOfBusiness'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del tipo de negocio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeOfBusiness', @level2type=N'COLUMN',@level2name=N'TypeOfBusinessName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion del tipo de negocio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeOfBusiness', @level2type=N'COLUMN',@level2name=N'TypeOfBusinessDescription'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del pais al que pertenece el tipo de negocio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeOfBusiness', @level2type=N'COLUMN',@level2name=N'CountryID'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'1 activo, 0 inactivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeOfBusiness', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeOfBusiness', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeOfBusiness', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeOfBusiness', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeOfBusiness', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla que contiene la informacion de los diferentes tipos de negocios' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeOfBusiness'
GO