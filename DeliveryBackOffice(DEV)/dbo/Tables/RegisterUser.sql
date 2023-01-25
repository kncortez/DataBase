CREATE TABLE [dbo].[RegisterUser] (
    [UsrIdUser]               BIGINT         IDENTITY (1, 1) NOT NULL,
    [UsrIdPerson]             BIGINT         NOT NULL,
    [UsrNickName]             VARCHAR (100)  NOT NULL,
    [UsrEmail]                VARCHAR (200)  NOT NULL,
    [UsrAvatar]               VARCHAR (200)  NULL,
    [UsrLastPassword]         VARCHAR (200)  NOT NULL,
    [UsrPasswordExpiration]   DATE           NOT NULL,
    [UsrLang]                 VARCHAR (2)    NULL,
    [UsrDeviceType]           VARCHAR (50)   NULL,
    [UsrCurrency]             VARCHAR (10)   NULL,
    [UsrEnable2FA]            BIT            NULL,
    [UsrRestrictionAddressIp] VARCHAR (200)  NULL,
    [UsrRowStatus]            BIT            NOT NULL,
    [UsrTokenCreated]         VARCHAR (50)   NOT NULL,
    [UsrDateCreated]          DATE           NOT NULL,
    [UsrTokenUpdated]         VARCHAR (50)   NULL,
    [UsrDateUpdated]          DATE           NULL,
    [PrefixCallingCode]       NVARCHAR (4)   NULL,
    [Phone]                   NVARCHAR (15)  NULL,
    [UrlFacebook]             NVARCHAR (300) NULL,
    [UrlInstagram]            NVARCHAR (300) NULL,
    [UrlEcommerce]            NVARCHAR (300) NULL,
    [UrlWebsite]              NVARCHAR (300) NULL,
    [IdentificationImageA]    NVARCHAR (500) NULL,
    [IdentificationImageB]    NVARCHAR (500) NULL,
    [VerifiedPhone]           BIT            CONSTRAINT [DF__RegisterU__Verif__2E51B1C3] DEFAULT ('false') NULL,
    [ChangePassword]          BIT            NULL,
    PRIMARY KEY CLUSTERED ([UsrIdUser] ASC),
    FOREIGN KEY ([UsrIdPerson]) REFERENCES [dbo].[Person] ([PerIdPerson])
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo que indica si telefono ya fue verificado o no.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUser', @level2type = N'COLUMN', @level2name = N'VerifiedPhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar url de sitio web del usuario.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUser', @level2type = N'COLUMN', @level2name = N'UrlWebsite';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar url cuenta instagram del usuario.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUser', @level2type = N'COLUMN', @level2name = N'UrlInstagram';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar url cuenta de facebook del usuario.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUser', @level2type = N'COLUMN', @level2name = N'UrlFacebook';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar url de la empresa del usuario.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUser', @level2type = N'COLUMN', @level2name = N'UrlEcommerce';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar url de imagen parte de atras de dpi del usuario.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUser', @level2type = N'COLUMN', @level2name = N'IdentificationImageB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar url de imagen parte frontal de dpi del usuario.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUser', @level2type = N'COLUMN', @level2name = N'IdentificationImageA';

