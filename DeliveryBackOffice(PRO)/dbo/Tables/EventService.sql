CREATE TABLE [dbo].[EventService] (
    [IdEventService]      INT            IDENTITY (1, 1) NOT NULL,
    [ServiceManagementId] INT            NOT NULL,
    [ServiceStatusId]     INT            NOT NULL,
    [RowStauts]           BIT            NOT NULL,
    [TokenCreated]        NVARCHAR (50)  NOT NULL,
    [DateCreated]         DATETIME       NOT NULL,
    [Observations]        NVARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([IdEventService] ASC),
    CONSTRAINT [FKEventService] FOREIGN KEY ([ServiceManagementId]) REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement]),
    CONSTRAINT [FKEventStatus] FOREIGN KEY ([ServiceStatusId]) REFERENCES [dbo].[CatServiceStatus] ([IdServiceStatus])
);

