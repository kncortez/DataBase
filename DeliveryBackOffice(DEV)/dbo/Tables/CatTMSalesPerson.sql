CREATE TABLE [dbo].[CatTMSalesPerson] (
    [IdCatTMSalesPerson] INT            IDENTITY (1, 1) NOT NULL,
    [Code]               NVARCHAR (25)  NOT NULL,
    [FirstName]          NVARCHAR (100) NOT NULL,
    [LastName]           NVARCHAR (100) NOT NULL,
    [Country]            NVARCHAR (25)  NOT NULL,
    [RegisterUserId]     BIGINT         NOT NULL,
    [RowStatus]          BIT            NOT NULL,
    [DateCreated]        DATETIME       NOT NULL,
    [TokenCreated]       NVARCHAR (50)  NOT NULL,
    [DateUpdated]        DATETIME       NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdCatTMSalesPerson] ASC),
    CONSTRAINT [FK_CatTMSalesPerson_RegisterUser] FOREIGN KEY ([RegisterUserId]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);

