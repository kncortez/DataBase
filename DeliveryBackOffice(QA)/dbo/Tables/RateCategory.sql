CREATE TABLE [dbo].[RateCategory] (
    [IdRateCategory]     INT            IDENTITY (1, 1) NOT NULL,
    [TitleName]          NVARCHAR (50)  NULL,
    [RateCatDescription] NVARCHAR (200) NULL,
    [RateCatStatus]      BIT            NULL,
    [TokenCreated]       NVARCHAR (50)  NULL,
    [DateCreated]        DATETIME       NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
    [DateUpdated]        DATETIME       NULL,
    CONSTRAINT [PK_RateCategory] PRIMARY KEY CLUSTERED ([IdRateCategory] ASC)
);

