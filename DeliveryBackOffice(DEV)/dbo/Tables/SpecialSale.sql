CREATE TABLE [dbo].[SpecialSale] (
    [IdSpecialSale] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]          VARCHAR (50)  NOT NULL,
    [Description]   VARCHAR (200) NULL,
    [StartDate]     DATETIME      NOT NULL,
    [FinishDate]    DATETIME      NULL,
    [IsGlobal]      BIT           NOT NULL,
    [Priority]      INT           NOT NULL,
    [RowStatus]     BIT           NOT NULL,
    [TokenCreated]  VARCHAR (50)  NOT NULL,
    [DateCreated]   DATETIME      NOT NULL,
    [TokenUpdated]  VARCHAR (50)  NULL,
    [DateUpdated]   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdSpecialSale] ASC)
);

