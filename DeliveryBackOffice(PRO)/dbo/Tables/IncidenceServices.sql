CREATE TABLE [dbo].[IncidenceServices] (
    [IdIncidence]          INT            IDENTITY (1, 1) NOT NULL,
    [ServiceManagementId]  INT            NULL,
    [IncidenceTypeId]      INT            NULL,
    [DescriptionIncidence] VARCHAR (300)  NULL,
    [Latitude]             VARCHAR (30)   NULL,
    [Longitude]            VARCHAR (30)   NULL,
    [Accuracy]             VARCHAR (30)   NULL,
    [RowStatus]            BIT            NOT NULL,
    [TokenCreated]         VARCHAR (50)   NOT NULL,
    [DateCreated]          DATETIME       NOT NULL,
    [TokenUpdated]         VARCHAR (50)   NULL,
    [DateUpdated]          DATETIME       NULL,
    [Guide]                NVARCHAR (25)  NULL,
    [Observations]         NVARCHAR (250) NULL,
    PRIMARY KEY CLUSTERED ([IdIncidence] ASC),
    CONSTRAINT [FKIncidentRecolection] FOREIGN KEY ([ServiceManagementId]) REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement]),
    CONSTRAINT [FKIncidenTypProduct] FOREIGN KEY ([IncidenceTypeId]) REFERENCES [dbo].[CatTypeIncidence] ([IdIncidenceType])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de actualziacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de administracion de servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'ServiceManagementId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'stado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'observaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'Observations';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'longitud', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'Longitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'latitud', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'Latitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipo de incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'IncidenceTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'IdIncidence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'Guide';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'descripcion de incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'DescriptionIncidence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualizacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'feha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'precisión', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceServices', @level2type = N'COLUMN', @level2name = N'Accuracy';

