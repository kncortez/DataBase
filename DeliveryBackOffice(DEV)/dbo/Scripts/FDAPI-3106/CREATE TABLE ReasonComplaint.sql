CREATE TABLE [dbo].[ReasonComplaint] (
    [ReasonComplaintId]    INT              IDENTITY (1, 1) NOT NULL,
    [Description]          NVARCHAR (80)    NULL,
    [CountryId]            NVARCHAR (2)    NULL,
    [RowStatus]            BIT              CONSTRAINT [DF_ReasonComplaint_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]         NVARCHAR (50)    NOT NULL,
    [DateCreated]          DATETIME         NOT NULL,
    [TokenUpdated]         NVARCHAR (50)    NULL,
    [DateUpdated]          DATETIME         NULL,
    CONSTRAINT [PK_ReasonComplaint] PRIMARY KEY ([ReasonComplaintId])
);
GO