CREATE TABLE [dbo].[DeliveryFavCOD] (
    [IdDeliveryFavCOD]              INT          IDENTITY (1, 1) NOT NULL,
    [AliasFavCOD]                   VARCHAR (50) NULL,
    [NameAccountFavCOD]             VARCHAR (50) NULL,
    [TypeAccountFavCOD]             VARCHAR (50) NULL,
    [DocumentIdFavCOD]              VARCHAR (50) NULL,
    [StatusFavCOD]                  INT          NULL,
    [IdAccountFavCOD]               INT          NULL,
    [TokenCreated]                  VARCHAR (50) NULL,
    [DateCreated]                   DATETIME     NULL,
    [TokenUpdate]                   VARCHAR (50) NULL,
    [DateUpdate]                    DATETIME     NULL,
    [IdBank]                        INT          NULL,
    [NumberAccFavCOD]               VARCHAR (50) NULL,
    [VisitPointByClientPortfolioId] INT          NULL,
    [IsDefault]                     BIT          CONSTRAINT [DF_DeliveryFavCOD_IsDefault] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DeliveryFavCOD] PRIMARY KEY CLUSTERED ([IdDeliveryFavCOD] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_DeliveryFavCOD_LoadList]
    ON [dbo].[DeliveryFavCOD]([VisitPointByClientPortfolioId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DeliveryFavCOD_BankStatusList]
    ON [dbo].[DeliveryFavCOD]([StatusFavCOD] ASC, [IdBank] ASC);

