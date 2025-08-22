CREATE TABLE [dbo].[ContactIncident] (
    [ID]   TINYINT       IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_ContactIncident] PRIMARY KEY CLUSTERED ([ID] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ContactIncident',
    @level2type = N'COLUMN',
    @level2name = N'ID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre del incidente',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ContactIncident',
    @level2type = N'COLUMN',
    @level2name = N'Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catalogo de incidentes que se pueden dar al intentar contactar al receptor de paquete',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ContactIncident',
    @level2type = NULL,
    @level2name = NULL