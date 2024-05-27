CREATE TABLE [dbo].[MembershipSubscriptionLog] (
    [IdMembershipSubscriptionLog] BIGINT          IDENTITY (1, 1) NOT NULL,
    [SystemId]                    INT             NOT NULL,
    [ModuleId]                    INT             NOT NULL,
    [MembershipId]                INT             NULL,
    [SubscriptionId]              INT             NULL,
    [SalesPackageStatusId]        INT             NULL,
    [StationId]                   INT             NULL,
    [CustomerId]                  INT             NULL,
    [AccountId]                   BIGINT          NULL,
    [VisitPointClientId]          INT             NULL,
    [LogActionDescription]        NVARCHAR (300)  NOT NULL,
    [LogGuideSerie]               NVARCHAR (2)    NULL,
    [LogGuideNumber]              INT             NULL,
    [LogGuideOriginalValue]       DECIMAL (14, 2) NULL,
    [LogGuideNewValue]            DECIMAL (14, 2) NULL,
    [RowStatus]                   BIT             CONSTRAINT [DF_MembershipSubscriptionLog_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                NVARCHAR (50)   NOT NULL,
    [DateCreated]                 DATETIME        NOT NULL,
    [TokenUpdated]                NVARCHAR (50)   NULL,
    [DateUpdated]                 DATETIME        NULL,
    [LogAuthorizationValue]       NVARCHAR (50)   NULL,
    [LogTransactionId]            NVARCHAR (50)   NULL,
    [LogTransactionOrder]         NVARCHAR (50)   NULL,
    [LogServiceNumber]            INT             NULL,
    CONSTRAINT [PK_MembershipSubscriptionLog] PRIMARY KEY CLUSTERED ([IdMembershipSubscriptionLog] ASC),
    CONSTRAINT [FK_MembershipSubscriptionLog_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_MembershipSubscriptionLog_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_MembershipSubscriptionLog_DeliveryOrder] FOREIGN KEY ([LogGuideSerie], [LogGuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_MembershipSubscriptionLog_Membership] FOREIGN KEY ([MembershipId]) REFERENCES [dbo].[Membership] ([IdMembership]),
    CONSTRAINT [FK_MembershipSubscriptionLog_Module] FOREIGN KEY ([ModuleId]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FK_MembershipSubscriptionLog_Station] FOREIGN KEY ([StationId]) REFERENCES [dbo].[CatStation] ([IdStation]),
    CONSTRAINT [FK_MembershipSubscriptionLog_Status] FOREIGN KEY ([SalesPackageStatusId]) REFERENCES [dbo].[CatSalesPackageStatus] ([IdCatSalesPackageStatus]),
    CONSTRAINT [FK_MembershipSubscriptionLog_Subscription] FOREIGN KEY ([SubscriptionId]) REFERENCES [dbo].[Subscription] ([IdSubscription]),
    CONSTRAINT [FK_MembershipSubscriptionLog_System] FOREIGN KEY ([SystemId]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [FK_MembershipSubscriptionLog_VisitPointClient] FOREIGN KEY ([VisitPointClientId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);




GO
CREATE NONCLUSTERED INDEX [idx_MembershipSubscriptionLog_RowStatus]
    ON [dbo].[MembershipSubscriptionLog]([RowStatus] ASC)
    INCLUDE([LogGuideSerie], [LogGuideNumber]);


GO
CREATE NONCLUSTERED INDEX [idx_LogGuideSerie_LogGuideNumber_RowStatus]
    ON [dbo].[MembershipSubscriptionLog]([LogGuideSerie] ASC, [LogGuideNumber] ASC, [RowStatus] ASC);

