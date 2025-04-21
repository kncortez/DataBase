CREATE TABLE [dbo].[RateBySalePipeLine] (
    [IdRatePipeLine] INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RateId]         INT          NOT NULL,
    [SalePipeLineId] INT          NOT NULL,
    [RowStatus]      BIT          NOT NULL,
    [TokenCreated]   VARCHAR (50) NOT NULL,
    [DateCreated]    DATETIME     NOT NULL,
    [TokenUpdated]   VARCHAR (50) NULL,
    [DateUpdated]    DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdRatePipeLine] ASC),
    CONSTRAINT [FKRatePipeLIne] FOREIGN KEY ([RateId]) REFERENCES [dbo].[RateHeader] ([RheId]),
    CONSTRAINT [FKRatePipeLine2] FOREIGN KEY ([SalePipeLineId]) REFERENCES [dbo].[CatSalePipelines] ([IdSalePipeLine])
);

