CREATE TABLE [dbo].[RouteAssignment] (
    [IdRouteAssignment]              BIGINT          IDENTITY (1, 1) NOT NULL,
    [CourierId]                      INT             NULL,
    [RouteId]                        INT             NOT NULL,
    [VehicleId]                      INT             NULL,
    [IsClosed]                       BIT             DEFAULT ((0)) NOT NULL,
    [DateOfAssignment]               DATE            NOT NULL,
    [StartingMileage]                INT             NOT NULL,
    [CompletedMileage]               INT             NOT NULL,
    [DispatchStationId]              INT             NULL,
    [DispatchGuides]                 INT             NULL,
    [DispatchPiecesDry]              INT             NULL,
    [DispatchPiecesCold]             INT             NULL,
    [SettlementStationId]            INT             NULL,
    [SettlementGuidesDelivered]      INT             NULL,
    [SettlementPiecesDryDelivered]   INT             NULL,
    [SettlementPiecesColdDelivered]  INT             NULL,
    [SettlementGuidesReprocess]      INT             NULL,
    [SettlementPiecesDryReprocess]   INT             NULL,
    [SettlementPiecesColdReprocess]  INT             NULL,
    [SettlementGuidesTransfered]     INT             NULL,
    [SettlementPiecesDryTransfered]  INT             NULL,
    [SettlementPiecesColdTransfered] INT             NULL,
    [SettlementGuidesPicked]         INT             NULL,
    [SettlementPiecesDryPicked]      INT             NULL,
    [SettlementPiecesColdPicked]     INT             NULL,
    [SettlementToken]                NVARCHAR (50)   NULL,
    [SettlementDate]                 DATETIME        NULL,
    [CODSettlementStationId]         INT             NULL,
    [CODSettlementGuides]            INT             NULL,
    [CODSettlementTotal]             DECIMAL (18, 2) NULL,
    [CODSettlementToken]             NVARCHAR (50)   NULL,
    [CODSettlementDate]              DATETIME        NULL,
    [RowStatus]                      BIT             DEFAULT ((1)) NOT NULL,
    [DateCreated]                    DATETIME        NOT NULL,
    [TokenCreated]                   NVARCHAR (50)   NOT NULL,
    [DateUpdated]                    DATETIME        NULL,
    [TokenUpdated]                   NVARCHAR (50)   NULL,
    PRIMARY KEY CLUSTERED ([IdRouteAssignment] ASC),
    CONSTRAINT [FK_RouteAssignment_Courier] FOREIGN KEY ([CourierId]) REFERENCES [dbo].[SenderReceiver] ([ID]),
    CONSTRAINT [FK_RouteAssignment_Route] FOREIGN KEY ([RouteId]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    CONSTRAINT [FK_RouteAssignment_StationCODSettlement] FOREIGN KEY ([CODSettlementStationId]) REFERENCES [dbo].[CatStation] ([IdStation]),
    CONSTRAINT [FK_RouteAssignment_StationDispatch] FOREIGN KEY ([DispatchStationId]) REFERENCES [dbo].[CatStation] ([IdStation]),
    CONSTRAINT [FK_RouteAssignment_StationSettlement] FOREIGN KEY ([SettlementStationId]) REFERENCES [dbo].[CatStation] ([IdStation]),
    CONSTRAINT [FK_RouteAssignment_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[CatVehicle] ([IdVehicle]),
    UNIQUE NONCLUSTERED ([DateOfAssignment] ASC, [CourierId] ASC),
    UNIQUE NONCLUSTERED ([DateOfAssignment] ASC, [RouteId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de liquidación de COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'CODSettlementDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de liquidación de COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'CODSettlementToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total liquidado en COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'CODSettlementTotal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de guías liquidadas en COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'CODSettlementGuides';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de estación de liquidación de COD de la tabla CatStation.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'CODSettlementStationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de liquidación de paquetes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de liquidación de paquetes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas frías liquidadas bajo recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementPiecesColdPicked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas secas liquidadas bajo recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementPiecesDryPicked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de guías liquidadas bajo recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementGuidesPicked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas frías liquidadas bajo traslado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementPiecesColdTransfered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas secas liquidadas bajo traslado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementPiecesDryTransfered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de guías liquidadas bajo traslado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementGuidesTransfered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas frías liquidadas bajo reproceso (Retornadas a instalaciones).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementPiecesColdReprocess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas secas liquidadas bajo reproceso (Retornadas a instalaciones).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementPiecesDryReprocess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de guías liquidadas bajo reproceso (Retornadas a instalaciones).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementGuidesReprocess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas frías liquidadas bajo entrega.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementPiecesColdDelivered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas secas liquidadas bajo entrega.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementPiecesDryDelivered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de guías liquidadas bajo entrega.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementGuidesDelivered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de estación de liquidación de paquetes de la tabla CatStation.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'SettlementStationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas frías despachadas en ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'DispatchPiecesCold';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas secas despachadas en ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'DispatchPiecesDry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de guías despachadas en ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'DispatchGuides';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de estación de despacho de la tabla CatStation.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'DispatchStationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kilometraje de entrada de la ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'CompletedMileage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kilometraje de salida de la ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'StartingMileage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de asignación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'DateOfAssignment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si el registro esta cerrado y no puede ser operado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'IsClosed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del vehículo de la tabla CatVehicle.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'VehicleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la ruta de la tabla CatRoute.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'RouteId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del courier asignado a la ruta de la tabla SenderReceiver.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'CourierId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment', @level2type = N'COLUMN', @level2name = N'IdRouteAssignment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de asignación de rutas a couriers.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssignment';

