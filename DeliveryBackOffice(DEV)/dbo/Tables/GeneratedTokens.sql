CREATE TABLE [dbo].[GeneratedTokens] (
    [TokenId]            BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [UserId]             BIGINT        NULL,
    [UserName]           VARCHAR (200) NOT NULL,
    [GeneratedToken]     VARCHAR (200) NULL,
    [GeneratedDate]      DATETIME      NULL,
    [ExpirationDate]     DATETIME      NULL,
    [Status]             BIT           NULL,
    [VerificationStatus] BIT           NULL,
    [DateOfTokenUse]     DATETIME      NULL,
    [ResetCounter]       INT           NOT NULL,
    [TokenType]          CHAR (1)      NULL,
    [IP]                 VARCHAR (100) NULL,
    [IdSystem]           INT           NULL,
    CONSTRAINT [PK_ResetPasswordVerification] PRIMARY KEY CLUSTERED ([TokenId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_UserId_VerificationStatus]
    ON [dbo].[GeneratedTokens]([UserId] ASC, [VerificationStatus] ASC);

