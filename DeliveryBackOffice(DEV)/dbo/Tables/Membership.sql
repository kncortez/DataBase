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
    [CatValueTypeId]                 INT             NULL,
    [ProductGiftShippingEmail]       NVARCHAR (100)  NULL,
    [ActivationCode]                 NVARCHAR (50)   NULL,
    [ActivationDate]                 DATETIME        NULL,
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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Día el cual se desea poder renovar la membresía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'RenewalFixedDay';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del vendedor de telemercadeo asociado a la membresía vendida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'CatTMSalesPersonId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de expiración de puntos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'PointsExpirationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Puntos disponibles para usar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'AvailablePoints';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Puntos acumulados durante un periodo de vigencia de membresía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'AccumulatedPoints';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Listado de membresías generadas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del punto de visita asociado a la membresía (no activo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'VisitPointClientId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nit con la que se compra la membresía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'TaxIdNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad máxima de servicios de la membresía adquirida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'MembershipMaxServiceFixedValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto del servicio al tener membresía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'MembershipFixedValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Costo de la membresía adquirida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'MembershipCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de activación de Express Center para uso en clientes individuales (no vigente)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'MembershipCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'LastPaymentDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el cliente desea autorenovar su membresía anual', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'IsAutoRenewable';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Correo de facturación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'InvoiceEmail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dirección para facturar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'FiscalAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de expiración de membresía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'ExpirationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la forma de pago asociada, con que tarjeta se pagó, tabla CustomerPaymentValue', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'CustomerPaymentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del dueño de la mebresía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatSalesPackageStatus', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'CatMembershipStatusId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de servicio generados bajo membresías, luego de vencer se siguen acumulando con descuento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'ActualServiceCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la cuenta de la membresía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'AccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de tabla CatValueType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'CatValueTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de activación del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Membership', @level2type = N'COLUMN', @level2name = N'ActivationDate';

