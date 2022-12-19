CREATE TABLE [dbo].[UnifiedRouteSettlementDetail] (
    [IdUnifiedRouteSettlementDetail] INT             IDENTITY (1, 1) NOT NULL,
    [UnifiedRouteSettlementId]       INT             NOT NULL,
    [ServiceManagementId]            INT             NOT NULL,
    [GuideSerie]                     NVARCHAR (2)    NOT NULL,
    [GuideNumber]                    INT             NOT NULL,
    [PiecesSettled]                  INT             DEFAULT ((0)) NOT NULL,
    [PiecesMissing]                  INT             DEFAULT ((0)) NOT NULL,
    [ServiceSettlementAmount]        DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [ServiceCODSettlementAmount]     DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [UserSettlement]                 NVARCHAR (50)   NULL,
    [DateSettlement]                 DATETIME        NULL,
    [UserCODSettlement]              NVARCHAR (50)   NULL,
    [DateCODSettlement]              DATETIME        NULL,
    [IsOpenProcess]                  INT             DEFAULT ((0)) NOT NULL,
    [UserProcess]                    NVARCHAR (50)   NULL,
    [IsArrival]                      BIT             DEFAULT ((0)) NOT NULL,
    [IsReturn]                       BIT             DEFAULT ((0)) NOT NULL,
    [IsDelivered]                    BIT             DEFAULT ((0)) NOT NULL,
    [IsTransfered]                   BIT             DEFAULT ((0)) NOT NULL,
    [RowStatus]                      BIT             DEFAULT ((1)) NOT NULL,
    [TokenCreated]                   NVARCHAR (50)   NOT NULL,
    [DateCreated]                    DATETIME        NOT NULL,
    [TokenUpdated]                   NVARCHAR (50)   NULL,
    [DateUpdated]                    DATETIME        NULL,
    [IsLost]                         BIT             CONSTRAINT [DF_UnifiedRouteSettlementDetail_IsLost] DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdUnifiedRouteSettlementDetail] ASC),
    CONSTRAINT [FK_UnifiedRouteSettlementDetail_Guide] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_UnifiedRouteSettlementDetail_ServiceManagement] FOREIGN KEY ([ServiceManagementId]) REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la guía fue un paquete extraviado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'IsLost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la guía fue trasladada a un express center.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'IsTransfered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la guía fue entregada.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'IsDelivered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la guía esta retornando a forza por no haber sido entregada.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'IsReturn';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la guía fue recolectada y esta ingresando a las instalaciones.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'IsArrival';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario quien realiza el proceso abierto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'UserProcess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicador si la guía esta en un proceso abierto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'IsOpenProcess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha cuando se liquido COD la guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'DateCODSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de usuario quien liquido COD la guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'UserCODSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de liquidación de la guía (como paquete).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'DateSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de usuario quien liquido la guía (como paquete).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'UserSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto COD de la guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'ServiceCODSettlementAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto del servicio de la guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'ServiceSettlementAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas faltantes de la guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'PiecesMissing';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'PiecesSettled';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del servicio al que pertenece una guía de la tabla ServiceManagement.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'ServiceManagementId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de encabezado de liquidación de la tabla UnifiedRouteSettlement.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'UnifiedRouteSettlementId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail', @level2type = N'COLUMN', @level2name = N'IdUnifiedRouteSettlementDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de detalle de guías y servicios liquidados en liquidación unificada.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetail';

