CREATE TABLE [dbo].[CustomerTownshipMapping] (
    [IdCustomerTownshipMapping] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TownshipId]                INT            NOT NULL,
    [CodeOfReference]           INT            NOT NULL,
    [CountryId]                 NVARCHAR (5)   NOT NULL,
    [ExternalTownshipId]        NVARCHAR (200) NULL,
    [ExternalTownshipName]      NVARCHAR (200) NULL,
    [ExternalProvinceId]        NVARCHAR (200) NULL,
    [ExternalProvinceName]      NVARCHAR (200) NULL,
    [RowStatus]                 BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]              NVARCHAR (50)  NOT NULL,
    [DateCreated]               DATETIME       DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]              NVARCHAR (50)  NULL,
    [DateUpdated]               DATETIME       NULL,
    CONSTRAINT [PK_CustomerTownshipMapping] PRIMARY KEY CLUSTERED ([IdCustomerTownshipMapping] ASC),
    CONSTRAINT [CHK_CustomerTownshipMapping_ExternalData] CHECK ([ExternalTownshipId] IS NOT NULL OR [ExternalTownshipName] IS NOT NULL),
    CONSTRAINT [FK_CustomerTownshipMapping_Township] FOREIGN KEY ([TownshipId]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FK_CustomerTownshipMapping_VisitPointClient] FOREIGN KEY ([CodeOfReference]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);


GO
CREATE NONCLUSTERED INDEX [IX_CustomerTownshipMapping_IdTownship]
    ON [dbo].[CustomerTownshipMapping]([TownshipId] ASC, [RowStatus] ASC)
    INCLUDE([CodeOfReference], [CountryId], [ExternalTownshipId], [ExternalTownshipName], [ExternalProvinceName]);


GO
CREATE NONCLUSTERED INDEX [IX_CustomerTownshipMapping_Customer_ExternalNames]
    ON [dbo].[CustomerTownshipMapping]([CodeOfReference] ASC, [ExternalTownshipName] ASC, [ExternalProvinceName] ASC)
    INCLUDE([TownshipId], [CountryId], [RowStatus]);


GO
CREATE NONCLUSTERED INDEX [IX_CustomerTownshipMapping_Customer_ExternalId]
    ON [dbo].[CustomerTownshipMapping]([CodeOfReference] ASC, [ExternalTownshipId] ASC)
    INCLUDE([TownshipId], [CountryId], [RowStatus]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CustomerTownshipMapping_ExternalId]
    ON [dbo].[CustomerTownshipMapping]([CodeOfReference] ASC, [ExternalTownshipId] ASC) WHERE ([ExternalTownshipId] IS NOT NULL);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de última actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1 activo, 0 inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre externo que utiliza el cliente para este departamento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'ExternalProvinceName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID o código que utiliza el cliente externo para este departamento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'ExternalProvinceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre externo que utiliza el cliente para este municipio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'ExternalTownshipName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID o código que utiliza el cliente externo para este municipio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'ExternalTownshipId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de país ISO', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'CountryId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Codigo de referencia del punto de visita, tabla VisitPointClient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'CodeOfReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foránea del municipio interno de Forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'TownshipId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador principal del mapeo de municipio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'IdCustomerTownshipMapping';

