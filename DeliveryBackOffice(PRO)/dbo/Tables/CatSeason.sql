CREATE TABLE [dbo].[CatSeason] (
    [IdSeason]          INT            IDENTITY (1, 1) NOT NULL,
    [SeasonName]        NVARCHAR (50)  NULL,
    [SeasonDescription] NVARCHAR (200) NULL,
    [RowStatus]         BIT            NULL,
    [TokenCreated]      NVARCHAR (50)  NULL,
    [DateCreated]       DATETIME       NULL,
    [TokenUpdated]      NVARCHAR (50)  NULL,
    [DateUpdated]       DATETIME       NULL,
    CONSTRAINT [PK_CatSeason] PRIMARY KEY CLUSTERED ([IdSeason] ASC)
);

