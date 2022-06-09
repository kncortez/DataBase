CREATE TYPE [dbo].[TblGuidePrice] AS TABLE (
    [GuideSerie]  NVARCHAR (2)    NOT NULL,
    [GuideNumber] INT             NOT NULL,
    [GuidePrice]  DECIMAL (12, 2) NOT NULL);

