CREATE TABLE [dbo].[UserSystemRestriction] (
    [UstIdRestriction] BIGINT       IDENTITY (1, 1) NOT NULL,
    [UstIdUser]        BIGINT       NOT NULL,
    [UstIdSystem]      INT          NOT NULL,
    [UstAccessRetries] INT          NOT NULL,
    [UstRetries]       INT          NOT NULL,
    [UstStatus]        VARCHAR (10) NOT NULL,
    [UstRowStatus]     BIT          NOT NULL,
    [UstTokenCreated]  VARCHAR (50) NOT NULL,
    [UstDateCreated]   DATETIME     NOT NULL,
    [UstOperationDate] DATETIME     NOT NULL,
    PRIMARY KEY CLUSTERED ([UstIdRestriction] ASC),
    CONSTRAINT [FKSystemRestriction] FOREIGN KEY ([UstIdSystem]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [FKUserRestriction] FOREIGN KEY ([UstIdUser]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para registro de bloqueo de usuario por sistema.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserSystemRestriction';

