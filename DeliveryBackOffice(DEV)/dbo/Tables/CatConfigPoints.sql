CREATE TABLE [dbo].[CatConfigPoints] (
    [IdCatConfigPoints]              INT           IDENTITY (1, 1) NOT NULL,
    [CatConfigPointsExpirationDays]  INT           NOT NULL,
    [CatConfigPointsExchangeValue]   INT           NOT NULL,
    [CatConfigPointsGenerationValue] INT           NOT NULL,
    [CatConfigPointsExchangeType]    NVARCHAR (50) NOT NULL,
    [CatConfigPointsGenerationType]  NVARCHAR (50) NOT NULL,
    [RowStatus]                      BIT           NOT NULL,
    [TokenCreated]                   NVARCHAR (50) NOT NULL,
    [DateCreated]                    DATETIME      NOT NULL,
    [TokenUpdated]                   NVARCHAR (50) NULL,
    [DateUpdated]                    DATETIME      NULL,
    CONSTRAINT [PK_CatConfigPoints] PRIMARY KEY CLUSTERED ([IdCatConfigPoints] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigPoints', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigPoints', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigPoints', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigPoints', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigPoints', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Forma de generar puntos forza (Monto o Servicio)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigPoints', @level2type = N'COLUMN', @level2name = N'CatConfigPointsGenerationType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Forma de utilizar puntos en intercambio de puntos forza (Monto o Servicio)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigPoints', @level2type = N'COLUMN', @level2name = N'CatConfigPointsExchangeType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor de puntos a generar en proceso de acreditación de puntos forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigPoints', @level2type = N'COLUMN', @level2name = N'CatConfigPointsGenerationValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor de puntos en proceso de intercambio de puntos forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigPoints', @level2type = N'COLUMN', @level2name = N'CatConfigPointsExchangeValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Días adicionales para la expiración de puntos forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigPoints', @level2type = N'COLUMN', @level2name = N'CatConfigPointsExpirationDays';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la tabla', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigPoints', @level2type = N'COLUMN', @level2name = N'IdCatConfigPoints';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Acumulación de puntos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigPoints';

