CREATE TABLE [dbo].[ImagesByVisitPoint] (
    [IdImage]         INT           IDENTITY (1, 1) NOT NULL,
    [CodeOfReference] INT           NULL,
    [PathImage]       VARCHAR (200) NULL,
    [RowStatus]       BIT           NULL,
    [TokenCreated]    VARCHAR (150) NOT NULL,
    [DateCreated]     DATETIME      NOT NULL,
    [TokenUpdated]    VARCHAR (150) NULL,
    [DateUpdated]     DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdImage] ASC),
    CONSTRAINT [FKCodeOfReference] FOREIGN KEY ([CodeOfReference]) REFERENCES [dbo].[VisitPointClientParser] ([CodeOfReference])
);

