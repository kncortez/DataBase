CREATE TABLE [dbo].[PackagesRangeDetail] (
    [IdPackagesRangeDetail] INT             IDENTITY (1, 1) NOT NULL,
    [PackagesRangeId]       INT             NULL,
    [CatRateSegmentId]      INT             NOT NULL,
    [Value]                 DECIMAL (18, 2) NOT NULL,
    [RowStatus]             BIT             CONSTRAINT [DF_PackagesRangeDetail_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]          NVARCHAR (50)   NOT NULL,
    [DateCreated]           DATETIME        NOT NULL,
    [TokenUpdated]          NVARCHAR (50)   NULL,
    [DateUpdated]           NCHAR (10)      NULL,
    CONSTRAINT [PK_PackagesRangeDetail] PRIMARY KEY CLUSTERED ([IdPackagesRangeDetail] ASC),
    CONSTRAINT [FK_PackagesRangeDetail_CatRateSegment] FOREIGN KEY ([CatRateSegmentId]) REFERENCES [dbo].[CatRateSegment] ([CrsId]),
    CONSTRAINT [FK_PackagesRangeDetail_PackagesRange] FOREIGN KEY ([PackagesRangeId]) REFERENCES [dbo].[PackagesRange] ([IdPackagesRange])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de modificación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token modificación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de creación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token creación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor de la tarifa en relación al segmento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeDetail', @level2type = N'COLUMN', @level2name = N'Value';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Segmento de tarifa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeDetail', @level2type = N'COLUMN', @level2name = N'CatRateSegmentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rango al que pertenece', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeDetail', @level2type = N'COLUMN', @level2name = N'PackagesRangeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la tabla', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeDetail', @level2type = N'COLUMN', @level2name = N'IdPackagesRangeDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar el detalle de precios para un rango de paquetes para las tarifas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeDetail';


GO


