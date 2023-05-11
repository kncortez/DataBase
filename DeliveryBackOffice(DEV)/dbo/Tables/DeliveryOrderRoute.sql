CREATE TABLE [dbo].[DeliveryOrderRoute] (
    [IdDeliveryOrderRoute] INT           IDENTITY (1, 1) NOT NULL,
    [GuideSerie]           NVARCHAR (2)  NOT NULL,
    [GuideNumber]          INT           NOT NULL,
    [Route]                NVARCHAR (50) NOT NULL,
    [IsPendingTransfer]    BIT           CONSTRAINT [DF_DeliveryOrderRoute_IsPendingTransfer] DEFAULT ((1)) NOT NULL,
    [RowStatus]            BIT           CONSTRAINT [DF_DeliveryOrderRoute_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]         NVARCHAR (50) NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [TokenUpdated]         NVARCHAR (50) NULL,
    [DateUpdated]          DATETIME      NULL,
    CONSTRAINT [PK_DeliveryOrderRoute] PRIMARY KEY ([IdDeliveryOrderRoute])
);


GO
CREATE NONCLUSTERED INDEX [IX_DeliveryOrderRoute]
    ON [dbo].[DeliveryOrderRoute]([GuideSerie] ASC, [GuideNumber] DESC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de modificación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderRoute', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de modificación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderRoute', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de creación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderRoute', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderRoute', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, 1=Activo 0=Borrado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderRoute', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para saber si la guía ya fué trasladada a una preparación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderRoute', @level2type = N'COLUMN', @level2name = N'IsPendingTransfer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la ruta que está asignada la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderRoute', @level2type = N'COLUMN', @level2name = N'Route';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía, foránea DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderRoute', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía, foránea DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderRoute', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de tabla DeliveryOrderRoute', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderRoute', @level2type = N'COLUMN', @level2name = N'IdDeliveryOrderRoute';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar las guías que contienen una ruta en SetServiceRoutes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderRoute';

