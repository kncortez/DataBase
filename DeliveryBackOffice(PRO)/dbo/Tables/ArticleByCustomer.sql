CREATE TABLE [dbo].[ArticleByCustomer] (
    [AbcId]            INT             IDENTITY (1, 1) NOT NULL,
    [AbcIdArticle]     INT             NOT NULL,
    [AbcIdCustomer]    INT             NULL,
    [AbcRowStatus]     BIT             NOT NULL,
    [AbcTokenCreated]  VARCHAR (50)    NOT NULL,
    [AbcDateCreated]   DATETIME        NOT NULL,
    [AbcTokenUpdated]  VARCHAR (50)    NULL,
    [AbcDateUpdated]   DATETIME        NULL,
    [Code]             NVARCHAR (20)   NULL,
    [PriceDefault]     DECIMAL (12, 2) NULL,
    [Height]           DECIMAL (18, 2) NULL,
    [Width]            DECIMAL (18, 2) NULL,
    [Length]           DECIMAL (18, 2) NULL,
    [MassWeight]       DECIMAL (18, 2) NULL,
    [VolumetricWeight] DECIMAL (18, 2) NULL,
    [ShowDefault]      BIT             NULL,
    PRIMARY KEY CLUSTERED ([AbcId] ASC),
    CONSTRAINT [FKArticleCustom] FOREIGN KEY ([AbcIdArticle]) REFERENCES [dbo].[CatArticle] ([ArtId]),
    CONSTRAINT [FKCustomArticle] FOREIGN KEY ([AbcIdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [AK_Password] UNIQUE NONCLUSTERED ([Code] ASC)
);

