CREATE TABLE [dbo].[TermsAndConditions] (
    [IdTAC]        BIGINT        IDENTITY (1, 1) NOT NULL,
    [Name]         VARCHAR (50)  NOT NULL,
    [Description]  VARCHAR (250) NOT NULL,
    [RowStatus]    BIT           NOT NULL,
    [TokenCreated] VARCHAR (50)  NOT NULL,
    [DateCreated]  DATETIME      NOT NULL,
    [TokenUpdated] VARCHAR (50)  NULL,
    [DateUpdated]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdTAC] ASC)
);

