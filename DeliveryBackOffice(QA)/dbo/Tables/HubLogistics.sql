CREATE TABLE [dbo].[HubLogistics] (
    [IdHubLogistic]   INT           IDENTITY (1, 1) NOT NULL,
    [HubName]         VARCHAR (50)  NULL,
    [HubAbbreviation] VARCHAR (5)   NULL,
    [HubStatus]       BIT           NULL,
    [IdStation]       INT           NULL,
    [IdCountry]       VARCHAR (2)   NULL,
    [TokenCreated]    VARCHAR (50)  NULL,
    [DateCreated]     DATETIME      NULL,
    [TokenUpdate]     VARCHAR (50)  NULL,
    [DateUpdated]     DATETIME      NULL,
    [IsGateway]       BIT           NULL,
    [HubLatitude]     NVARCHAR (20) NULL,
    [HubLongitude]    NVARCHAR (20) NULL,
    CONSTRAINT [PK_HubLogistics] PRIMARY KEY CLUSTERED ([IdHubLogistic] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [NonClusteredIndex-HubAbbreviation]
    ON [dbo].[HubLogistics]([HubAbbreviation] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Gateway 1, Hub 0', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'IsGateway';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'TokenUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la estación de la tabla CatStation.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'IdStation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'IdHubLogistic';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del pais de la tabla CatCountry.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'IdCountry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'HubStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre descriptivo del hub.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'HubName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Abreviación del Hub.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'HubAbbreviation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitud del hub.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'HubLongitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latitud del hub.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'HubLatitude';

