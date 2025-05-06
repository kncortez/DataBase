CREATE TABLE [dbo].[CatPointPromo] (
    [IdPointPromo]          BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PointPromoDescription] NVARCHAR (200) NOT NULL,
    [PointPromoWeight]      INT            NOT NULL,
    [StartPromoDate]        DATETIME       NOT NULL,
    [FinishPromoDate]       DATETIME       NOT NULL,
    [Monday]                BIT            NOT NULL,
    [Tuesday]               BIT            NOT NULL,
    [Wednesday]             BIT            NOT NULL,
    [Thursday]              BIT            NOT NULL,
    [Friday]                BIT            NOT NULL,
    [Saturday]              BIT            NOT NULL,
    [Sunday]                BIT            NOT NULL,
    [InPointExchange]       BIT            DEFAULT ((0)) NOT NULL,
    [InPointGeneration]     BIT            DEFAULT ((0)) NOT NULL,
    [PointPromoFactor]      DECIMAL (5, 2) DEFAULT ((1)) NULL,
    [RowStatus]             BIT            NOT NULL,
    [DateCreated]           DATETIME       NOT NULL,
    [TokenCreated]          NVARCHAR (50)  NOT NULL,
    [DateUpdated]           DATETIME       NULL,
    [TokenUpdated]          NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdPointPromo] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualziación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Factor a aplicar en los puntos,', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'PointPromoFactor';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si la promoción aplica en la generación de puntos.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'InPointGeneration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si la promoción aplica en el canjeo de puntos.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'InPointExchange';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si promoción aplica día domingo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'Sunday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si promoción aplica día sabado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'Saturday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si promoción aplica día viernes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'Friday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si promoción aplica día jueves.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'Thursday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si promoción aplica día miercoles.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'Wednesday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si promoción aplica día martes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'Tuesday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si promoción aplica día lunes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'Monday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha final de valides de la promoción.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'FinishPromoDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de inicio de valides de la promoción.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'StartPromoDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor que determina que promoción toma precedencia (Mayor peso implica que se genera sobre los que tienen menor peso).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'PointPromoWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la promoción.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'PointPromoDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo', @level2type = N'COLUMN', @level2name = N'IdPointPromo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogo de promociones de puntos forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPointPromo';

