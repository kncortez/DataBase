CREATE TABLE [dbo].[EventService] (
    [IdEventService]      INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
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






GO
CREATE NONCLUSTERED INDEX [IDX_ServiceManagementId_ServiceStatusId_RowStauts]
    ON [dbo].[EventService]([ServiceManagementId] ASC, [ServiceStatusId] ASC, [RowStauts] ASC);

