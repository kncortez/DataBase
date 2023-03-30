CREATE TYPE [dbo].[TblServiceExecutionProcess] AS TABLE (
    [ServiceExecutionProcessId]           INT            NULL,
    [ServiceExecutionProcessName]         NVARCHAR (100) NULL,
    [ServiceExecutionProcessTime]         TIME (7)       NULL,
    [ServiceExecutionProcessIsPending]    BIT            NULL,
    [ServiceExecutionProcessHasStarted]   BIT            NULL,
    [ServiceExecutionProcessHasCompleted] BIT            NULL);

