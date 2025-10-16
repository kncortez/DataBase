CREATE TABLE [dbo].[PackagesRangeCOD] (
    [IdPackagesRangeCOD] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PackagesRangeId]    INT             NULL,
    [CatRateSegmentId]   INT             NOT NULL,
    [CODRate]            DECIMAL (12, 2) NOT NULL,
    [CODExempt]          DECIMAL (12, 2) NULL,
    [RowStatus]          BIT             CONSTRAINT [DF_PackagesRangeCOD_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]       NVARCHAR (50)   NOT NULL,
    [DateCreated]        DATETIME        NOT NULL,
    [TokenUpdated]       NVARCHAR (50)   NULL,
    [DateUpdated]        NCHAR (10)      NULL,
    CONSTRAINT [PK_PackagesRangeCOD] PRIMARY KEY CLUSTERED ([IdPackagesRangeCOD] ASC),
    CONSTRAINT [FK_PackagesRangeCOD_CatRateSegment] FOREIGN KEY ([CatRateSegmentId]) REFERENCES [dbo].[CatRateSegment] ([CrsId]),
    CONSTRAINT [FK_PackagesRangeCOD_PackagesRange] FOREIGN KEY ([PackagesRangeId]) REFERENCES [dbo].[PackagesRange] ([IdPackagesRange])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de modificación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeCOD', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token modificación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeCOD', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de creación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeCOD', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token creación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeCOD', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeCOD', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor de excento hasta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeCOD', @level2type = N'COLUMN', @level2name = N'CODExempt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor por cobro ad valorem', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeCOD', @level2type = N'COLUMN', @level2name = N'CODRate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Segmento de tarifa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeCOD', @level2type = N'COLUMN', @level2name = N'CatRateSegmentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rango al que pertenece', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeCOD', @level2type = N'COLUMN', @level2name = N'PackagesRangeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la tabla', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeCOD', @level2type = N'COLUMN', @level2name = N'IdPackagesRangeCOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar el detalle de precios COD para un rango de paquetes para las tarifas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PackagesRangeCOD';

