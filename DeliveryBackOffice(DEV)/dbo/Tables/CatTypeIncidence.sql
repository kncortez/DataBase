CREATE TABLE [dbo].[CatTypeIncidence] (
    [IdIncidenceType]          INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [NameIncidence]            VARCHAR (200)  NULL,
    [DescriptionIncidence]     VARCHAR (200)  NULL,
    [RowStatus]                BIT            NOT NULL,
    [TokenCreated]             VARCHAR (50)   NOT NULL,
    [DateCreated]              DATETIME       NOT NULL,
    [TokenUpdated]             VARCHAR (50)   NULL,
    [DateUpdated]              DATETIME       NULL,
    [ServiceType]              NVARCHAR (25)  NULL,
    [OrderId]                  INT            NULL,
    [Code]                     INT            NULL,
    [IncidenceClasificationId] INT            NULL,
    [IsForcedIncidence]        BIT            DEFAULT ((0)) NOT NULL,
    [ValidatesLocation]        BIT            DEFAULT ((0)) NOT NULL,
    [HasConfirmationProcess]   BIT            DEFAULT ((0)) NOT NULL,
    [NotifiesOrigin]           BIT            DEFAULT ((0)) NOT NULL,
    [NameIncidencePublic]      VARCHAR (50)   NULL,
    [EvidenceRequirement]      BIT            NULL,
    [CourierInstructions]      NVARCHAR (100) NULL,
    [CountryId]                NVARCHAR (2)   NULL,
    [CatPartyResponsibleId]    INT            NULL,   
    PRIMARY KEY CLUSTERED ([IdIncidenceType] ASC),
    CONSTRAINT [FK_CatTypeIncidence_CatPartyResponsible] FOREIGN KEY ([CatPartyResponsibleId]) REFERENCES [dbo].[CatPartyResponsible] ([IdCatPartyResponsible])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogo de tipos de incidencias del sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del tipo de incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'IdIncidenceType';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre descriptivo del tipo de incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'NameIncidence';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción detallada del tipo de incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'DescriptionIncidence';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro: 1=Activo, 0=Inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token o identificador del usuario que creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token o identificador del usuario que actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'DateUpdated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de servicio asociado a la incidencia (DELIVERY, PICKUP, RETURN, etc.)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'ServiceType';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden de visualización o prioridad del tipo de incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'OrderId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código numérico identificador del tipo de incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'Code';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de clasificación de incidencia foráneo a tabla de clasificaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'IncidenceClasificationId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la incidencia esta forzada a ser incidencia en ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'IsForcedIncidence';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si incidencia valida ubicación para procesamiento.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'ValidatesLocation';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si incidencia genera una notificación para el remitente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'NotifiesOrigin';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si incidencia genera proceso de confirmación de incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'HasConfirmationProcess';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si requiere evidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'EvidenceRequirement';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Instrucciones para courierman', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'CourierInstructions';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre público o amigable para mostrar a clientes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'NameIncidencePublic';
GO 
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del país asociado al tipo de incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'CountryId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foránea a la tabla de partes responsables (Cliente/forza)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'CatPartyResponsibleId';
