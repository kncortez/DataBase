CREATE TABLE [dbo].[CorporateTownshipCoverage] (
    [IdCorporateTownshipCoverage] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TownshipSourceId]            INT           NOT NULL,
    [TownshipDestinyId]           INT           NOT NULL,
    [SegmentTypeId]               INT           NOT NULL,
    [RowStatus]                   BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                NVARCHAR (50) NOT NULL,
    [DateCreated]                 DATETIME      NOT NULL,
    [TokenUpdated]                NVARCHAR (50) NULL,
    [DateUpdated]                 DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdCorporateTownshipCoverage] ASC),
    CONSTRAINT [FK_CorporateTownshipCoverage_Segment] FOREIGN KEY ([SegmentTypeId]) REFERENCES [dbo].[CatRateSegment] ([CrsId]),
    CONSTRAINT [FK_CorporateTownshipCoverage_TownshipDest] FOREIGN KEY ([TownshipDestinyId]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FK_CorporateTownshipCoverage_TownshipOrig] FOREIGN KEY ([TownshipSourceId]) REFERENCES [dbo].[Township] ([IdTownship])
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CorporateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CorporateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CorporateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CorporateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CorporateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del segmento de la tabla CatRateSegment.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CorporateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'SegmentTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del municipio  de destino de la tabla Township.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CorporateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'TownshipDestinyId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del municipio de origen de la tabla Township.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CorporateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'TownshipSourceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CorporateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'IdCorporateTownshipCoverage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de coberturas por municipio de corporativos.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CorporateTownshipCoverage';


GO
CREATE NONCLUSTERED INDEX [idx_TownshipSourceId]
    ON [dbo].[CorporateTownshipCoverage]([TownshipSourceId] ASC);


GO



GO
