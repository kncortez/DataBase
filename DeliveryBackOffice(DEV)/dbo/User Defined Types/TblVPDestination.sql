CREATE TYPE [dbo].[TblVPDestination] AS TABLE (
    [IdVPSource]  INT NOT NULL,
    [IDVPDestiny] INT NOT NULL,
    [IsGuard]     BIT NULL,
    [IsTransit]   BIT NULL,
    [IsDefault]   BIT NULL,
    [RowStatus]   BIT NULL);

