CREATE TABLE [dbo].[GuideBatch] (
    [IdRow]                         BIGINT        IDENTITY (1, 1) NOT NULL,
    [IdBatch]                       BIGINT        NOT NULL,
    [IdUser]                        BIGINT        NOT NULL,
    [GuideSeries]                   VARCHAR (100) NOT NULL,
    [GuideNumber]                   VARCHAR (100) NOT NULL,
    [IdVisitPointByClientPortfolio] BIGINT        NOT NULL,
    [IdAddress]                     BIGINT        NOT NULL,
    [Status]                        INT           NOT NULL,
    [RowStatus]                     BIT           NOT NULL,
    [TokenCreated]                  VARCHAR (50)  NOT NULL,
    [DateCreated]                   DATETIME      NOT NULL,
    [TokenUpdated]                  VARCHAR (50)  NULL,
    [DateUpdated]                   DATETIME      NULL,
    CONSTRAINT [PKGuideBatch] PRIMARY KEY CLUSTERED ([IdRow] ASC),
    CONSTRAINT [FKRegisterUserBatch] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser]),
    CONSTRAINT [FKUserAddressBatch] FOREIGN KEY ([IdAddress]) REFERENCES [dbo].[UserAddress] ([UadIdAddress])
);

