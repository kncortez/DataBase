CREATE TABLE [dbo].[TownshipDistrictByBillingSV](
    [IdTownshipDistrictByBillingSV] [int] IDENTITY(1,1) NOT NULL,
    [StateByBillingSVId] [int] NOT NULL,
    [TownshipId] [int] NOT NULL,
    [DistrictId] [int] NOT NULL,
    [RowStatus] [bit] NOT NULL,
    [TokenCreated] [varchar](50) NOT NULL,
    [DateCreated] [datetime] NOT NULL,
    [TokenUpdated] [varchar](50) NULL,
    [Datepdated] [datetime] NULL,
    CONSTRAINT [PK_TownshipDistrictByBillingSV] PRIMARY KEY CLUSTERED ( [IdTownshipDistrictByBillingSV] ASC),
    CONSTRAINT [FK_TownshipDistrictByBillingSV_StateByBillingSV] FOREIGN KEY([StateByBillingSVId]) REFERENCES [dbo].[StateByBillingSV] ([Id]),
    CONSTRAINT [FK_TownshipDistrictByBillingSV_Township] FOREIGN KEY([IdTownshipDistrictByBillingSV]) REFERENCES [dbo].[Township] ([IdTownship]),
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria que identifica el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TownshipDistrictByBillingSV', @level2type = N'COLUMN', @level2name = N'IdTownshipDistrictByBillingSV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que hace referncia a la tabla StateByBillingSVId.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TownshipDistrictByBillingSV', @level2type = N'COLUMN', @level2name = N'StateByBillingSVId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'LLave foranea que hace referencia a la tabla Township.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TownshipDistrictByBillingSV', @level2type = N'COLUMN', @level2name = N'TownshipId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que hace referencia a la tabla DistrictByBillingSVId.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TownshipDistrictByBillingSV', @level2type = N'COLUMN', @level2name = N'DistrictId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TownshipDistrictByBillingSV', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que actualizó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TownshipDistrictByBillingSV', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TownshipDistrictByBillingSV', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que generó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TownshipDistrictByBillingSV', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TownshipDistrictByBillingSV', @level2type = N'COLUMN', @level2name = N'RowStatus';