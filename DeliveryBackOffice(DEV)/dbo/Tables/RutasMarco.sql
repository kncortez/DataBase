CREATE TABLE [dbo].[RutasMarco] (
    [CodeRoute] NVARCHAR (100) NULL,
    [RowID]     INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    CONSTRAINT [PK_RutasMarco] PRIMARY KEY CLUSTERED ([RowID] ASC)
);

