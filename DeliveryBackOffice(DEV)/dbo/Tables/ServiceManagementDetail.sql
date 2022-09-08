CREATE TABLE [dbo].[ServiceManagementDetail] (
    [IdServiceManagementDetail]    BIGINT          IDENTITY (1, 1) NOT NULL,
    [ServiceManagement]            INT             NOT NULL,
    [ServiceStartDate]             DATETIME        NOT NULL,
    [ServiceEndDate]               DATETIME        NOT NULL,
    [ServiceVisitPointId]          INT             NULL,
    [ServiceVisitPointPortfolioId] BIGINT          NULL,
    [ServiceCustomerName]          NVARCHAR (100)  NOT NULL,
    [ProvinceId]                   INT             NOT NULL,
    [TownshipId]                   INT             NOT NULL,
    [SettlementId]                 BIGINT          NULL,
    [ServiceAddress]               NVARCHAR (600)  NOT NULL,
    [ServiceSpecialInstructions]   NVARCHAR (600)  NULL,
    [ServicePhone]                 NVARCHAR (20)   NULL,
    [HubLogisticsId]               INT             NULL,
    [ServiceAmount]                DECIMAL (18, 2) CONSTRAINT [DF_ServiceManagementDetail_ServiceAmount] DEFAULT ((0)) NOT NULL,
    [ServiceExtraAmount]           DECIMAL (18, 2) CONSTRAINT [DF_ServiceManagementDetail_ServiceExtraAmount] DEFAULT ((0)) NOT NULL,
    [TypeVehicleId]                INT             NULL,
    [SubTypeServiceManagmentId]    BIGINT          NOT NULL,
    [RowStatus]                    BIT             NOT NULL,
    [TokenCreated]                 NVARCHAR (50)   NOT NULL,
    [DateCreated]                  DATETIME        NOT NULL,
    [TokenUpdated]                 NVARCHAR (50)   NULL,
    [DateUpdated]                  DATETIME        NULL,
    CONSTRAINT [PK_ServiceManagementDetail] PRIMARY KEY CLUSTERED ([IdServiceManagementDetail] ASC),
    CONSTRAINT [FK_ServiceManagementDetail_CatTypeVehicle] FOREIGN KEY ([TypeVehicleId]) REFERENCES [dbo].[CatTypeVehicle] ([IdTypeVehicle]),
    CONSTRAINT [FK_ServiceManagementDetail_HubLogistics] FOREIGN KEY ([HubLogisticsId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_ServiceManagementDetail_Province] FOREIGN KEY ([ProvinceId]) REFERENCES [dbo].[Province] ([IdProvince]),
    CONSTRAINT [FK_ServiceManagementDetail_ServiceManagement] FOREIGN KEY ([ServiceManagement]) REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement]),
    CONSTRAINT [FK_ServiceManagementDetail_Settlement] FOREIGN KEY ([SettlementId]) REFERENCES [dbo].[Settlement] ([IdSettlement]),
    CONSTRAINT [FK_ServiceManagementDetail_SubTypeServiceManagment] FOREIGN KEY ([SubTypeServiceManagmentId]) REFERENCES [dbo].[SubTypeServiceManagment] ([IdSubTypeServiceManagment]),
    CONSTRAINT [FK_ServiceManagementDetail_Township] FOREIGN KEY ([TownshipId]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FK_ServiceManagementDetail_VisitPointByClientPortfolio] FOREIGN KEY ([ServiceVisitPointPortfolioId]) REFERENCES [dbo].[VisitPointByClientPortfolio] ([IdVisitPointByClientPortfolio]),
    CONSTRAINT [FK_ServiceManagementDetail_VisitPointClient] FOREIGN KEY ([ServiceVisitPointId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementDetail', @level2type = N'COLUMN', @level2name = N'ServiceVisitPointPortfolioId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del VisitPoint, Foránea VisitPointClient (Valor 0 es un punto vacío)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementDetail', @level2type = N'COLUMN', @level2name = N'ServiceVisitPointId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de finalización del servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementDetail', @level2type = N'COLUMN', @level2name = N'ServiceEndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de inicio del servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementDetail', @level2type = N'COLUMN', @level2name = N'ServiceStartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del Servicio, Foránea ServiceManagement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementDetail', @level2type = N'COLUMN', @level2name = N'ServiceManagement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de tabla ServiceManagementDetail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagementDetail', @level2type = N'COLUMN', @level2name = N'IdServiceManagementDetail';

