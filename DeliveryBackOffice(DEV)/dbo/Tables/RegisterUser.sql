CREATE TABLE [dbo].[RegisterUser] (
    [UsrIdUser]               BIGINT        IDENTITY (1, 1) NOT NULL,
    [UsrIdPerson]             BIGINT        NOT NULL,
    [UsrNickName]             VARCHAR (100) NOT NULL,
    [UsrEmail]                VARCHAR (200) NOT NULL,
    [UsrAvatar]               VARCHAR (200) NULL,
    [UsrLastPassword]         VARCHAR (200) NOT NULL,
    [UsrPasswordExpiration]   DATE          NOT NULL,
    [UsrLang]                 VARCHAR (2)   NULL,
    [UsrDeviceType]           VARCHAR (50)  NULL,
    [UsrCurrency]             VARCHAR (10)  NULL,
    [UsrEnable2FA]            BIT           NULL,
    [UsrRestrictionAddressIp] VARCHAR (200) NULL,
    [UsrRowStatus]            BIT           NOT NULL,
    [UsrTokenCreated]         VARCHAR (50)  NOT NULL,
    [UsrDateCreated]          DATE          NOT NULL,
    [UsrTokenUpdated]         VARCHAR (50)  NULL,
    [UsrDateUpdated]          DATE          NULL,
    [PrefixCallingCode]       NVARCHAR (4)  NULL,
    [Phone]                   NVARCHAR (15) NULL,
    PRIMARY KEY CLUSTERED ([UsrIdUser] ASC),
    FOREIGN KEY ([UsrIdPerson]) REFERENCES [dbo].[Person] ([PerIdPerson])
);



