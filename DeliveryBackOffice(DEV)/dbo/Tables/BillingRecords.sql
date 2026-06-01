CREATE TABLE [dbo].[BillingRecords] (
    [Id]    INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Notes] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

