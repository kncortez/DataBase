CREATE TABLE [dbo].[RoutePreparation] (
    [IdRoutePreparation]          INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CatRouteId]                  INT           NULL,
    [DateRoutePreparation]        DATE          NOT NULL,
    [GuidesQuantity]              SMALLINT      NOT NULL,
    [PiecesDry]                   SMALLINT      NOT NULL,
    [PiecesCold]                  SMALLINT      NOT NULL,
    [DeliveryOrderBySettlementId] BIGINT        NULL,
    [RowStatus]                   BIT           CONSTRAINT [df_RoutePreparation_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]                NVARCHAR (50) NOT NULL,
    [DateCreated]                 DATETIME      NOT NULL,
    [TokenUpdated]                NVARCHAR (50) NULL,
    [DateUpdated]                 DATETIME      NULL,
    [CatVehicleId]                INT           NULL,
    [IsSimpliRoute]               BIT           NULL,
    CONSTRAINT [PK_RoutePreparation_IdRoutePreparation] PRIMARY KEY CLUSTERED ([IdRoutePreparation] ASC),
    CONSTRAINT [FK_RoutePreparation_CatRouteId] FOREIGN KEY ([CatRouteId]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    CONSTRAINT [FK_RoutePreparation_CatVehicleId] FOREIGN KEY ([CatVehicleId]) REFERENCES [dbo].[CatVehicle] ([IdVehicle]),
    CONSTRAINT [FK_RoutePreparation_DeliveryOrderBySettlementId] FOREIGN KEY ([DeliveryOrderBySettlementId]) REFERENCES [dbo].[DeliveryOrderBySettlement] ([ID])
);














GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar la información de la preparación de entregas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla RoutePreparation.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation', @level2type = N'COLUMN', @level2name = N'IdRoutePreparation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatRoute.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation', @level2type = N'COLUMN', @level2name = N'CatRouteId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de la preparación de entregas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation', @level2type = N'COLUMN', @level2name = N'DateRoutePreparation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de guías en la preparación de entregas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation', @level2type = N'COLUMN', @level2name = N'GuidesQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas secas en la preparación de entregas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation', @level2type = N'COLUMN', @level2name = N'PiecesDry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas frías en la preparación de entregas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation', @level2type = N'COLUMN', @level2name = N'PiecesCold';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatVehicle.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation', @level2type = N'COLUMN', @level2name = N'CatVehicleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la preparación de ruta fue generada desde Simpliroute.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparation', @level2type = N'COLUMN', @level2name = N'IsSimpliRoute';


GO
CREATE NONCLUSTERED INDEX [IDX_CatRouteId_DateRoutePreparation_RowStatus]
    ON [dbo].[RoutePreparation]([CatRouteId] ASC, [DateRoutePreparation] ASC, [RowStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_DateRoutePreparation]
    ON [dbo].[RoutePreparation]([DateRoutePreparation] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_IdRoutePreparation_RowStatus_DateRoutePreparation]
    ON [dbo].[RoutePreparation]([IdRoutePreparation] ASC, [RowStatus] ASC, [DateRoutePreparation] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_DeliveryOrderBySettlementId_RowStatus]
    ON [dbo].[RoutePreparation]([DeliveryOrderBySettlementId] ASC, [RowStatus] ASC);

