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


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicador booleano de cambio de contraseña', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUser', @level2type = N'COLUMN', @level2name = N'ChangePassword';


GO
CREATE NONCLUSTERED INDEX [idx_UsrIdPerson]
    ON [dbo].[RegisterUser]([UsrIdPerson] ASC);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificacion de persona',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrIdPerson'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificación de usuario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrIdUser'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'nombre de usuario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrNickName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'correo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrEmail'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ultima contraseña',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrLastPassword'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'fecha de expiración de contraseña',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrPasswordExpiration'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tipo de dispositivo ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrDeviceType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Abreviatura de idioma(ES)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrLang'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Abreviatura de moneda',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrCurrency'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Codigo de quien creo el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Codigo de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrTokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fehca de modificación del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'UsrDateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Prefijo para llamadas',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'PrefixCallingCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Telefono',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = N'COLUMN',
    @level2name = N'Phone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contiene información de los usuarios que utilizan el portal individual',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RegisterUser',
    @level2type = NULL,
    @level2name = NULL