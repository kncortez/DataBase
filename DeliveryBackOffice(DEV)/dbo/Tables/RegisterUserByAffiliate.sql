CREATE TABLE [dbo].[RegisterUserByAffiliate] (
    [IdRegisterUserByAffiliate] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [AffiliateId]               BIGINT        NOT NULL,
    [RegisterUserId]            BIGINT        NOT NULL,
    [RowStatus]                 BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]               DATETIME      NULL,
    [TokenCreated]              NVARCHAR (50) NOT NULL,
    [DateUpdated]               DATETIME      NULL,
    [TokenUpdated]              NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdRegisterUserByAffiliate] ASC),
    CONSTRAINT [FK_RegisterUserByAffiliate_Affiliate] FOREIGN KEY ([AffiliateId]) REFERENCES [dbo].[Affiliate] ([IdAffiliate]),
    CONSTRAINT [FK_RegisterUserByAffiliate_RegisterUserId] FOREIGN KEY ([RegisterUserId]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser]),
    UNIQUE NONCLUSTERED ([RegisterUserId] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUserByAffiliate', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUserByAffiliate', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUserByAffiliate', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUserByAffiliate', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUserByAffiliate', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del usuario (UsrIdUser) de la tabla RegisterUser.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUserByAffiliate', @level2type = N'COLUMN', @level2name = N'RegisterUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del afiliado de la tabla Affiliate.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUserByAffiliate', @level2type = N'COLUMN', @level2name = N'AffiliateId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUserByAffiliate', @level2type = N'COLUMN', @level2name = N'IdRegisterUserByAffiliate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para relacionar usuarios con afiliados para login.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RegisterUserByAffiliate';

