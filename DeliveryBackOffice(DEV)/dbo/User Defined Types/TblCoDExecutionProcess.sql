CREATE TYPE [dbo].[TblCoDExecutionProcess] AS TABLE (
    [CoDExecutionProcessId]     INT            NULL,
    [CoDExecutionProcessName]   NVARCHAR (100) NULL,
    [CoDExecutionProcessTime]   TIME (7)       NULL,
    [CoDExecutionProcessBankId] INT            NULL);

