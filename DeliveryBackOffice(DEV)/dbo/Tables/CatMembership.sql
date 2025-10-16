CREATE TABLE [dbo].[CatMembership] (
    [IdCatMembership]                INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [MembershipName]                 NVARCHAR (50)   NOT NULL,
    [MembershipDescription]          NVARCHAR (300)  NOT NULL,
    [MembershipCost]                 DECIMAL (18, 2) NOT NULL,
    [MembershipFixedValue]           INT             NOT NULL,
    [MembershipMaxServiceFixedValue] INT             NOT NULL,
    [MembershipValidity]             INT             NOT NULL,
    [RowStatus]                      BIT             NOT NULL,
    [TokenCreated]                   NVARCHAR (50)   NOT NULL,
    [DateCreated]                    DATETIME        NOT NULL,
    [TokenUpdated]                   NVARCHAR (50)   NULL,
    [DateUpdated]                    DATETIME        NULL,
    [Icon]                           NVARCHAR (50)   NULL,
    [NextSalesPackageBanner]         NVARCHAR (200)  NULL,
    [CatProductCategoryId]           INT             NULL,
    [Tag]                            NVARCHAR (100)  NULL,
    [Position]                       INT             NULL,
    [IdCountry]                      VARCHAR (2)     NULL,
    [IdCatCurrencyCOD]               INT             NULL,
    CONSTRAINT [PK_CatMembership] PRIMARY KEY CLUSTERED ([IdCatMembership] ASC),
    CONSTRAINT [FK_CatMembership_CatCountry] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    CONSTRAINT [FK_CatMembership_CatCurrencyCOD] FOREIGN KEY ([IdCatCurrencyCOD]) REFERENCES [dbo].[CatCurrencyCOD] ([IdCatCurrencyCOD])
);








GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'IdCatMembership'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de la membresia.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'MembershipName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de la membresia.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'MembershipDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Costo monetario para comprar la membresia.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'MembershipCost'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto fijo de servicios de guía, limitado a una cantidad.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'MembershipFixedValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad maxima de servicios los cuales tendran un monto fijo.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'MembershipMaxServiceFixedValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tiempo, en días, que será valida la membresia.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'MembershipValidity'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Último token de actualización del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última fecha de actualización del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo de ícono configurable' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'Icon'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de banner a desplegar cuando servicios de monto fijo esten proximos a acabarse' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'NextSalesPackageBanner'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'País de la membresía ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'IdCountry'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Divisa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'IdCatCurrencyCOD'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de catalogo de membresias.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership'
GO


GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'etiqueta de identificación ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'Tag'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ordenar membresia por posición' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'Position'
