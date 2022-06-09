CREATE TABLE [dbo].[RateData] (
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
    [WeightTo]          DECIMAL (12, 2) NULL,
    PRIMARY KEY CLUSTERED ([IdRateData] ASC),
    CONSTRAINT [FKRateArticuleId] FOREIGN KEY ([ArticleId]) REFERENCES [dbo].[ArticleByCustomer] ([AbcId]),
    CONSTRAINT [FKRateDetId] FOREIGN KEY ([RateId]) REFERENCES [dbo].[RateHeader] ([RheId]),
    CONSTRAINT [FKRateHubDestinyId] FOREIGN KEY ([HubDestinyId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FKRateHubSourceId] FOREIGN KEY ([HubSourceId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FKRateSegmentId] FOREIGN KEY ([TypeSegmentId]) REFERENCES [dbo].[CatRateSegment] ([CrsId]),
    CONSTRAINT [FKRateServiceId] FOREIGN KEY ([TypeServiceId]) REFERENCES [dbo].[CatTypeService] ([CtsId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Peso desde en tarifario por peso.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'WeightFrom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Peso hasta en tarifario por peso.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'WeightTo';

