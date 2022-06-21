CREATE TABLE [dbo].[TmpNumberPhone] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [GuideNumber]    INT           NULL,
    [PhoneSender]    VARCHAR (200) NULL,
    [PhoneReceiver]  VARCHAR (200) NULL,
    [PhoneAlternant] VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

