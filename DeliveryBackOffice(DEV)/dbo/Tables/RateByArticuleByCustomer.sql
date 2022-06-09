CREATE TABLE [dbo].[RateByArticuleByCustomer] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [ArticuleByCustomerId] INT             NOT NULL,
    [SegmetId]             INT             NOT NULL,
    [Price]                DECIMAL (12, 2) NOT NULL,
    [RmsRowStatus]         BIT             NOT NULL,
    [TokenCreated]         VARCHAR (50)    NOT NULL,
    [DateCreated]          DATETIME        NOT NULL,
    [TokenUpdated]         VARCHAR (50)    NULL,
    [DateUpdated]          DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FKRateCustomerArticule] FOREIGN KEY ([ArticuleByCustomerId]) REFERENCES [dbo].[ArticleByCustomer] ([AbcId]),
    CONSTRAINT [FKRateCutomerSegment] FOREIGN KEY ([SegmetId]) REFERENCES [dbo].[CatRateSegment] ([CrsId])
);

