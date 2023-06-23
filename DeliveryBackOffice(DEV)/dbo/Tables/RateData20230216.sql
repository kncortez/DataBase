CREATE TABLE [dbo].[RateData20230216] (
    [IdRateData]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [RateId]            INT             NOT NULL,
    [TypeServiceId]     INT             NULL,
    [TypeSegmentId]     INT             NULL,
    [HubSourceId]       INT             NULL,
    [HubDestinyId]      INT             NULL,
    [ArticleId]         INT             NULL,
    [RateValue]         DECIMAL (14, 2) NOT NULL,
    [RowStatus]         BIT             NOT NULL,
    [TokenCreated]      VARCHAR (50)    NOT NULL,
    [DateCreated]       DATETIME        NOT NULL,
    [TokenUpdated]      VARCHAR (50)    NULL,
    [DateUpdated]       DATETIME        NULL,
    [LimitHourDelivery] TIME (7)        NULL,
    [LimitHourPickup]   TIME (7)        NULL,
    [WeightFrom]        DECIMAL (12, 2) NULL,
    [WeightTo]          DECIMAL (12, 2) NULL
);

