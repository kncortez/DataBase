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
    PRIMARY KEY CLUSTERED ([BlpIdBilling] ASC),
    CONSTRAINT [FKBillingAccount] FOREIGN KEY ([BlpIdAccount]) REFERENCES [dbo].[Account] ([AccIdAccount])
);


GO
CREATE NONCLUSTERED INDEX [IX_BillingProfile_LoadList]
    ON [dbo].[BillingProfile]([VisitPointByClientPortfolioId] ASC);

