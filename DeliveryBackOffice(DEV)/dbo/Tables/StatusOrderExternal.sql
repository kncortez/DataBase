CREATE TABLE [dbo].[StatusOrderExternal] (
    [IdStatusOrderExternal] INT            IDENTITY (1, 1) NOT NULL,
    [CustomerId]            INT            NOT NULL,
    [Remark]                NVARCHAR (50)  NOT NULL,
    [Description]           NVARCHAR (250) NOT NULL,
    [RowStatus]             BIT            CONSTRAINT [DF__StatusOrd__RowSt__1CFD088F] DEFAULT ((1)) NOT NULL,
    [DateCreated]           DATETIME       NOT NULL,
    [TokenCreated]          NVARCHAR (50)  NOT NULL,
    [DateUpdated]           DATETIME       NULL,
    [TokenUpdated]          NVARCHAR (50)  NULL,
    CONSTRAINT [PK__StatusOr__104265F3E41490A3] PRIMARY KEY CLUSTERED ([IdStatusOrderExternal] ASC)
);

