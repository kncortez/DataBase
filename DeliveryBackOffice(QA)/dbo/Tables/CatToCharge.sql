CREATE TABLE [dbo].[CatToCharge] (
    [IdToCharge]       INT             IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (50)   NOT NULL,
    [Description]      NVARCHAR (100)  NULL,
    [DescriptionLabel] NVARCHAR (100)  NULL,
    [Value]            DECIMAL (18, 2) NOT NULL,
    [UnitId]           INT             NULL,
    [CountryId]        VARCHAR (2)     NULL,
    [CurrencyId]       INT             NULL,
    [RowStatus]        BIT             NOT NULL,
    [TokenCreated]     NVARCHAR (50)   NOT NULL,
    [DateCreated]      DATETIME        NOT NULL,
    [TokenUpdated]     NVARCHAR (50)   NULL,
    [DateUpdated]      DATETIME        NULL,
    CONSTRAINT [PK_CatToCharge] PRIMARY KEY CLUSTERED ([IdToCharge] ASC),
    CONSTRAINT [FK_CatToCharge_CatCountry] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    CONSTRAINT [FK_CatToCharge_CatToCharge] FOREIGN KEY ([IdToCharge]) REFERENCES [dbo].[CatToCharge] ([IdToCharge]),
    CONSTRAINT [FK_CatToCharge_DeliveryCurrency] FOREIGN KEY ([CurrencyId]) REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id]),
    CONSTRAINT [FK_CatToCharge_Unit] FOREIGN KEY ([UnitId]) REFERENCES [dbo].[Unit] ([IdUnit])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogo por defecto de los monto a cobrar a los clientes del portal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatToCharge';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificado de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatToCharge', @level2type = N'COLUMN', @level2name = N'IdToCharge';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de monto a cobrar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatToCharge', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del monto a cobrar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatToCharge', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor o porcentaje', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatToCharge', @level2type = N'COLUMN', @level2name = N'Value';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unidad de media valor o porcentaje', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatToCharge', @level2type = N'COLUMN', @level2name = N'UnitId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'País al que pertenece el cobro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatToCharge', @level2type = N'COLUMN', @level2name = N'CountryId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Moneda', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatToCharge', @level2type = N'COLUMN', @level2name = N'CurrencyId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado activo o no', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatToCharge', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatToCharge', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatToCharge', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatToCharge', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatToCharge', @level2type = N'COLUMN', @level2name = N'DateUpdated';

