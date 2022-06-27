CREATE TABLE [dbo].[ExtPlatformService] (
    [IdExtPlatformService] INT              IDENTITY (1, 1) NOT NULL,
    [ExtPlatformId]        INT              NOT NULL,
    [IdService]            INT              NOT NULL,
    [Reference]            NVARCHAR (10)    NULL,
    [TrackingData]         NVARCHAR (150)   NULL,
    [Plan]                 NVARCHAR (50)    NULL,
    [Route]                NVARCHAR (50)    NULL,
    [Order]                INT              NULL,
    [Address]              NVARCHAR (200)   NOT NULL,
    [Latitude]             DECIMAL (18, 15) NOT NULL,
    [Longitude]            DECIMAL (18, 15) NOT NULL,
    [Driver]               NVARCHAR (50)    NULL,
    [Vehicle]              NVARCHAR (50)    NULL,
    [Observation]          NVARCHAR (200)   NULL,
    [IsIncluded]           BIT              NOT NULL,
    [IsDelivery]           BIT              NOT NULL,
    [ServiceStatus]        NVARCHAR (30)    NULL,
    [EstimatedTimeArrival] DATETIME         NULL,
    [StartServiceDateTime] DATETIME         NULL,
    [EndServiceDateTime]   DATETIME         NULL,
    [CheckoutLatitude]     DECIMAL (18, 15) NULL,
    [CheckoutLongitude]    DECIMAL (18, 15) NULL,
    [RowStatus]            BIT              NOT NULL,
    [TokenCreated]         NVARCHAR (50)    NOT NULL,
    [DateCreated]          DATETIME         NOT NULL,
    [TokenUpdated]         NVARCHAR (50)    NULL,
    [DateUpdated]          DATETIME         NULL,
    [IsPreLocated]         BIT              NULL,
    PRIMARY KEY CLUSTERED ([IdExtPlatformService] ASC),
    CONSTRAINT [ExtPlatformService_PlatformId_FK] FOREIGN KEY ([ExtPlatformId]) REFERENCES [dbo].[CatExternalPlatform] ([IdExternalPlatform])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'IdExtPlatformService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la plataforma a la que pertenece el servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'ExtPlatformId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del servicio dentro de la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'IdService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referencia asignada por nosotros dentro de la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'Reference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Información de rastreo que provee la plataforma externa relacionado al servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'TrackingData';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del plan asociado al servicio, visto desde la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'Plan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la ruta asociada al servicio, visto desde la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'Route';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden en el que fue asignado el servicio en la ruta vista desde la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'Order';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Direccion que fue ingresada en la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latitud del servicio registrada en la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'Latitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitud del servicio registrada en la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'Longitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre identificador del usuario o courierman dentro de la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'Driver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre identificador del vehículo dentro de la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'Vehicle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Observacion respecto al servicio generado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'Observation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a si el servicio fue incluido dentro de la ruta/plan (1 representando su inclusión)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'IsIncluded';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a si es un servicio de entrega o de recoleccion (1 representando entrega)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'IsDelivery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado asignado dentro de la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'ServiceStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tiempo en que la plataforma externa predice que se atendera el servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'EstimatedTimeArrival';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se genera el servicio del lado de la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'StartServiceDateTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se completa el servicio del lado de la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'EndServiceDateTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latitud donde se registra el servicio al finalizarlo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'CheckoutLatitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitud donde se registra el servicio al finalizarlo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'CheckoutLongitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la ubicación fue obtenida desde base de datos (1) o si fue cálculada (0)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatformService', @level2type = N'COLUMN', @level2name = N'IsPreLocated';


GO


