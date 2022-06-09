CREATE TABLE [dbo].[DeliveryOrderBySettlement] (
    [ID]                     BIGINT        IDENTITY (1, 1) NOT NULL,
    [Date_Printed]           DATETIME      NULL,
    [User_Dispatched]        NVARCHAR (50) NULL,
    [Date_Dispatched]        DATETIME      NULL,
    [Pieces_Dry_Dispatched]  SMALLINT      NULL,
    [Pieces_Cold_Dispatched] SMALLINT      NULL,
    [Guides_Dispatched]      SMALLINT      NULL,
    [User_Received]          NVARCHAR (50) NULL,
    [Date_Received]          DATETIME      NULL,
    [Pieces_Dry_Received]    SMALLINT      NULL,
    [Pieces_Cold_Received]   SMALLINT      NULL,
    [Guides_Received]        SMALLINT      NULL,
    [ID_Courier]             INT           NOT NULL,
    [Route_Dispatched]       DATETIME      NULL,
    [Route_Received]         DATETIME      NULL,
    [User_Received_COD]      NVARCHAR (50) NULL,
    [Date_Received_COD]      DATETIME      NULL,
    [Guides_Received_COD]    SMALLINT      NULL,
    [Route_Received_COD]     DATETIME      NULL,
    [DispatchedStationId]    INT           NULL,
    [SettlementStationId]    INT           NULL,
    [CatVehicleId]           INT           NULL,
    [CatRouteId]             INT           NULL,
    [StartingKilometers]     NVARCHAR (50) NULL,
    CONSTRAINT [PK_DeliveryOrderBySettlement] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DeliveryOrderBySettlement_CatRouteId] FOREIGN KEY ([CatRouteId]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    CONSTRAINT [FK_DeliveryOrderBySettlement_CatStationDispatch] FOREIGN KEY ([DispatchedStationId]) REFERENCES [dbo].[CatStation] ([IdStation]),
    CONSTRAINT [FK_DeliveryOrderBySettlement_CatStationSettlement] FOREIGN KEY ([SettlementStationId]) REFERENCES [dbo].[CatStation] ([IdStation]),
    CONSTRAINT [FK_DeliveryOrderBySettlement_CatVehicleId] FOREIGN KEY ([CatVehicleId]) REFERENCES [dbo].[CatVehicle] ([IdVehicle]),
    CONSTRAINT [FK_DeliveryOrderSettlement_SenderReceiver] FOREIGN KEY ([ID_Courier]) REFERENCES [dbo].[SenderReceiver] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20211209-170157]
    ON [dbo].[DeliveryOrderBySettlement]([Date_Received] ASC, [SettlementStationId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la estación donde se realizo el despacho', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderBySettlement', @level2type = N'COLUMN', @level2name = N'DispatchedStationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la estación donde se realizo la liquidación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderBySettlement', @level2type = N'COLUMN', @level2name = N'SettlementStationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del Vehículo en la tabla CatVehicle', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderBySettlement', @level2type = N'COLUMN', @level2name = N'CatVehicleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de la ruta en la tabla CatRoute', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderBySettlement', @level2type = N'COLUMN', @level2name = N'CatRouteId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kilómetros que tiene el Vehículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderBySettlement', @level2type = N'COLUMN', @level2name = N'StartingKilometers';

