CREATE TABLE [dbo].[UnifiedRouteSettlement] (
    [IdUnifiedRouteSettlement] INT           IDENTITY (1, 1) NOT NULL,
    [RouteAssignmentId]        INT           NOT NULL,
    [TotalGuidesSettled]       INT           DEFAULT ((0)) NOT NULL,
    [TotalPiecesSettled]       INT           DEFAULT ((0)) NOT NULL,
    [TotalPiecesMissing]       INT           DEFAULT ((0)) NOT NULL,
    [UserSettlement]           NVARCHAR (50) NULL,
    [DateSettlement]           DATETIME      NULL,
    [SettlementStation]        INT           NULL,
    [TotalCODGuidesSettled]    INT           DEFAULT ((0)) NOT NULL,
    [UserCODSettlement]        NVARCHAR (50) NULL,
    [DateCODSettlement]        DATETIME      NULL,
    [CODSettlementStation]     INT           NULL,
    [RowStatus]                BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]             NVARCHAR (50) NOT NULL,
    [DateCreated]              DATETIME      NOT NULL,
    [TokenUpdated]             NVARCHAR (50) NULL,
    [DateUpdated]              DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdUnifiedRouteSettlement] ASC),
    CONSTRAINT [FK_UnifiedRouteSettlement_CODSettlementStation] FOREIGN KEY ([CODSettlementStation]) REFERENCES [dbo].[CatStation] ([IdStation]),
    CONSTRAINT [FK_UnifiedRouteSettlement_RouteAssignment] FOREIGN KEY ([RouteAssignmentId]) REFERENCES [dbo].[RouteAssigment] ([IdRouteAssigment]),
    CONSTRAINT [FK_UnifiedRouteSettlement_SettlementStation] FOREIGN KEY ([SettlementStation]) REFERENCES [dbo].[CatStation] ([IdStation])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de encabezado para liquidación de rutas unificadas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de usuario quien liquido la ruta (por paquetes).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'UserSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario quien liquido la ruta por COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'UserCODSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas de guías liquidadas (como paquete).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'TotalPiecesSettled';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de piezas de guías faltantes (como paquete).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'TotalPiecesMissing';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad total de guías liquidadas (como paquete).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'TotalGuidesSettled';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de guías que se liquido COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'TotalCODGuidesSettled';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estación donde se liquido la ruta  (por paquetes).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'SettlementStation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la asgianción de ruta de la tabla RouteAssigment.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'RouteAssignmentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'IdUnifiedRouteSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de liquidación de la ruta (por paquetes).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'DateSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de liquidación de ruta por COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'DateCODSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estación donde se liquido la ruta por COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlement', @level2type = N'COLUMN', @level2name = N'CODSettlementStation';

