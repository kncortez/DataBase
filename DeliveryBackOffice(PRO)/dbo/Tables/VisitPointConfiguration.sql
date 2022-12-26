CREATE TABLE [dbo].[VisitPointConfiguration] (
    [IdVPConfiguration]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [VisitPointID]         INT           NOT NULL,
    [TransportCompanyID]   INT           NULL,
    [HubLogisticID]        INT           NULL,
    [CODAccountBankID]     INT           NULL,
    [CODAccountName]       NVARCHAR (50) NULL,
    [CODAccountNumber]     NVARCHAR (50) NULL,
    [CODAccountBankTypeID] INT           NULL,
    [CODAccountCurrencyID] INT           NULL,
    [RowStatus]            BIT           NULL,
    [TokenCreated]         NVARCHAR (50) NULL,
    [DateCreated]          DATETIME      NULL,
    [TokenUpdated]         NVARCHAR (50) NULL,
    [DateUpdated]          DATETIME      NULL,
    [AveragePackageDaily]  INT           NULL,
    [DateStartOperation]   DATETIME      NULL,
    CONSTRAINT [PK_VisitPointConfiguration] PRIMARY KEY CLUSTERED ([IdVPConfiguration] ASC),
    CONSTRAINT [FK_VisitPointConfiguration_CatBankAccountType] FOREIGN KEY ([CODAccountBankTypeID]) REFERENCES [dbo].[CatBankAccountType] ([IdBankAccountType]),
    CONSTRAINT [FK_VisitPointConfiguration_CatTransportCompany] FOREIGN KEY ([TransportCompanyID]) REFERENCES [dbo].[CatTransportCompany] ([IdTransportCompany]),
    CONSTRAINT [FK_VisitPointConfiguration_DeliveryBank] FOREIGN KEY ([CODAccountBankID]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
    CONSTRAINT [FK_VisitPointConfiguration_DeliveryCurrency] FOREIGN KEY ([CODAccountCurrencyID]) REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id]),
    CONSTRAINT [FK_VisitPointConfiguration_HubLogistics] FOREIGN KEY ([HubLogisticID]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_VisitPointConfiguration_VisitPointClient] FOREIGN KEY ([VisitPointID]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);




GO
CREATE NONCLUSTERED INDEX [idx_VisitPointID]
    ON [dbo].[VisitPointConfiguration]([VisitPointID] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_DateStartOperation]
    ON [dbo].[VisitPointConfiguration]([DateStartOperation] ASC);

