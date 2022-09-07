CREATE TABLE [dbo].[ConfirmedAddress] (
    [NirPhone]               NVARCHAR (4)   NOT NULL,
    [Phone]                  NVARCHAR (15)  NOT NULL,
    [TokenCreated]           VARCHAR (50)   NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [TokenUpdate]            VARCHAR (50)   NULL,
    [DateUpdate]             DATETIME       NULL,
    [RowStatus]              BIT            NOT NULL,
    [AccountId]              BIGINT         NOT NULL,
    [TownshipId]             INT            NOT NULL,
    [NameAddress]            VARCHAR (100)  NOT NULL,
    [Address]                NVARCHAR (600) NOT NULL,
    [AdditionalInstructions] VARCHAR (250)  NULL,
    [CityPlaceId]            INT            NOT NULL,
    [CodeOfReference]        INT            NULL,
    [DeliveryOptionId]       BIGINT         NULL,
    [Latitude]               VARCHAR (20)   NULL,
    [Longitude]              VARCHAR (20)   NULL,
    [Neighborhood]           VARCHAR (50)   NULL,
    [Zone]                   SMALLINT       NULL,
    [CatModuleId]               INT            NULL,
    [StatusAddressId]        INT            NOT NULL,
    CONSTRAINT [PK_ConfirmedAddress] PRIMARY KEY CLUSTERED ([NirPhone] ASC, [Phone] ASC),
    CONSTRAINT [FK_CADD_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_CADD_CityPlace] FOREIGN KEY ([CityPlaceId]) REFERENCES [dbo].[CatCityPlace] ([IdCityPlace]),
    CONSTRAINT [FK_CADD_Module] FOREIGN KEY ([CatModuleId]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FK_CADD_State] FOREIGN KEY ([StatusAddressId]) REFERENCES [dbo].[CatStateConfirmedAddress] ([IdStatus]),
    CONSTRAINT [FK_CADD_Township] FOREIGN KEY ([TownshipId]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FK_CADD_VP] FOREIGN KEY ([CodeOfReference]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Almacena la zona de la dirección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'Zone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que actualiza el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'TokenUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que crea el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Teléfono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código del país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'NirPhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Guarda una referencia como colinia, residencial etc..', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'Neighborhood';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la dirección confirmada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'NameAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Guarda la longitud de una ubicación geográfica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'Longitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Guarda la latitud de una ubicación geográfica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'Latitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del municipio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'TownshipId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado d ela dirección confirmada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'StatusAddressId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del módulo desde donde se crea el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'CatModuleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de la opción de entrega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'DeliveryOptionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del código de referencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'CityPlaceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id referente a la tabla Account', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'AccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en que se realiza la actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'DateUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Día en que se crea el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Codigo referente a punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'CodeOfReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dirección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Instrucciones especiales', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddress', @level2type = N'COLUMN', @level2name = N'AdditionalInstructions';

