CREATE TABLE [dbo].[TermsAndConditionsByUser] (
    [IdTACByUser]  BIGINT       IDENTITY (1, 1) NOT NULL,
    [TACId]        BIGINT       NOT NULL,
    [IdAccount]    BIGINT       NOT NULL,
    [TAC]          BIT          NOT NULL,
    [RowStatus]    BIT          NOT NULL,
    [TokenCreated] VARCHAR (50) NOT NULL,
    [DateCreated]  DATETIME     NOT NULL,
    [TokenUpdated] VARCHAR (50) NULL,
    [DateUpdated]  DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdTACByUser] ASC),
    FOREIGN KEY ([IdAccount]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    FOREIGN KEY ([TACId]) REFERENCES [dbo].[TermsAndConditions] ([IdTAC])
);

