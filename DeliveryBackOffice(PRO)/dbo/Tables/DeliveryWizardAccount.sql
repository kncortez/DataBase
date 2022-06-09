CREATE TABLE [dbo].[DeliveryWizardAccount] (
    [IdWizAccount]     INT          IDENTITY (1, 1) NOT NULL,
    [AccIdAccount]     INT          NULL,
    [IdWiz]            INT          NULL,
    [StatusAccountWiz] INT          NULL,
    [DateCreate]       DATETIME     NULL,
    [TokenCreate]      VARCHAR (50) NULL,
    [DateUpdate]       DATETIME     NULL,
    [TokenUpdate]      VARCHAR (50) NULL,
    CONSTRAINT [PK_DeliveryWizardAccount] PRIMARY KEY CLUSTERED ([IdWizAccount] ASC)
);

