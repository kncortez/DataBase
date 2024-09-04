CREATE TABLE [dbo].[CatConditionOfPayment] (
    [IdConditionOfPayment]          INT            IDENTITY (1, 1) NOT NULL,
    [ConditionOfPayment]            NVARCHAR (50)  NOT NULL,
    [ConditionOfPaymenDescription]  NVARCHAR (200) NULL,
    [ConditionOfPaymenAbbreviation] NVARCHAR (20)  NULL,
    [RowStatus]                     BIT            CONSTRAINT [DF_CatConditionOfPayment_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]                  NVARCHAR (50)  NOT NULL,
    [DateCreated]                   DATETIME       NOT NULL,
    [TokenUpdated]                  NVARCHAR (50)  NULL,
    [DateUpdated]                   DATETIME       NULL,
    [IdCountry]                     VARCHAR(2)     NULL,
    CONSTRAINT [PK_CatConditionOfPayment] PRIMARY KEY CLUSTERED ([IdConditionOfPayment] ASC),
    CONSTRAINT [FK_CatConditionOfPayment_CatCountry] FOREIGN KEY (IdCountry) REFERENCES [dbo].[CatCountry](IdCountry)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatConditionOfPayment',
    @level2type = N'COLUMN',
    @level2name = N'IdConditionOfPayment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catalogo de condiciones de pago',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatConditionOfPayment',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'nombre de condicion de pago',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatConditionOfPayment',
    @level2type = N'COLUMN',
    @level2name = N'ConditionOfPayment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'descripcion de la condicion de pago',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatConditionOfPayment',
    @level2type = N'COLUMN',
    @level2name = N'ConditionOfPaymenDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'abreviatura de la condicion de pago',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatConditionOfPayment',
    @level2type = N'COLUMN',
    @level2name = N'ConditionOfPaymenAbbreviation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado (1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatConditionOfPayment',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Codigo de quien creo el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatConditionOfPayment',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creacion',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatConditionOfPayment',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Codigo de quien modifico el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatConditionOfPayment',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificacion',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatConditionOfPayment',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Id del pais donde se utiliza la condicion (CatCountry)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatConditionOfPayment',
    @level2type = N'COLUMN',
    @level2name = N'IdCountry'