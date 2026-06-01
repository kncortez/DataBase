CREATE TABLE [dbo].[CustomsNotificationsLog] (
    [IdLog]        INT                IDENTITY (1, 1) NOT NULL,
    [JobId]        NVARCHAR (50)      NOT NULL,
    [TargetStatus] NVARCHAR (50)      NOT NULL,
    [ReferenceId]  INT                NOT NULL,
    [SentTo]       NVARCHAR (2000)    NOT NULL,
    [Status]       NVARCHAR (20)      NOT NULL,
    [ErrorMessage] NVARCHAR (2000)    NULL,
    [CreatedAt]    DATETIMEOFFSET (7) DEFAULT (sysdatetimeoffset()) NOT NULL,
    CONSTRAINT [PK_CustomsNotificationsLog] PRIMARY KEY CLUSTERED ([IdLog] ASC)
);

