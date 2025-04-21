CREATE TABLE [dbo].[CatWizard] (
    [IdWiz]          INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [NameWiz]        VARCHAR (50) NULL,
    [DescriptionWiz] VARCHAR (80) NULL,
    [StatusWiz]      INT          NULL,
    [DateCreated]    DATETIME     NULL,
    [TokenCreate]    VARCHAR (50) NULL,
    [DateUpdate]     DATETIME     NULL,
    [TokenUpdate]    VARCHAR (50) NULL,
    CONSTRAINT [PK_CatWizard] PRIMARY KEY CLUSTERED ([IdWiz] ASC)
);

