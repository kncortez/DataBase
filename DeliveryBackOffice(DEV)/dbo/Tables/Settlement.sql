CREATE TABLE [dbo].[Settlement] (
    [IdSettlement]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [Settlement]         NVARCHAR (100) NULL,
    [SettlementLatitud]  DECIMAL (9, 6) NULL,
    [SettlementLongitud] DECIMAL (9, 6) NULL,
    [PostalCode]         NVARCHAR (5)   NULL,
    [SettlementSatus]    BIT            NULL,
    [IdTownship]         INT            NULL,
    [IdProvince]         INT            NULL,
    [IdCountry]          NVARCHAR (2)   NULL,
    [IsSpecial]          BIT            NULL,
    [TokenCreated]       NVARCHAR (50)  NULL,
    [DateCreated]        DATETIME       NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
    [DateUpdated]        DATETIME       NULL,
    CONSTRAINT [PK_Settlement] PRIMARY KEY CLUSTERED ([IdSettlement] ASC),
    CONSTRAINT [FK_Settlement_Province] FOREIGN KEY ([IdProvince]) REFERENCES [dbo].[Province] ([IdProvince]),
    CONSTRAINT [FK_Settlement_Township] FOREIGN KEY ([IdTownship]) REFERENCES [dbo].[Township] ([IdTownship])
);




GO
CREATE NONCLUSTERED INDEX [IX_Settlement_SettlementStatusList]
    ON [dbo].[Settlement]([IdSettlement] ASC, [SettlementSatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_IdTownship_Include]
    ON [dbo].[Settlement]([IdTownship] ASC)
    INCLUDE([Settlement]);

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificación de asentamiento',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'IdSettlement'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción de asentamiento',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'Settlement'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Latitud',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'SettlementLatitud'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Longitud',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'SettlementLongitud'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código postal',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'PostalCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 inactivo) ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'SettlementSatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia municipio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'IdTownship'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia departamento',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'IdProvince'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia país',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'IdCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Especial(1 SI, 0 No)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'IsSpecial'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Datos de asentamientos ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Settlement',
    @level2type = NULL,
    @level2name = NULL
