CREATE TABLE [dbo].[RoutePreparationLogError] (
    [IdRoutePreparationLogError] INT           IDENTITY (1, 1) NOT NULL,
    [ErrorDescription]           VARCHAR (300) NULL,
    [ErrorNumber]                INT           NULL,
    [ErrorProcedure]             VARCHAR (100) NULL,
    [ErrorLine]                  INT           NULL,
    [GuideSerie]                 NVARCHAR (2)  NULL,
    [GuideNumber]                INT           NULL,
    [TokenCreated]               VARCHAR (50)  NOT NULL,
    [DateCreated]                DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([IdRoutePreparationLogError] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationLogError', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationLogError', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía con error.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationLogError', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía con error.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationLogError', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Línea del error.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationLogError', @level2type = N'COLUMN', @level2name = N'ErrorLine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'StoreProcedure donde se originó el error.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationLogError', @level2type = N'COLUMN', @level2name = N'ErrorProcedure';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número del error.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationLogError', @level2type = N'COLUMN', @level2name = N'ErrorNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del error.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationLogError', @level2type = N'COLUMN', @level2name = N'ErrorDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del log.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationLogError', @level2type = N'COLUMN', @level2name = N'IdRoutePreparationLogError';

