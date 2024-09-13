CREATE TABLE [dbo].[InternalUser] (
    [IdUser]         BIGINT         NOT NULL,
    [Username]       NVARCHAR (50)  NOT NULL,
    [IdEmployee]     NVARCHAR (50)  NULL,
    [RegisterUserID] BIGINT         NULL,
    [RowStatus]      BIT            CONSTRAINT [DF_InternalUser_RowStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated]   NVARCHAR (50)  NULL,
    [DateCreated]    DATETIME       NULL,
    [TokenUpdated]   NVARCHAR (50)  NULL,
    [DateUpdated]    DATETIME       NULL,
    [Comment]        NVARCHAR (200) NULL,
    CONSTRAINT [PK_InternalUser] PRIMARY KEY CLUSTERED ([IdUser] ASC, [Username] ASC),
    CONSTRAINT [FK_InternalUser_RegisterUser] FOREIGN KEY ([RegisterUserID]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);






GO
CREATE NONCLUSTERED INDEX [idx_ RegisterUserID]
    ON [dbo].[InternalUser]([RegisterUserID] ASC);

