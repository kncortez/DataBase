CREATE TABLE [dbo].[KindOfVPBusiness] (
    [IdKindOfVPBusiness]     INT            IDENTITY (1, 1) NOT NULL,
    [KindOfVPNameBussiness]  NVARCHAR (100) NULL,
    [Shorthand]              NVARCHAR (15)  NULL,
    [StatusKindOfVPBusiness] BIT            NULL,
    [TokenCreated]           NVARCHAR (50)  NULL,
    [DateCreated]            DATETIME       NULL,
    [TokenUpdate]            NVARCHAR (50)  NULL,
    [DateUpdated]            DATETIME       NULL,
    [IdCountry]              VARCHAR(2)     NULL, 
    CONSTRAINT [PK_KindOfVPBusiness] PRIMARY KEY CLUSTERED ([IdKindOfVPBusiness] ASC),
    CONSTRAINT [FK_KindOfVPBusiness_CatCountry] FOREIGN KEY (IdCountry) REFERENCES [dbo].[CatCountry](IdCountry)
);


GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del tipo de negocio del punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPBusiness', @level2type=N'COLUMN',@level2name=N'IdKindOfVPBusiness'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del tipo de negocio del punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPBusiness', @level2type=N'COLUMN',@level2name=N'KindOfVPNameBussiness'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Abreviatura de nombre del tipo de negocio del punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPBusiness', @level2type=N'COLUMN',@level2name=N'Shorthand'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'1 activo, 0 inactivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPBusiness', @level2type=N'COLUMN',@level2name=N'StatusKindOfVPBusiness'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPBusiness', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPBusiness', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPBusiness', @level2type=N'COLUMN',@level2name=N'TokenUpdate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPBusiness', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla que contiene la informacion de los tipos de negocio del punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPBusiness'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Id de pais(Referencia a IdCountry de la tabla CatCountry)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'KindOfVPBusiness',
    @level2type = N'COLUMN',
    @level2name = N'IdCountry'