CREATE TABLE [dbo].[UserAddress] (
    [UadIdAddress]                  BIGINT         IDENTITY (1, 1) NOT NULL,
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
    PRIMARY KEY CLUSTERED ([UadIdAddress] ASC),
    CONSTRAINT [FK_IdVisitPointClient] FOREIGN KEY ([CodeOfReference]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [FK_UserAddress_CatCityPlace] FOREIGN KEY ([IdCityPlace]) REFERENCES [dbo].[CatCityPlace] ([IdCityPlace]),
    CONSTRAINT [FKAddressAccount] FOREIGN KEY ([UadIdAccount]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FKAddressTownship] FOREIGN KEY ([UadIdTownship]) REFERENCES [dbo].[Township] ([IdTownship])
);


GO
CREATE NONCLUSTERED INDEX [IX_UserAddress_DeliveryOptionList]
    ON [dbo].[UserAddress]([UadIdDeliveryOption] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_UserAddress_LoadList]
    ON [dbo].[UserAddress]([VisitPointByClientPortfolioId] ASC, [UadRowStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_UserAddress_SettlementList]
    ON [dbo].[UserAddress]([UadIdSettlement] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_UserAddress_TownshipList]
    ON [dbo].[UserAddress]([UadIdTownship] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserAddress', @level2type = N'COLUMN', @level2name = N'UadIdSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserAddress', @level2type = N'COLUMN', @level2name = N'UadIdDeliveryOption';

