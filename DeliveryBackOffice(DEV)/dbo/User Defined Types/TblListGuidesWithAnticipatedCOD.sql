CREATE TYPE [dbo].[TblListGuidesWithAnticipatedCOD] AS TABLE (
    [Guide_Serie]       NVARCHAR (2) NULL,
    [Guide_Number]      INT         NULL,
    [ExcludeCOD]        BIT         NULL,
    [IsAnticipatedCOD]  BIT         NULL,
    [AmountToPay]       DECIMAL(18,2)     NULL,
    [CODAmount]         DECIMAL(18,2)     NULL
);