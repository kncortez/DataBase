CREATE TABLE [dbo].[CatTypePromoCard] (
    [IdTypePromoCard] INT           IDENTITY (1, 1) NOT NULL,
    [TypeName]        VARCHAR (50)  NOT NULL,
    [ShortName]       VARCHAR (10)  NOT NULL,
    [TypeDescription] VARCHAR (100) NULL,
    [RowStatus]       BIT           NOT NULL,
    [TokenCreated]    VARCHAR (50)  NOT NULL,
    [DateCreated]     DATETIME      NOT NULL,
    [TokenUpdated]    VARCHAR (50)  NULL,
    [DateUpdated]     DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdTypePromoCard] ASC)
);

