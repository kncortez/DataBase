CREATE TABLE [dbo].[RateBySalePipeLine] (
    [IdRatePipeLine] INT          IDENTITY (1, 1) NOT NULL,
    [RateId]         INT          NOT NULL,
    [SalePipeLineId] INT          NOT NULL,
    [RowStatus]      BIT          NOT NULL,
    [TokenCreated]   VARCHAR (50) NOT NULL,
    [DateCreated]    DATETIME     NOT NULL,
    [TokenUpdated]   VARCHAR (50) NULL,
    [DateUpdated]    DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdRatePipeLine] ASC),
    CONSTRAINT [FKRatePipeLIne] FOREIGN KEY ([RateId]) REFERENCES [dbo].[RateHeader] ([RheId]),
    CONSTRAINT [FKRatePipeLine2] FOREIGN KEY ([SalePipeLineId]) REFERENCES [dbo].[CatSalePipelines] ([IdSalePipeLine])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único de la relación entre tarifa y canal de ventas.', 
@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateBySalePipeLine', @level2type = N'COLUMN', @level2name = N'IdRatePipeLine';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la tarifa asociada. Referencia a tabla RateHeader', 
@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateBySalePipeLine', @level2type = N'COLUMN', @level2name = N'RateId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del canal de ventas asociado.', 
@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateBySalePipeLine', @level2type = N'COLUMN', @level2name = N'SalePipeLineId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado (1 activo, 0 inactivo).', 
@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateBySalePipeLine', @level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creacion', 
@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateBySalePipeLine', @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion', 
@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateBySalePipeLine', @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modifico', 
@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateBySalePipeLine', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificacion', 
@level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateBySalePipeLine', @level2type = N'COLUMN', @level2name = N'DateUpdated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla que relaciona tabla de tarifa(RateHeader) y canal de ventas(CatSalePipelines).',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateBySalePipeLine',
    @level2type = NULL,
    @level2name = NULL

