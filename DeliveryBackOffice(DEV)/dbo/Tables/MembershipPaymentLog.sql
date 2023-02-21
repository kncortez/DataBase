CREATE TABLE [dbo].[MembershipPaymentLog] (
    [IdMembershipPaymentLog] INT           IDENTITY (1, 1) NOT NULL,
    [MembershipId]           INT           NOT NULL,
    [Authorization]          NVARCHAR (50) NULL,
    [TypeOfInOutOfMoneyId]   INT           NOT NULL,
    [RowStatus]              BIT           CONSTRAINT [DF_MembershipPaymentLog_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]           NVARCHAR (50) NOT NULL,
    [DateCreated]            DATETIME      NOT NULL,
    [TokenUpdated]           NVARCHAR (50) NULL,
    [DateUpdated]            DATETIME      NULL,
    [TransactionOrder]       NVARCHAR (50) NULL,
    [PaymentImageURL]        NVARCHAR (600) NULL,
    CONSTRAINT [PK_MembershipPaymentLog] PRIMARY KEY CLUSTERED ([IdMembershipPaymentLog] ASC),
    CONSTRAINT [FK_MembershipPaymentLog_Membership] FOREIGN KEY ([MembershipId]) REFERENCES [dbo].[Membership] ([IdMembership]),
    CONSTRAINT [FK_MembershipPaymentLog_PaymentType] FOREIGN KEY ([TypeOfInOutOfMoneyId]) REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Imagen de pago que se realizo, de ser posible', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipPaymentLog', @level2type = N'COLUMN', @level2name = N'PaymentImageURL';
