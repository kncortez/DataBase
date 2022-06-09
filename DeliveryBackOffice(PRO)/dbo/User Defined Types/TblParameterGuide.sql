CREATE TYPE [dbo].[TblParameterGuide] AS TABLE (
    [GuideSerie]               NVARCHAR (2)     NOT NULL,
    [GuideNumber]              INT              NOT NULL,
    [GuideLatitude]            DECIMAL (19, 16) NULL,
    [GuideLongitude]           DECIMAL (19, 16) NULL,
    [GuideServiceWindow1Start] DATETIME         NULL,
    [GuideServiceWindow1End]   DATETIME         NULL,
    [GuideServiceWindow2Start] DATETIME         NULL,
    [GuideServiceWindow2End]   DATETIME         NULL);

