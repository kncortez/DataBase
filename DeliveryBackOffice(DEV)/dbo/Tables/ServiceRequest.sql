CREATE TABLE [dbo].[ServiceRequest] (
    [Messageid]        NVARCHAR (MAX) NULL,
    [Receiver_Name]    NVARCHAR (100) NOT NULL,
    [Receiver_Email]   NVARCHAR (200) NOT NULL,
    [PathReceivedFile] NVARCHAR (200) NULL,
    [PathSticker]      NVARCHAR (100) NULL,
    [Status]           NVARCHAR (50)  NOT NULL,
    [Receiver_Date]    DATETIME       NOT NULL,
    [DateCreated]      DATETIME       NOT NULL,
    [Manifest_Serie]   NVARCHAR (2)   NOT NULL,
    [Manifest_Number]  INT            NOT NULL,
    [CustomerID]       INT            NULL,
    CONSTRAINT [pk_manifest] PRIMARY KEY CLUSTERED ([Manifest_Serie] ASC, [Manifest_Number] ASC),
    CONSTRAINT [FK_ServiceRequest_Customer] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customer] ([IdCustomer])
);



