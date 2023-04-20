CREATE TABLE [dbo].[ServiceDetail] (
    [IdServiceDetail]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [ServiceId]              BIGINT          NOT NULL,
    [GuideSerie]             NVARCHAR (2)    NOT NULL,
    [GuideNumber]            INT             NOT NULL,
    [ServiceAmount]          DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [ServiceExtraAmount]     DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [IsClosed]               BIT             DEFAULT ((0)) NOT NULL,
    [SettlementStationId]    INT             NULL,
    [IsPicked]               BIT             DEFAULT ((0)) NOT NULL,
    [IsDelivered]            BIT             DEFAULT ((0)) NOT NULL,
    [IsTransfered]           BIT             DEFAULT ((0)) NOT NULL,
    [IsReprocess]            BIT             DEFAULT ((0)) NOT NULL,
    [SettlementToken]        NVARCHAR (50)   NULL,
    [SettlementDate]         DATETIME        NULL,
    [CODSettlementStationId] INT             NULL,
    [CODSettlementShipTotal] DECIMAL (18, 2) NULL,
    [CODSettlementCODTotal]  DECIMAL (18, 2) NULL,
    [CODSettlementToken]     NVARCHAR (50)   NULL,
    [CODSettlementDate]      DATETIME        NULL,
    [RowStatus]              BIT             DEFAULT ((1)) NOT NULL,
    [DateCreated]            DATETIME        NOT NULL,
    [TokenCreated]           NVARCHAR (50)   NOT NULL,
    [DateUpdated]            DATETIME        NULL,
    [TokenUpdated]           NVARCHAR (50)   NULL,
    PRIMARY KEY CLUSTERED ([IdServiceDetail] ASC),
    CONSTRAINT [FK_ServiceDetail_Guide] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_ServiceDetail_Service] FOREIGN KEY ([ServiceId]) REFERENCES [dbo].[Service] ([IdService]),
    CONSTRAINT [FK_ServiceDetail_StationCODSettlement] FOREIGN KEY ([CODSettlementStationId]) REFERENCES [dbo].[CatStation] ([IdStation]),
    CONSTRAINT [FK_ServiceDetail_StationSettlement] FOREIGN KEY ([SettlementStationId]) REFERENCES [dbo].[CatStation] ([IdStation])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de liquidación de COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'CODSettlementDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de liquidación de COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'CODSettlementToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de COD liquidado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'CODSettlementCODTotal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de envío liquidado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'CODSettlementShipTotal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de estación de liquidación de COD de la tabla CatStation.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'CODSettlementStationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de liquidación de paquetes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'SettlementDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de liquidación de paquetes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'SettlementToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si el servicio fue reprocesado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'IsReprocess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si el servicio fue trasladado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'IsTransfered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si el servicio fue entregado o devuelto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'IsDelivered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si el servicio fue recolectado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'IsPicked';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de estación de liquidación de paquetes de la tabla CatStation.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'SettlementStationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si el registro esta cerrado y ya no puede ser operado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'IsClosed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de COD del servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'ServiceExtraAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de envío del servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'ServiceAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del servicio de la tabla Service.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'ServiceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail', @level2type = N'COLUMN', @level2name = N'IdServiceDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de guías relacionadas a servicios.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetail';

