CREATE TABLE [dbo].[HubByRegion] (
    [IdHubByRegion] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [HubLogisticId] INT           NOT NULL,
    [RegionId]      INT           NOT NULL,
    [RowStatus]     BIT           NOT NULL,
    [TokenCreated]  NVARCHAR (50) NOT NULL,
    [DateCreated]   DATETIME      NOT NULL,
    [TokenUpdated]  NVARCHAR (50) NULL,
    [DateUpdated]   DATETIME      NULL,
    CONSTRAINT [PK_HubByRegion] PRIMARY KEY CLUSTERED ([IdHubByRegion] ASC),
    CONSTRAINT [FK_HubByRegin_Region] FOREIGN KEY ([RegionId]) REFERENCES [dbo].[CatRegion] ([IdCatRegion]),
    CONSTRAINT [FK_HubByRegion_HubLogistic] FOREIGN KEY ([HubLogisticId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [UK_HubLogisticId] UNIQUE NONCLUSTERED ([HubLogisticId] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_HubLogisticIdRegionId]
    ON [dbo].[HubByRegion]([HubLogisticId] ASC, [RegionId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registros de HUBs por región.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubByRegion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubByRegion', @level2type = N'COLUMN', @level2name = N'IdHubByRegion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del hub', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubByRegion', @level2type = N'COLUMN', @level2name = N'HubLogisticId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de la región', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubByRegion', @level2type = N'COLUMN', @level2name = N'RegionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubByRegion', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubByRegion', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubByRegion', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubByRegion', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubByRegion', @level2type = N'COLUMN', @level2name = N'DateUpdated';

