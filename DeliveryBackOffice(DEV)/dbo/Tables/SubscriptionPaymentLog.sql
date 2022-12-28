CREATE TABLE [dbo].[SubscriptionPaymentLog] (
    [IdSubscriptionPaymentLog] INT           IDENTITY (1, 1) NOT NULL,
    [SubscriptionId]           INT           NOT NULL,
    [Authorization]            NVARCHAR (50) NOT NULL,
    [TypeOfInOutOfMoneyId]     INT           NOT NULL,
    [RowStatus]                BIT           CONSTRAINT [DF_SubscriptionPaymentLog_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]             NVARCHAR (50) NOT NULL,
    [DateCreated]              DATETIME      NOT NULL,
    [TokenUpdated]             NVARCHAR (50) NULL,
    [DateUpdated]              DATETIME      NULL,
    [TransactionOrder]         NVARCHAR (50) NULL,
    CONSTRAINT [PK_SubscriptionPaymentLog] PRIMARY KEY CLUSTERED ([IdSubscriptionPaymentLog] ASC)
);

