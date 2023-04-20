CREATE TABLE [dbo].[Service] (
    [IdService]                      BIGINT          IDENTITY (1, 1) NOT NULL,
    [RouteAssignmentId]              BIGINT          NULL,
    [ServiceStatusId]                INT             NOT NULL,
    [ServiceProvince]                INT             NOT NULL,
    [ServiceTownship]                INT             NOT NULL,
    [ServiceSettlement]              BIGINT          NULL,
    [VisitPointCodeOfReference]      INT             NULL,
    [VisitPointPortfolioId]          BIGINT          NULL,
    [HubLogisticsId]                 INT             NULL,
    [StartTime]                      DATETIME        NULL,
    [FinishTime]                     DATETIME        NULL,
    [AlterStartTime]                 DATETIME        NULL,
    [AlterFinishTime]                DATETIME        NULL,
    [ServiceCustomerName]            NVARCHAR (200)  NOT NULL,
    [ServicePhone]                   NVARCHAR (200)  NOT NULL,
    [ServiceAddress]                 NVARCHAR (600)  NOT NULL,
    [ServiceSpecialInstructions]     NVARCHAR (600)  NULL,
    [ServiceAmount]                  DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [ServiceExtraAmount]             DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [ExpectedVehicleType]            INT             NULL,
    [ServiceSubType]                 BIGINT          NOT NULL,
    [AssignmentAttemptCourier]       INT             NULL,
    [IsClosed]                       BIT             DEFAULT ((0)) NOT NULL,
    [IsCompleted]                    BIT             DEFAULT ((0)) NOT NULL,
    [IsFailed]                       BIT             DEFAULT ((0)) NOT NULL,
    [IsCanceled]                     BIT             DEFAULT ((0)) NOT NULL,
    [ServiceVirtualOrder]            DECIMAL (5, 2)  DEFAULT ((0)) NOT NULL,
    [IsCustomerReschedule]           BIT             DEFAULT ((0)) NOT NULL,
    [IsOpenProcess]                  BIT             DEFAULT ((0)) NOT NULL,
    [OpenProcessUser]                NVARCHAR (50)   NULL,
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
    [CODSettlementShipTotal]         DECIMAL (18, 2) NULL,
    [CODSettlementCODTotal]          DECIMAL (18, 2) NULL,
    [CODSettlementToken]             NVARCHAR (50)   NULL,
    [CODSettlementDate]              DATETIME        NULL,
    [RowStatus]                      BIT             DEFAULT ((1)) NOT NULL,
    [DateCreated]                    DATETIME        NOT NULL,
    [TokenCreated]                   NVARCHAR (50)   NOT NULL,
    [DateUpdated]                    DATETIME        NULL,
    [TokenUpdated]                   NVARCHAR (50)   NULL,
    PRIMARY KEY CLUSTERED ([IdService] ASC),
    CONSTRAINT [FK_Service_ExpectedVehicle] FOREIGN KEY ([ExpectedVehicleType]) REFERENCES [dbo].[CatTypeVehicle] ([IdTypeVehicle]),
    CONSTRAINT [FK_Service_HubLogistic] FOREIGN KEY ([HubLogisticsId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_Service_Portfolio] FOREIGN KEY ([VisitPointPortfolioId]) REFERENCES [dbo].[VisitPointByClientPortfolio] ([IdVisitPointByClientPortfolio]),
    CONSTRAINT [FK_Service_Province] FOREIGN KEY ([ServiceProvince]) REFERENCES [dbo].[Province] ([IdProvince]),
    CONSTRAINT [FK_Service_RouteAssignment] FOREIGN KEY ([RouteAssignmentId]) REFERENCES [dbo].[RouteAssignment] ([IdRouteAssignment]),
    CONSTRAINT [FK_Service_Settlement] FOREIGN KEY ([ServiceSettlement]) REFERENCES [dbo].[Settlement] ([IdSettlement]),
    CONSTRAINT [FK_Service_StationCODSettlement] FOREIGN KEY ([CODSettlementStationId]) REFERENCES [dbo].[CatStation] ([IdStation]),
    CONSTRAINT [FK_Service_StationSettlement] FOREIGN KEY ([SettlementStationId]) REFERENCES [dbo].[CatStation] ([IdStation]),
    CONSTRAINT [FK_Service_Status] FOREIGN KEY ([ServiceStatusId]) REFERENCES [dbo].[CatServiceStatus] ([IdServiceStatus]),
    CONSTRAINT [FK_Service_SubType] FOREIGN KEY ([ServiceSubType]) REFERENCES [dbo].[SubTypeServiceManagment] ([IdSubTypeServiceManagment]),
    CONSTRAINT [FK_Service_Township] FOREIGN KEY ([ServiceTownship]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FK_Service_VisitPoint] FOREIGN KEY ([VisitPointCodeOfReference]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de liquidación de COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'CODSettlementDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de liquidación de COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'CODSettlementToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de COD liquidado en COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'CODSettlementCODTotal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de envío liquidado en COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'CODSettlementShipTotal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de guías liquidadas en COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'CODSettlementGuides';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de estación de liquidación de COD de la tabla CatStation.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'CODSettlementStationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de liquidación de paquetes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de liquidación de paquetes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas frías liquidadas bajo recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementPiecesColdPicked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas secas liquidadas bajo recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementPiecesDryPicked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de guías liquidadas bajo recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementGuidesPicked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas frías liquidadas bajo traslado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementPiecesColdTransfered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas secas liquidadas bajo traslado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementPiecesDryTransfered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de guías liquidadas bajo traslado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementGuidesTransfered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas frías liquidadas bajo reproceso (Retornadas a instalaciones).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementPiecesColdReprocess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas secas liquidadas bajo reproceso (Retornadas a instalaciones).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementPiecesDryReprocess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de guías liquidadas bajo reproceso (Retornadas a instalaciones).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementGuidesReprocess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas frías liquidadas bajo entrega.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementPiecesColdDelivered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas secas liquidadas bajo entrega.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementPiecesDryDelivered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de guías liquidadas bajo entrega.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementGuidesDelivered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de estación de liquidación de paquetes de la tabla CatStation.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'SettlementStationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario quien tiene el registro en un proceso abierto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'OpenProcessUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si el registro esta en un proceso abierto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'IsOpenProcess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si el servicio fue recalendarizado por el cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'IsCustomerReschedule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden virtual de ejecución del servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'ServiceVirtualOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si se cancelo el servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'IsCanceled';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si hubo una incidencia en el servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'IsFailed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si se completo el servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'IsCompleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si el registro esta cerrado y no puede ser operado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'IsClosed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del posible courier a atender el servicio de la tabla SenderReceiver.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'AssignmentAttemptCourier';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de servicio de la tabla SubTypeServiceManagment.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'ServiceSubType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de vehículo esperado en el servicio de la tabla CatTypeVehicle.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'ExpectedVehicleType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de COD total del servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'ServiceExtraAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de envío total del servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'ServiceAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Instrucciones adicionales del cliente final del servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'ServiceSpecialInstructions';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dirección del cliente final del servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'ServiceAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Teléfono del cliente final del servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'ServicePhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del cliente final del servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'ServiceCustomerName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora alterna de finalización esperado para realizar el servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'AlterFinishTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora alterna de inicio esperado para realizar el servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'AlterStartTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de finalización esperado para realizar el servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'FinishTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de inicio esperado para realizar el servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'StartTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del hub que opera el servicio de la tabla HubLogistics.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'HubLogisticsId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de cartera de clientes de la tabla VisitPointByClientPortfolio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'VisitPointPortfolioId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del punto de visita de la tabla VisitPointClient.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'VisitPointCodeOfReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del poblado de la tabla Settlement.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'ServiceSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del municipio de la tabla Township.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'ServiceTownship';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del departamento de la tabla Province.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'ServiceProvince';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del estado del servicio de la tabla CatServiceStatus.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'ServiceStatusId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la ruta a la que esta asignada el servicio de la tabla RouteAssignment.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'RouteAssignmentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service', @level2type = N'COLUMN', @level2name = N'IdService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de servicios.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Service';

