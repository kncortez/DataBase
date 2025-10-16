CREATE TABLE [dbo].[MembershipUsageByAffiliate] (
    [IdMembershipUsageByAffiliate] BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [MembershipId]                 INT             NOT NULL,
    [AffiliateId]                  BIGINT          NOT NULL,
    [InvoiceAuthorization]         NVARCHAR (200)  NULL,
    [Amount]                       DECIMAL (18, 2) NULL,
    [DiscountValueType]            INT             NOT NULL,
    [DiscountValue]                DECIMAL (5, 2)  NOT NULL,
    [DiscountApplied]              DECIMAL (18, 2) NULL,
    [FinalAmount]                  DECIMAL (18, 2) NULL,
    [RowStatus]                    BIT             DEFAULT ((1)) NOT NULL,
    [DateCreated]                  DATETIME        NULL,
    [TokenCreated]                 NVARCHAR (50)   NOT NULL,
    [DateUpdated]                  DATETIME        NULL,
    [TokenUpdated]                 NVARCHAR (50)   NULL,
    [RegisterUserId]               BIGINT          NOT NULL,
    PRIMARY KEY CLUSTERED ([IdMembershipUsageByAffiliate] ASC),
    CONSTRAINT [FK_MembershipUsageByAffiliate_Affiliate] FOREIGN KEY ([AffiliateId]) REFERENCES [dbo].[Affiliate] ([IdAffiliate]),
    CONSTRAINT [FK_MembershipUsageByAffiliate_DiscountType] FOREIGN KEY ([DiscountValueType]) REFERENCES [dbo].[CatValueType] ([IdCatValueType]),
    CONSTRAINT [FK_MembershipUsageByAffiliate_Membership] FOREIGN KEY ([MembershipId]) REFERENCES [dbo].[Membership] ([IdMembership]),
    CONSTRAINT [FK_MembershipUsageByAffiliate_RegisterUser] FOREIGN KEY ([RegisterUserId]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto final registrado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'FinalAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de descuento aplicado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'DiscountApplied';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor del descuento aplicado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'DiscountValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de valor de la tabla CatValueType.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'DiscountValueType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto por el cual se registra el uso de la membresia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la factura donde se registro el uso de membresia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'InvoiceAuthorization';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del afiliado de la tabla Affiliate.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'AffiliateId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la membresia de la tabla Membership.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'MembershipId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'IdMembershipUsageByAffiliate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de registro de canjeo de membresias por afiliados.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador del usuario que registro el uso de la tabla RegisterUser', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipUsageByAffiliate', @level2type = N'COLUMN', @level2name = N'RegisterUserId';

