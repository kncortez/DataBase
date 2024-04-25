CREATE TABLE [dbo].[MembershipPaymentLog] (
    [IdMembershipPaymentLog] INT            IDENTITY (1, 1) NOT NULL,
    [MembershipId]           INT            NOT NULL,
    [Authorization]          NVARCHAR (50)  NULL,
    [TypeOfInOutOfMoneyId]   INT            NOT NULL,
    [RowStatus]              BIT            CONSTRAINT [DF_MembershipPaymentLog_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]           NVARCHAR (50)  NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [TokenUpdated]           NVARCHAR (50)  NULL,
    [DateUpdated]            DATETIME       NULL,
    [TransactionOrder]       NVARCHAR (50)  NULL,
    [PaymentImageURL]        NVARCHAR (600) NULL,
    CONSTRAINT [PK_MembershipPaymentLog] PRIMARY KEY CLUSTERED ([IdMembershipPaymentLog] ASC),
    CONSTRAINT [FK_MembershipPaymentLog_Membership] FOREIGN KEY ([MembershipId]) REFERENCES [dbo].[Membership] ([IdMembership]),
    CONSTRAINT [FK_MembershipPaymentLog_PaymentType] FOREIGN KEY ([TypeOfInOutOfMoneyId]) REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'URL de la Imagen de Pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipPaymentLog', @level2type = N'COLUMN', @level2name = N'PaymentImageURL';



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de tabla tipo de pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipPaymentLog', @level2type = N'COLUMN', @level2name = N'TypeOfInOutOfMoneyId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de identificación de la transacción de pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipPaymentLog', @level2type = N'COLUMN', @level2name = N'TransactionOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipPaymentLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'estado del  registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipPaymentLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de tabla de catalogo de membresias', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipPaymentLog', @level2type = N'COLUMN', @level2name = N'MembershipId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de tabla de registros de pago de compra de membresias ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipPaymentLog', @level2type = N'COLUMN', @level2name = N'IdMembershipPaymentLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipPaymentLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'numero decomprobante de pago o Order number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipPaymentLog', @level2type = N'COLUMN', @level2name = N'Authorization';

