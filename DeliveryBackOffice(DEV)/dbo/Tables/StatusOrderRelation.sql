CREATE TABLE [dbo].[StatusOrderRelation] (
    [IdStatusOrderRelation]		INT			IDENTITY (1, 1) NOT NULL,
    [StatusOrderId]				TINYINT     NOT NULL,
    [StatusOrderExternalId]     INT			NOT NULL,
    [RowStatus]          BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]        DATETIME       NOT NULL,
    [TokenCreated]       NVARCHAR (50)  NOT NULL,
    [DateUpdated]        DATETIME       NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
	CONSTRAINT [PK_IdStatusOrderRelation] PRIMARY KEY CLUSTERED ([IdStatusOrderRelation] ASC),
    CONSTRAINT [FK_StatusOrderRelation_StatusOrderExternal] FOREIGN KEY ([StatusOrderExternalId]) REFERENCES [dbo].[StatusOrderExternal] ([IdStatusOrderExternal]),
    CONSTRAINT [FK_StatusOrderRelation_StatusOrder] FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder]  ([StatusOrderId])
);