CREATE TABLE [dbo].[MembershipAffiliateDiscount] (
    [IdMembershipAffiliateDiscount] BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CatMembershipId]               INT            NOT NULL,
    [AffiliateId]                   BIGINT         NOT NULL,
    [DiscountValueType]             INT            NOT NULL,
    [DiscountValue]                 DECIMAL (5, 2) NOT NULL,
    [RowStatus]                     BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]                   DATETIME       NULL,
    [TokenCreated]                  NVARCHAR (50)  NOT NULL,
    [DateUpdated]                   DATETIME       NULL,
    [TokenUpdated]                  NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdMembershipAffiliateDiscount] ASC),
    CONSTRAINT [FK_MembershipAffiliateDiscount_Affiliate] FOREIGN KEY ([AffiliateId]) REFERENCES [dbo].[Affiliate] ([IdAffiliate]),
    CONSTRAINT [FK_MembershipAffiliateDiscount_DiscountType] FOREIGN KEY ([DiscountValueType]) REFERENCES [dbo].[CatValueType] ([IdCatValueType]),
    CONSTRAINT [FK_MembershipAffiliateDiscount_Membership] FOREIGN KEY ([CatMembershipId]) REFERENCES [dbo].[CatMembership] ([IdCatMembership]),
    UNIQUE NONCLUSTERED ([AffiliateId] ASC, [CatMembershipId] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipAffiliateDiscount', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipAffiliateDiscount', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipAffiliateDiscount', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipAffiliateDiscount', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipAffiliateDiscount', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor de descuento.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipAffiliateDiscount', @level2type = N'COLUMN', @level2name = N'DiscountValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de valor de descuento de CatValueType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipAffiliateDiscount', @level2type = N'COLUMN', @level2name = N'DiscountValueType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del afiliado de la tabla Affiliate.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipAffiliateDiscount', @level2type = N'COLUMN', @level2name = N'AffiliateId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la membresia de la tabla CatMembership.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipAffiliateDiscount', @level2type = N'COLUMN', @level2name = N'CatMembershipId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipAffiliateDiscount', @level2type = N'COLUMN', @level2name = N'IdMembershipAffiliateDiscount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de descuentos dados por afiliado por catálogo de membresias.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipAffiliateDiscount';

