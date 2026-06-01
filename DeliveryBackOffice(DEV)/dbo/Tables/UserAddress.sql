CREATE TABLE [dbo].[UserAddress] (
    [UadIdAddress]                  BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [UadIdTownship]                 INT            NOT NULL,
    [UadIdAccount]                  BIGINT         NOT NULL,
    [UadIdCountry]                  VARCHAR (2)    NULL,
    [UadFullName]                   VARCHAR (100)  NULL,
    [UadAddress1]                   NVARCHAR (600) NULL,
    [UadAddress2]                   VARCHAR (200)  NULL,
    [UadNirPhone]                   VARCHAR (10)   NOT NULL,
    [UadPhone]                      VARCHAR (100)  NOT NULL,
    [UadAdditionalInstructions]     VARCHAR (250)  NULL,
    [UadRowStatus]                  BIT            NOT NULL,
    [UadTokenCreated]               VARCHAR (50)   NOT NULL,
    [UadDateCreated]                DATE           NOT NULL,
    [UadTokenUpdated]               VARCHAR (50)   NULL,
    [UadDateUpdated]                DATE           NULL,
    [CodeOfReference]               INT            NULL,
    [IdCityPlace]                   INT            NULL,
    [VisitPointByClientPortfolioId] INT            NULL,
    [UadIdSettlement]               BIGINT         NULL,
    [UadIdDeliveryOption]           BIGINT         NULL,
    [UadFavorite]                   BIT            NULL,
    PRIMARY KEY CLUSTERED ([UadIdAddress] ASC),
    CONSTRAINT [FK_IdVisitPointClient] FOREIGN KEY ([CodeOfReference]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [FK_UserAddress_CatCityPlace] FOREIGN KEY ([IdCityPlace]) REFERENCES [dbo].[CatCityPlace] ([IdCityPlace]),
    CONSTRAINT [FKAddressAccount] FOREIGN KEY ([UadIdAccount]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FKAddressTownship] FOREIGN KEY ([UadIdTownship]) REFERENCES [dbo].[Township] ([IdTownship])
);












GO
CREATE NONCLUSTERED INDEX [IX_UserAddress_LoadList]
    ON [dbo].[UserAddress]([VisitPointByClientPortfolioId] ASC, [UadRowStatus] ASC);


GO



GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserAddress', @level2type = N'COLUMN', @level2name = N'UadIdSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserAddress', @level2type = N'COLUMN', @level2name = N'UadIdDeliveryOption';


GO
CREATE NONCLUSTERED INDEX [idx_UadIdAccount_CodeOfReference]
    ON [dbo].[UserAddress]([UadIdAccount] ASC, [CodeOfReference] ASC);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'LIsta de direcciones que tiene el usuario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadIdAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id del municipio(Referencia a idTownship de la tabla Township)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadIdTownship'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de la cuenta de usuario(Referencia a AccIdAccount de la tabla Account)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadIdAccount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id del pais',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadIdCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre completo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadFullName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Primera dirección ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadAddress1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Segundo dirección',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadAddress2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Prefijo de número telefónico',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadNirPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Número telefónico',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicaciones adicionales para entrega',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadAdditionalInstructions'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadTokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificiación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadDateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id del punto de visita(Refencia a CodeOfReference de la tabla VisitPointClient)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'CodeOfReference'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de lugar de la ciudad(Refencia a idCityPlace de la tabla CatCityPlace)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'IdCityPlace'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de la cartera de cliente',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'VisitPointByClientPortfolioId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dirección favorita es unica por cliente y solo es de Origen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserAddress',
    @level2type = N'COLUMN',
    @level2name = N'UadFavorite'
GO



GO
CREATE NONCLUSTERED INDEX [IDX_UadIdAccount_UadRowStatus_UadFavorite_INCLUDE]
    ON [dbo].[UserAddress]([UadIdAccount] ASC, [UadRowStatus] ASC, [UadFavorite] ASC)
    INCLUDE([UadIdTownship], [UadNirPhone], [UadPhone], [CodeOfReference], [IdCityPlace]);


GO
CREATE NONCLUSTERED INDEX [idx_CodeOfReference]
    ON [dbo].[UserAddress]([CodeOfReference] ASC);

