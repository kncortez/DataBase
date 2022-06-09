CREATE TYPE [dbo].[TblBatchGuides] AS TABLE (
    [RowNumber]    INT           NULL,
    [GuideId]      NVARCHAR (50) NULL,
    [GuideSerie]   NVARCHAR (2)  NULL,
    [GuideNumber]  INT           NULL,
    [GuidePiece]   INT           NULL,
    [InternalCode] INT           NULL);

