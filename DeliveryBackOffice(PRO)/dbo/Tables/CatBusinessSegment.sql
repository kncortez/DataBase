CREATE TABLE [dbo].[CatBusinessSegment] (
    [IdBusinessSegment]          INT            IDENTITY (1, 1) NOT NULL,
    [BusinessSegmentName]        NVARCHAR (75)  NOT NULL,
    [BusinessSegmentDescription] NVARCHAR (200) NOT NULL,
    [RowStatus]                  BIT            NOT NULL,
    [TokenCreated]               NVARCHAR (50)  NOT NULL,
    [DateCreated]                DATETIME       NOT NULL,
    [TokenUpdated]               NVARCHAR (50)  NULL,
    [DateUpdated]                DATETIME       NULL,
    CONSTRAINT [PK_CatBusinessSegment] PRIMARY KEY CLUSTERED ([IdBusinessSegment] ASC)
);

