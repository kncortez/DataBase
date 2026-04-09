
CREATE TABLE [dbo].[ServiceIncident] (
    [ServiceIncidentId] INT IDENTITY(1,1) NOT NULL,
    [ServiceId] INT NOT NULL,
    [CourierId] INT NOT NULL,
    [IncidentTypeId] INT NOT NULL,
	[IncidentId] INT NOT NULL,
    [CourierNotes] NVARCHAR(500) NULL,
	[CountryId] VARCHAR (2)   NULL,
	[HubId] INT NOT NULL,
    [CurrentAgentId] BIGINT NULL,
    [IncidentStatusId] INT NOT NULL,
	[Latitude] NVARCHAR (40) NULL,
	[Longitude] NVARCHAR (40) NULL,
	[IncidentPicturePath] NVARCHAR (500) NULL,
	[ReclassificationNotes] NVARCHAR(500) NULL,
	[ReclassifiedIncidentId] INT NULL,
	[AssignedAt] DATETIME NULL,
    [CompletedAt] DATETIME NULL,
	[IncidentConfirmed] BIT NULL,
	[IsPhotoVerified] BIT NULL,
	[IsLocationVerified] BIT NULL,
	[ServiceStillRequired] BIT NULL,
	[RescheduleCollectDate] DATETIME NULL,
    [DateCreated] DATETIME NOT NULL,
    [TokenCreated] NVARCHAR(50) NOT NULL,
	[DateUpdated]   DATETIME		NULL,
	[TokenUpdated]	NVARCHAR (50)	NULL,
    [RowStatus] BIT NOT NULL DEFAULT 1,
	PRIMARY KEY CLUSTERED ([ServiceIncidentId] ASC),
	CONSTRAINT FK_ServiceIncident_ServiceId FOREIGN KEY (ServiceId) REFERENCES dbo.ServiceManagement(IdServiceManagement),
	CONSTRAINT FK_ServiceIncident_CourierId FOREIGN KEY (CourierId) REFERENCES dbo.SenderReceiver(ID),
	CONSTRAINT FK_ServiceIncident_IncidentTypeId FOREIGN KEY (IncidentTypeId) REFERENCES dbo.CatServiceStatus(IdServiceStatus),
	CONSTRAINT FK_ServiceIncident_IncidentId FOREIGN KEY (IncidentId) REFERENCES dbo.CatTypeIncidence(IdIncidenceType),
	CONSTRAINT FK_ServiceIncident_CountryId FOREIGN KEY (CountryId) REFERENCES dbo.CatCountry(IdCountry),
	CONSTRAINT FK_ServiceIncident_HubId FOREIGN KEY (HubId) REFERENCES dbo.HubLogistics(IdHubLogistic),
	CONSTRAINT FK_ServiceIncident_CurrentAgentId FOREIGN KEY (CurrentAgentId) REFERENCES dbo.RegisterUser(UsrIdUser),
	CONSTRAINT FK_ServiceIncident_IncidentStatusId FOREIGN KEY (IncidentStatusId) REFERENCES dbo.IncidentStatus(IncidentStatusId),
	CONSTRAINT FK_ServiceIncident_ReclassifiedIncidentId FOREIGN KEY (IncidentId) REFERENCES dbo.CatTypeIncidence(IdIncidenceType)
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Identificador del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'ServiceIncidentId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'ID de ServiceManagement.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'ServiceId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'ID de SenderReceiver (Courier).',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'CourierId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'ID de CatServiceStatus.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'IncidentTypeId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'ID. de CatTypeIncidence',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'IncidentId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Observaciones del incidente.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'CourierNotes';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'ID. de CatCountry',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'CountryId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'ID. de HubLogistics',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'HubId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'ID. de agente asignado',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'CurrentAgentId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'ID. de IncidentStatus',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'IncidentStatusId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Latitud del lugar donde se registro la incidencia',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'Latitude';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Longitud del lugar donde se registro la incidencia',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'Longitude';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'URL de la ubicacion de la fotografia de la incidencia',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'IncidentPicturePath';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Comentarios sobre el cambio de incidencia',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'ReclassificationNotes';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Si la incidencia fue re clasificada',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'ReclassifiedIncidentId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Fecha en la que el agente se asigno el incidente',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'AssignedAt';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Fecha en la que el agente resolvio el incidente',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'CompletedAt';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Indica si la foto como evidencia fue aceptada.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'IsPhotoVerified';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Indica si la ubicación de la visita fallida fue aceptada.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'IsLocationVerified';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Indica si el agente determina si la incidencia es real.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'IncidentConfirmed';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Indica si el servicio aún es requerido',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'ServiceStillRequired';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Indica la nueva fecha para el servicio',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'RescheduleCollectDate';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Fecha de creación del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Token de creación del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Fecha de actualización del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'DateUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Token de actualización del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',
	@value = N'Estado lógico del registro.',
	@level0type = N'SCHEMA',
	@level0name = N'dbo',
	@level1type = N'TABLE',
	@level1name = N'ServiceIncident',
	@level2type = N'COLUMN',
	@level2name = N'RowStatus';
