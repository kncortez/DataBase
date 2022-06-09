CREATE TABLE [dbo].[CatTypeService] (
    [CtsId]             INT           IDENTITY (1, 1) NOT NULL,
    [CtsName]           VARCHAR (100) NOT NULL,
    [CtsShortName]      VARCHAR (3)   NOT NULL,
    [CtsDescription]    VARCHAR (200) NULL,
    [CtsRowStatus]      BIT           NOT NULL,
    [CtsTokenCreated]   VARCHAR (50)  NOT NULL,
    [CtsDateCreated]    DATETIME      NOT NULL,
    [CtsTokenUpdated]   VARCHAR (50)  NULL,
    [CtsDateUpdated]    DATETIME      NULL,
    [RateGroup]         INT           NULL,
    [LimitHourDelivery] TIME (7)      NULL,
    [LimitHourPickup]   TIME (7)      NULL,
    PRIMARY KEY CLUSTERED ([CtsId] ASC)
);

