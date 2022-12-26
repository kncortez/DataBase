CREATE TABLE [dbo].[ServiceDataForGuide] (
    [IdServiceDataForGuide] BIGINT           IDENTITY (1, 1) NOT NULL,
    [GuideSerie]            NVARCHAR (2)     NOT NULL,
    [GuideNumber]           INT              NOT NULL,
    [GuideToken]            NVARCHAR (50)    NOT NULL,
    [Latitude]              DECIMAL (18, 15) NULL,
    [Longitude]             DECIMAL (18, 15) NULL,
    [StartTime]             TIME (7)         NULL,
    [EndTime]               TIME (7)         NULL,
    [DateUsed]              DATETIME         NULL,
    [ProviderModule]        INT              NULL,
    [IsDelivery]            BIT              NOT NULL,
    [RowStatus]             BIT              NOT NULL,
    [TokenCreated]          NVARCHAR (50)    NOT NULL,
    [DateCreated]           DATETIME         NOT NULL,
    [TokenUpdated]          NVARCHAR (50)    NULL,
    [DateUpdated]           DATETIME         NULL,
    [StartTime2]            TIME (7)         NULL,
    [EndTime2]              TIME (7)         NULL,
    [Accuracy]              VARCHAR (20)     NULL,
    [IsInRoute]             BIT              DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([IdServiceDataForGuide] ASC),
    CONSTRAINT [ServiceDataForGuide_Guide_FK] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [ServiceDataForGuide_Module_FK] FOREIGN KEY ([ProviderModule]) REFERENCES [dbo].[CatModule] ([ModIdModule])
);






GO
CREATE NONCLUSTERED INDEX [IDX_IsDelivery]
    ON [dbo].[ServiceDataForGuide]([IsDelivery] ASC)
    INCLUDE([GuideSerie], [GuideNumber], [Latitude], [Longitude]);


GO
CREATE NONCLUSTERED INDEX [idx_GuideSerie_GuideNumber_IsDelivery]
    ON [dbo].[ServiceDataForGuide]([GuideSerie] ASC, [GuideNumber] ASC, [IsDelivery] ASC)
    INCLUDE([Latitude], [Longitude]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'IdServiceDataForGuide';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de acceso para landing page de captura de datos de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'GuideToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latitud donde se realizara el servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'Latitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitud donde se realizara el servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'Longitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Inicio de ventana horaria para realizar el servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'StartTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fin de ventana horaria para realizar el servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'EndTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en el que se registro la ultima asignacion de datos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'DateUsed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del modulo de donde proviene la informacion adicional, de ser ingresada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'ProviderModule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a si es un servicio de entrega o de recoleccion (1 siendo entrega)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'IsDelivery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Inicio de segunda ventana horaria para realizar el servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'StartTime2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fin de segunda ventana horaria para realizar el servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'EndTime2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'El radio aproximado en donde se úbica la ubicación (Latitud y Longitud)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'Accuracy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si el flujo es de una guía en ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDataForGuide', @level2type = N'COLUMN', @level2name = N'IsInRoute';

