CREATE TABLE [dbo].[Membership] (
    [IdMembership]                   INT             IDENTITY (1, 1) NOT NULL,
    [CatMembershipId]                INT             NOT NULL,
    [CatMembershipStatusId]          INT             NOT NULL,
    [MembershipCode]                 NVARCHAR (50)   NULL,
    [MembershipCost]                 DECIMAL (18, 2) NOT NULL,
    [CustomerId]                     INT             NULL,
    [AccountId]                      BIGINT          NULL,
    [VisitPointClientId]             INT             NULL,
    [CustomerPaymentId]              INT             NULL,
    [IsAutoRenewable]                BIT             CONSTRAINT [DF_Membership_IsAutoRenewable] DEFAULT ((0)) NULL,
    [MembershipFixedValue]           INT             NOT NULL,
    [MembershipMaxServiceFixedValue] INT             NOT NULL,
    [ActualServiceCount]             INT             CONSTRAINT [DF_Membership_ActualServiceCount] DEFAULT ((0)) NOT NULL,
    [ExpirationDate]                 DATETIME        NOT NULL,
    [RowStatus]                      BIT             CONSTRAINT [DF_Membership_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                   NVARCHAR (50)   NOT NULL,
    [DateCreated]                    DATETIME        NOT NULL,
    [TokenUpdated]                   NVARCHAR (50)   NULL,
    [DateUpdated]                    DATETIME        NULL,
    [LastPaymentDate]                DATETIME        NULL,
    [InvoiceName]                    NVARCHAR (100)  NULL,
    [TaxIdNumber]                    NVARCHAR (50)   NULL,
    [InvoiceEmail]                   NVARCHAR (50)   NULL,
    [FiscalAddress]                  NVARCHAR (200)  NULL,
    [RenewalFixedDay]                INT             NULL,
    [CatTMSalesPersonId]             INT             NULL,
    [AccumulatedPoints]              INT             NULL,
    [AvailablePoints]                INT             NULL,
    [PointsExpirationDate]           DATETIME        NULL,
    CONSTRAINT [PK_Membership] PRIMARY KEY CLUSTERED ([IdMembership] ASC),
    CONSTRAINT [FK_Membership_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_Membership_CatMembership] FOREIGN KEY ([CatMembershipId]) REFERENCES [dbo].[CatMembership] ([IdCatMembership]),
    CONSTRAINT [FK_Membership_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_Membership_CustomerPayment] FOREIGN KEY ([CustomerPaymentId]) REFERENCES [dbo].[CustomerPaymentValue] ([IdCustomerPaymentValue]),
    CONSTRAINT [FK_Membership_MembershipStatus] FOREIGN KEY ([CatMembershipStatusId]) REFERENCES [dbo].[CatSalesPackageStatus] ([IdCatSalesPackageStatus]),
    CONSTRAINT [FK_Membership_VisitPointClient] FOREIGN KEY ([VisitPointClientId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatMembership.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'CatMembershipId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla Membership.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'IdMembership';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Día  el cual se desea poder renovar la membresía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'RenewalFixedDay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del vendedor de telemercadeo asociado a la membresía vendida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'CatTMSalesPersonId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de expiración de puntos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'PointsExpirationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Puntos disponibles para usar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'AvailablePoints';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Puntos acumulados durante un periodo de vigencia de membresía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'AccumulatedPoints';

