CREATE TYPE [dbo].[TblGuideStatus] AS TABLE (
    [Guide_Serie]        NVARCHAR (2) NOT NULL,
    [Guide_Number]       INT          NOT NULL,
    [Status_Description] VARCHAR (50) NULL);

