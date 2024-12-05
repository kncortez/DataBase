CREATE TYPE [dbo].[TblListGuidesWithAnticipatedCOD] AS TABLE (
    [Guide_Serie]       VARCHAR (2) NULL,
    [Guide_Number]      INT         NULL,
    [ExcludeCOD]        BIT         NULL,
    [IsAnticipatedCOD]  BIT         NULL
);