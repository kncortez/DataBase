CREATE TABLE [dbo].[SettlementPickupStationDetail] (
    [IdSettlementPickupStationDetail] BIGINT          IDENTITY (1, 1) NOT NULL,
    [SettlementPickupStationId]       BIGINT          NOT NULL,
    [ServiceManagementId]             BIGINT          NOT NULL,
    [Price]                           DECIMAL (12, 2) NOT NULL,
    [SettlementSequence]              BIGINT          NULL,
    [SettlementStationId]             INT             NULL,
    [SettlementDate]                  DATETIME        NULL,
    [TokenSettlement]                 VARCHAR (50)    NULL,
    [RowStatus]                       BIT             NOT NULL,
    [TokenCreated]                    VARCHAR (50)    NOT NULL,
    [DateCreated]                     DATETIME        NOT NULL,
    [TokenUpdated]                    VARCHAR (50)    NULL,
    [DateUpdated]                     DATETIME        NULL,
    CONSTRAINT [PK__Settleme__B00337F96E48BBCA] PRIMARY KEY CLUSTERED ([IdSettlementPickupStationDetail] ASC),
    CONSTRAINT [FK__Settlemen__Settl__799DF262] FOREIGN KEY ([SettlementPickupStationId]) REFERENCES [dbo].[SettlementPickupStation] ([IdSettlementPickupStation]),
    CONSTRAINT [FK__Settlemen__Settl__7B863AD4] FOREIGN KEY ([SettlementStationId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [FK__Settlemen__Settl__7C7A5F0D] FOREIGN KEY ([SettlementPickupStationId]) REFERENCES [dbo].[SettlementPickupStation] ([IdSettlementPickupStation]),
    CONSTRAINT [FK__Settlemen__Settl__7D6E8346] FOREIGN KEY ([SettlementStationId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [FK__Settlemen__Settl__7E62A77F] FOREIGN KEY ([SettlementPickupStationId]) REFERENCES [dbo].[SettlementPickupStation] ([IdSettlementPickupStation])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Detalle de manifiesto de recolección asociado a cada courier.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id Detalle del manifiesto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail', @level2type = N'COLUMN', @level2name = N'IdSettlementPickupStationDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id manifiesto encabezado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail', @level2type = N'COLUMN', @level2name = N'SettlementPickupStationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Servicio de recolección asociado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail', @level2type = N'COLUMN', @level2name = N'ServiceManagementId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio del envío cuando aplique.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail', @level2type = N'COLUMN', @level2name = N'Price';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del manifiesto de la liquidación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail', @level2type = N'COLUMN', @level2name = N'SettlementSequence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estación o punto de venta donde se liquidan los servicios.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail', @level2type = N'COLUMN', @level2name = N'SettlementStationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de liquidación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail', @level2type = N'COLUMN', @level2name = N'SettlementDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del operador que lo liquidó.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail', @level2type = N'COLUMN', @level2name = N'TokenSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el registro está vigente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStationDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';

