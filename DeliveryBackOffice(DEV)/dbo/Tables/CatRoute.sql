CREATE TABLE [dbo].[CatRoute] (
    [IdRoute]      INT           IDENTITY (1, 1) NOT NULL,
    [CodeRoute]    VARCHAR (100) NOT NULL,
    [Description]  VARCHAR (200) NOT NULL,
    [IdTownship]   INT           NULL,
    [IdTypeRoute]  INT           NULL,
    [Zone]         VARCHAR (50)  NULL,
    [RowStatus]    BIT           NOT NULL,
    [TokenCreated] VARCHAR (50)  NOT NULL,
    [DateCreated]  DATETIME      NOT NULL,
    [TokenUpdated] VARCHAR (50)  NULL,
    [DateUpdated]  DATETIME      NULL,
    [CountryId]    NVARCHAR (2)  NULL,
    PRIMARY KEY CLUSTERED ([IdRoute] ASC),
    CONSTRAINT [FKRouteTownship] FOREIGN KEY ([IdTownship]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FKRouteTypeR] FOREIGN KEY ([IdTypeRoute]) REFERENCES [dbo].[CatTypeRoute] ([IdTypeRoute])
);




GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'identificador de registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatRoute', @level2type=N'COLUMN',@level2name=N'IdRoute'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de la ruta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatRoute', @level2type=N'COLUMN',@level2name=N'CodeRoute'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de la ruta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatRoute', @level2type=N'COLUMN',@level2name=N'Description'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id del departamento(Referencia a IdTownship de la tabla Township)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatRoute', @level2type=N'COLUMN',@level2name=N'IdTownship'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id del tipo de ruta(Refencia a IdTypeRoute de la tabla CatTypeRoute)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatRoute', @level2type=N'COLUMN',@level2name=N'IdTypeRoute'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de zona' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatRoute', @level2type=N'COLUMN',@level2name=N'Zone'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado(1 Activa, 0 Inactivo)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatRoute', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de quien creó el registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatRoute', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatRoute', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de quien modificó el registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatRoute', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatRoute', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de pais', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRoute', @level2type = N'COLUMN', @level2name = N'CountryId';


GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Catalogo de rutas que puede tomar un corier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatRoute'
GO

