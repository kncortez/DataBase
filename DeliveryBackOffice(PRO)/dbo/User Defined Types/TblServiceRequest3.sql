CREATE TYPE [dbo].[TblServiceRequest3] AS TABLE (
    [RowNumber]        INT            NOT NULL,
    [Messageid]        NVARCHAR (MAX) NULL,
    [Receiver_Name]    NVARCHAR (100) NULL,
    [Receiver_Email]   NVARCHAR (200) NOT NULL,
    [PathReceivedFile] NVARCHAR (200) NULL,
    [PathSticker]      NVARCHAR (200) NULL,
    [Status]           NVARCHAR (50)  NOT NULL,
    [Receiver_Date]    DATETIME       NOT NULL,
    [DateCreated]      DATETIME       NOT NULL,
    [CustomerID]       INT            NOT NULL);

