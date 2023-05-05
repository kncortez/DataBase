CREATE TABLE [dbo].[ExpressAccountServiceCart] (
    [IdExpressAccountServiceCart] BIGINT        IDENTITY (1, 1) NOT NULL,
    [AccountId]                   BIGINT        NOT NULL,
    [CustomerId]                  INT           NULL,
    [CustomerPortfolioId]         INT           NULL,
    [IsPending]                   BIT           NOT NULL,
    [RowStatus]                   BIT           NOT NULL,
    [DateCreated]                 DATETIME      NOT NULL,
    [TokenCreated]                NVARCHAR (50) NOT NULL,
    [DateUpdated]                 DATETIME      NULL,
    [TokenUpdated]                NVARCHAR (50) NULL,
    CONSTRAINT [PK_ExpressAccountServiceCart] PRIMARY KEY CLUSTERED ([IdExpressAccountServiceCart] ASC)
);

