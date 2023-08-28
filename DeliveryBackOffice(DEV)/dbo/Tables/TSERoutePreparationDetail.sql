CREATE TABLE [dbo].[TSERoutePreparationDetail] (
    [IDTSERoutePreparationDetail] INT           IDENTITY (1, 1) NOT NULL,
    [TSERoutePreparationHeaderID] INT           NOT NULL,
    [GuideSerie]                  NVARCHAR (2)  NOT NULL,
    [GuideNumber]                 INT           NOT NULL,
    [RowStatus]                   BIT           CONSTRAINT [DF_TSERoutePreparationDetail_RowStatus] DEFAULT ((1)) NOT NULL,
    [DateCreated]                 DATETIME      NOT NULL,
    [TokenCreated]                NVARCHAR (50) NOT NULL,
    [DateUpdated]                 DATETIME      NULL,
    [TokenUpdated]                NVARCHAR (50) NULL,
    CONSTRAINT [PK_TSERoutePreparationDetail] PRIMARY KEY CLUSTERED ([IDTSERoutePreparationDetail] ASC),
    CONSTRAINT [FK_TSERoutePreparationDetail_Guide] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'usuario de cración', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de la creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'número de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'llave foranea del encabezado de preparación de rutas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'TSERoutePreparationHeaderID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de detalle de preparación de ruta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'IDTSERoutePreparationDetail';


GO
CREATE NONCLUSTERED INDEX [idx_TSERoutePreparationDetail_TSERoutePreparationHeaderID]
    ON [dbo].[TSERoutePreparationDetail]([TSERoutePreparationHeaderID] ASC);

