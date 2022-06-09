CREATE TABLE [dbo].[TempGuideBatch] (
    [IdUser]                        BIGINT        NOT NULL,
    [GuideNumber]                   VARCHAR (100) NOT NULL,
    [IdBatch]                       BIGINT        NOT NULL,
    [IdVisitPointByClientPortfolio] BIGINT        NOT NULL,
    [IdAddress]                     BIGINT        NOT NULL,
    [Status]                        INT           NOT NULL,
    [RowStatus]                     BIT           NOT NULL,
    [TokenCreated]                  VARCHAR (50)  NOT NULL,
    [DateCreated]                   DATETIME      NOT NULL,
    [TokenUpdated]                  VARCHAR (50)  NULL,
    [DateUpdated]                   DATETIME      NULL
);

