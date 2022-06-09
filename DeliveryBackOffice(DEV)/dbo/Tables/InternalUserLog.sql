CREATE TABLE [dbo].[InternalUserLog] (
    [IdInternalUserLog] INT           IDENTITY (1, 1) NOT NULL,
    [IdUser]            INT           NULL,
    [UserName]          VARCHAR (100) NULL,
    [DateUpdate]        DATETIME      NULL,
    [UserUpdate]        VARCHAR (100) NULL,
    [IdUserNew]         INT           NULL,
    [UserRegisterID]    INT           NULL,
    [UsrIdUser]         INT           NULL,
    [UsrEmail]          VARCHAR (100) NULL,
    CONSTRAINT [PK_InternalUserLog] PRIMARY KEY CLUSTERED ([IdInternalUserLog] ASC)
);

