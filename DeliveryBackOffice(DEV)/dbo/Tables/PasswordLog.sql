CREATE TABLE [dbo].[PasswordLog] (
    [PslIdLog]        BIGINT        IDENTITY (1, 1) NOT NULL,
    [PslIdUser]       BIGINT        NOT NULL,
    [PslPassword]     VARCHAR (100) NOT NULL,
    [PslTokenCreated] VARCHAR (50)  NOT NULL,
    [PslDateCreated]  DATE          NOT NULL,
    PRIMARY KEY CLUSTERED ([PslIdLog] ASC),
    FOREIGN KEY ([PslIdUser]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);

