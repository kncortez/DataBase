CREATE TABLE [dbo].[DashboardCustomerConfig] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [ReportKey]       NVARCHAR (100) NOT NULL,
    [CustomerId]      INT            NOT NULL,
    [CustomerName]    NVARCHAR (200) NULL,
    [IsActive]        BIT            DEFAULT ((1)) NOT NULL,
    [BaseDate]        DATE           NULL,
    [AppliesDelivery] BIT            DEFAULT ((1)) NOT NULL,
    [AppliesReturn]   BIT            DEFAULT ((1)) NOT NULL,
    [CreatedAt]       DATETIME2 (7)  DEFAULT (sysdatetime()) NOT NULL,
    [UpdatedAt]       DATETIME2 (7)  NULL,
    [CreatedBy]       NVARCHAR (100) NULL,
    [UpdatedBy]       NVARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_DashboardCustomerConfig_Report_Customer] UNIQUE NONCLUSTERED ([ReportKey] ASC, [CustomerId] ASC)
);

