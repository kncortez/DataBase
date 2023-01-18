CREATE TABLE [dbo].[VisitPointByUser] (
    [IdVisitPointByUser] BIGINT        IDENTITY (1, 1) NOT NULL,
    [IdVisitPointClient] INT           NOT NULL,
    [RegisterUserID]     BIGINT        NULL,
    [RowStatus]          BIT           CONSTRAINT [DF_VisitPointByUser_RowStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated]       NVARCHAR (50) NULL,
    [DateCreated]        DATETIME      NULL,
    [TokenUpdated]       NVARCHAR (50) NULL,
    [DateUpdated]        DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdVisitPointByUser] ASC),
    CONSTRAINT [FK_VisitPointByUser_RegisterUser] FOREIGN KEY ([RegisterUserID]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);






GO


