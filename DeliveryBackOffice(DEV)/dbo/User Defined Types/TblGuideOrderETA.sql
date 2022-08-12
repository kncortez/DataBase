CREATE TYPE [dbo].[TblGuideOrderETA] AS TABLE (
    [Guide_Serie]  NVARCHAR (2)   NOT NULL,
    [Guide_Number] INT            NOT NULL,
    [Guide_Order]  DECIMAL (5, 2) NULL,
    [Guide_ETA]    TIME (7)       NULL);

