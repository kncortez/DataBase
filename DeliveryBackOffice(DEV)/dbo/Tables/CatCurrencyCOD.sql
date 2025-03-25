CREATE TABLE [dbo].[CatCurrencyCOD] (
    [IdCatCurrencyCOD] INT           IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (50) NOT NULL,
    [Symbol]           NVARCHAR (3)  NULL,
    [CodeISO]          NVARCHAR (3)  NOT NULL,
    [NumISO]           INT           NOT NULL,
    [RowStatus]        BIT           CONSTRAINT [DF_CatCurrencyCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]     NVARCHAR (50) NOT NULL,
    [DateCreated]      DATETIME      CONSTRAINT [DF_CatCurrencyCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]     NVARCHAR (50) NULL,
    [DateUpdated]      DATETIME      NULL,
    CONSTRAINT [PK_CatCurrencyCOD_IdCatCurrencyCOD] PRIMARY KEY CLUSTERED ([IdCatCurrencyCOD] ASC),
    CONSTRAINT [UK_CatCurrencyCOD_Name_CodeISO_NumISO] UNIQUE NONCLUSTERED ([Name] ASC, [CodeISO] ASC, [NumISO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCurrencyCOD', @level2type = N'COLUMN', @level2name = N'IdCatCurrencyCOD';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la moneda.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCurrencyCOD', @level2type = N'COLUMN', @level2name = N'Name';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Simbolo de la moneda', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCurrencyCOD', @level2type = N'COLUMN', @level2name = N'Symbol';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código ISO de la moneda.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCurrencyCOD', @level2type = N'COLUMN', @level2name = N'CodeISO';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código numérico ISO de la moneda.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCurrencyCOD', @level2type = N'COLUMN', @level2name = N'NumISO';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado (1 Activo, 0 Inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCurrencyCOD', @level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCurrencyCOD', @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en que se creó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCurrencyCOD', @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de última actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCurrencyCOD', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCurrencyCOD', @level2type = N'COLUMN', @level2name = N'DateUpdated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla que almacena las monedas que utilizan los sistemas.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatCurrencyCOD',
    @level2type = NULL,
    @level2name = NULL

