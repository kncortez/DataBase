CREATE TABLE [dbo].[Act] (
    [IdAct]             INT            IDENTITY (1, 1) NOT NULL,
    [CatRouteId]        INT            NOT NULL,
    [DateOfRoute]       DATETIME       NOT NULL,
    [ResponsibleName]   NVARCHAR (100) NULL,
    [ResponsibleCUI]    NVARCHAR (50)  NULL,
    [CatTypeActId]      INT            NOT NULL,
    [AuthorizationDate] DATETIME       NULL,
    [RowStatus]         BIT            NOT NULL,
    [TokenCreated]      NVARCHAR (50)  NOT NULL,
    [DateCreated]       DATETIME       NOT NULL,
    [TokenUpdated]      NVARCHAR (50)  NULL,
    [DateUpdated]       DATETIME       NULL,
    CONSTRAINT [PK_Act] PRIMARY KEY CLUSTERED ([IdAct] ASC),
    CONSTRAINT [FK_Act_ActType] FOREIGN KEY ([CatTypeActId]) REFERENCES [dbo].[CatTypeAct] ([IdCatTypeAct]),
    CONSTRAINT [FK_Act_CatRoute] FOREIGN KEY ([CatRouteId]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    CONSTRAINT [UQ_Act] UNIQUE NONCLUSTERED ([CatTypeActId] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualziación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tokend e actualziacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de autorización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'AuthorizationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipo del acta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'CatTypeActId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificación de el responsable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'ResponsibleCUI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del responsable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'ResponsibleName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de ruta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'DateOfRoute';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Relación a catalogo de rutas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'CatRouteId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de tabla', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'IdAct';

