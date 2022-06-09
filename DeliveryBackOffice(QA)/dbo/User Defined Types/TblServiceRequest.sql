CREATE TYPE [dbo].[TblServiceRequest] AS TABLE (
    [RowNumber]        INT            NOT NULL,
    [Messageid]        NVARCHAR (MAX) NULL,
    [Receiver_Name]    NVARCHAR (100) NULL,
    [Receiver_Email]   NVARCHAR (200) NOT NULL,
    [PathReceivedFile] NVARCHAR (100) NULL,
    [PathSticker]      NVARCHAR (100) NULL,
    [Status]           NVARCHAR (50)  NOT NULL,
    [Receiver_Date]    DATETIME       NOT NULL,
    [DateCreated]      DATETIME       NOT NULL,
    [CustomerID]       INT            NOT NULL);

