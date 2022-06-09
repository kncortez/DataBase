CREATE TABLE [dbo].[ExtPlatRoute] (
    [IdExtPlatRoute]  INT           IDENTITY (1, 1) NOT NULL,
    [ExtPlatformId]   INT           NOT NULL,
    [IdPlatformRoute] NVARCHAR (50) NOT NULL,
    [RowStatus]       BIT           NOT NULL,
    [TokenCreated]    NVARCHAR (50) NOT NULL,
    [DateCreated]     DATETIME      NOT NULL,
    [TokenUpdated]    NVARCHAR (50) NULL,
    [DateUpdated]     DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdExtPlatRoute] ASC),
    CONSTRAINT [FK_ExtPlatRoute_ExternalPlatform] FOREIGN KEY ([ExtPlatformId]) REFERENCES [dbo].[CatExternalPlatform] ([IdExternalPlatform])
);

