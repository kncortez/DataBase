CREATE TYPE [dbo].[TblListGuidesWithAnticipatedCOD] AS TABLE (
    [Guide_Serie]       NVARCHAR (2) NULL,
    [Guide_Number]      INT         NULL,
    [ExcludeCOD]        BIT         NULL,
    [IsAnticipatedCOD]  BIT         NULL
);