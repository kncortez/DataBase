CREATE TABLE [dbo].[BillingProfile] (
    [BlpIdBilling]                  BIGINT        IDENTITY (1, 1) NOT NULL,
    [BlpIdAccount]                  BIGINT        NOT NULL,
    [BlpName]                       VARCHAR (100) NOT NULL,
    [BlpAddress]                    VARCHAR (200) NOT NULL,
    [BlpTaxId]                      VARCHAR (50)  NULL,
    [BlpRowStatus]                  BIT           NOT NULL,
    [BlpTokenCreated]               VARCHAR (50)  NOT NULL,
    [BlpDateCreated]                DATETIME      NOT NULL,
    [BlpTokenUpdated]               VARCHAR (50)  NULL,
    [BlpDateUpdated]                DATETIME      NULL,
    [VisitPointByClientPortfolioId] INT           NULL,
    [IsDefault]                     BIT           CONSTRAINT [DF_BillingProfile_IsDefault] DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([BlpIdBilling] ASC),
    CONSTRAINT [FKBillingAccount] FOREIGN KEY ([BlpIdAccount]) REFERENCES [dbo].[Account] ([AccIdAccount])
);




GO
CREATE NONCLUSTERED INDEX [IX_BillingProfile_LoadList]
    ON [dbo].[BillingProfile]([VisitPointByClientPortfolioId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para identificar el perfil que se seleccionó como favorito.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingProfile', @level2type = N'COLUMN', @level2name = N'IsDefault';

