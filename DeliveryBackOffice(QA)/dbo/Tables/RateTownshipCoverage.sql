CREATE TABLE [dbo].[RateTownshipCoverage] (
    [IdRateTownshipCoverage] INT           IDENTITY (1, 1) NOT NULL,
    [RateId]                 INT           NOT NULL,
    [TownshipSourceId]       INT           NOT NULL,
    [TownshipDestinyId]      INT           NOT NULL,
    [SegmentTypeId]          INT           NOT NULL,
    [RowStatus]              BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]           NVARCHAR (50) NOT NULL,
    [DateCreated]            DATETIME      NOT NULL,
    [TokenUpdated]           NVARCHAR (50) NULL,
    [DateUpdated]            DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdRateTownshipCoverage] ASC),
    CONSTRAINT [FK_RateTownshipCoverage_AssignedSegment] FOREIGN KEY ([SegmentTypeId]) REFERENCES [dbo].[CatRateSegment] ([CrsId]),
    CONSTRAINT [FK_RateTownshipCoverage_RateHeader] FOREIGN KEY ([RateId]) REFERENCES [dbo].[RateHeader] ([RheId]),
    CONSTRAINT [FK_RateTownshipCoverage_TownshipDestiny] FOREIGN KEY ([TownshipDestinyId]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FK_RateTownshipCoverage_TownshipSource] FOREIGN KEY ([TownshipSourceId]) REFERENCES [dbo].[Township] ([IdTownship])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del segmento de la tabla CatRateSegment.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'SegmentTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del municipio  de destino de la tabla Township.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'TownshipDestinyId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del municipio de origen de la tabla Township.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'TownshipSourceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tarifario de la tabla RateHeader.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'RateId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateTownshipCoverage', @level2type = N'COLUMN', @level2name = N'IdRateTownshipCoverage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de coberturas por municipio de tarifarios.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateTownshipCoverage';

