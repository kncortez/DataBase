CREATE TABLE [dbo].[StatusOrderExternal] (
    [IdStatusOrderExternal]  INT    IDENTITY (1, 1) NOT NULL,
	[CustomerId]         INT            NOT NULL,
    [Remark]             NVARCHAR (50)  NOT NULL,
    [Description]        NVARCHAR (150) NOT NULL,
    [RowStatus]          BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]        DATETIME       NOT NULL,
    [TokenCreated]       NVARCHAR (50)  NOT NULL,
    [DateUpdated]        DATETIME       NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
	CONSTRAINT [PK_IdStatusOrderExternal] PRIMARY KEY CLUSTERED ([IdStatusOrderExternal] ASC)
)