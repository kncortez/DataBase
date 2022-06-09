CREATE TYPE [dbo].[TblVPCoverage] AS TABLE (
    [IdVpbySegment] INT NULL,
    [VisitPointId]  INT NOT NULL,
    [HubLogisticId] INT NOT NULL,
    [SegmentId]     INT NOT NULL,
    [RowStatus]     BIT NOT NULL);

