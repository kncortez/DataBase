CREATE TABLE [dbo].[LinehaulRoutePreparationActDetail] (
    [IdLinehaulRoutePreparationActDetail] INT           IDENTITY (1, 1) NOT NULL,
    [LinehaulRoutePreparationActId]       INT           NOT NULL,
    [GuideSerie]                          NVARCHAR (2)  NOT NULL,
    [GuideNumber]                         INT           NOT NULL,
    [GuideDryPieceTotal]                  INT           NOT NULL,
    [GuideColdPieceTotal]                 INT           NOT NULL,
    [DryPieceQuantity]                    INT           NOT NULL,
    [ColdPieceQuantity]                   INT           NOT NULL,
    [RowStatus]                           BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                        NVARCHAR (50) NOT NULL,
    [DateCreated]                         DATETIME      NOT NULL,
    [TokenUpdated]                        NVARCHAR (50) NULL,
    [DateUpdated]                         DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRoutePreparationActDetail] ASC),
    CONSTRAINT [FK_LinehaulRoutePreparationActDetail_Act] FOREIGN KEY ([LinehaulRoutePreparationActId]) REFERENCES [dbo].[LinehaulRoutePreparationAct] ([IdLinehaulRoutePreparationAct]),
    CONSTRAINT [FK_LinehaulRoutePreparationActDetail_Guide] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [UQ_LinehaulRoutePreparationActDetail_ActGuide] UNIQUE NONCLUSTERED ([LinehaulRoutePreparationActId] ASC, [GuideSerie] ASC, [GuideNumber] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas frías escaneadas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail', @level2type = N'COLUMN', @level2name = N'ColdPieceQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas secas escaneadas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail', @level2type = N'COLUMN', @level2name = N'DryPieceQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total de piezas frías asignadas a la guía enlazada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail', @level2type = N'COLUMN', @level2name = N'GuideColdPieceTotal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Total de piezas secas asignadas a la guía enlazada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail', @level2type = N'COLUMN', @level2name = N'GuideDryPieceTotal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía asignada | Tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guía asignada | Tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de encabezado de asignación de acta a preparación de ruta | Tabla LinehaulRoutePreparationAct', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail', @level2type = N'COLUMN', @level2name = N'LinehaulRoutePreparationActId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail', @level2type = N'COLUMN', @level2name = N'IdLinehaulRoutePreparationActDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de detalle de actas (justificaciones) asignadas a un proceso de preparación de linehaul.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetail';

