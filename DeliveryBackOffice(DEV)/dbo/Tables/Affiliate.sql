CREATE TABLE [dbo].[Affiliate] (
    [IdAffiliate]           BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [AffiliateName]         NVARCHAR (100) NOT NULL,
    [AffiliateContactName]  NVARCHAR (100) NULL,
    [AffiliateContactPhone] NVARCHAR (50)  NULL,
    [AffiliateContactEmail] NVARCHAR (100) NULL,
    [RowStatus]             BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]           DATETIME       NULL,
    [TokenCreated]          NVARCHAR (50)  NOT NULL,
    [DateUpdated]           DATETIME       NULL,
    [TokenUpdated]          NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdAffiliate] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Affiliate', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Affiliate', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Affiliate', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Affiliate', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Affiliate', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Correo de contacto de affiliado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Affiliate', @level2type = N'COLUMN', @level2name = N'AffiliateContactEmail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Teléfono de contacto del afiliado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Affiliate', @level2type = N'COLUMN', @level2name = N'AffiliateContactPhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la persona de contacto del afiliado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Affiliate', @level2type = N'COLUMN', @level2name = N'AffiliateContactName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del afiliado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Affiliate', @level2type = N'COLUMN', @level2name = N'AffiliateName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Affiliate', @level2type = N'COLUMN', @level2name = N'IdAffiliate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de afiliados', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Affiliate';

