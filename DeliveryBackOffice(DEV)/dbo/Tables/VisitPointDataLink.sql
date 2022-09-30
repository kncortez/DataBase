CREATE TABLE [dbo].[VisitPointDataLink] (
    [IdVisitPointDataLink]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [CustomerId]             INT           NOT NULL,
    [VisitPointId]           INT           NOT NULL,
    [ServiceToken]           NVARCHAR (50) NOT NULL,
    [ServiceTokenExpiration] DATETIME      NULL,
    [DataLinkStatusId]       INT           NOT NULL,
    [RowStatus]              BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]           NVARCHAR (50) NOT NULL,
    [DateCreated]            DATETIME      NOT NULL,
    [TokenUpdated]           NVARCHAR (50) NULL,
    [DateUPdated]            DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdVisitPointDataLink] ASC),
    CONSTRAINT [FK_VisitPointDataLink_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_VisitPointDataLink_DataLinkStatus] FOREIGN KEY ([DataLinkStatusId]) REFERENCES [dbo].[CatDataLinkStatus] ([IdCatDataLinkStatus]),
    CONSTRAINT [FK_VisitPointDataLink_VisitPoint] FOREIGN KEY ([VisitPointId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);

