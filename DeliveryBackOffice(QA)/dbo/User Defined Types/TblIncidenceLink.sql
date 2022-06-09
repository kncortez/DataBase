CREATE TYPE [dbo].[TblIncidenceLink] AS TABLE (
    [RowNumber]     INT           NOT NULL,
    [IncidenceId]   INT           NULL,
    [PathIncidence] VARCHAR (200) NULL,
    [RowStatus]     BIT           NULL,
    [TokenCreated]  VARCHAR (150) NULL,
    [DateCreated]   DATETIME      NULL,
    [TokenUpdated]  VARCHAR (150) NULL,
    [DateUpdated]   DATETIME      NULL);

