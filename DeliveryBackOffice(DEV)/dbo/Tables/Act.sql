CREATE TABLE [dbo].[Act] (
    [IdAct]             INT            IDENTITY (1, 1) NOT NULL,
    [CatRouteId]        INT            NOT NULL,
    [DateOfRoute]       DATETIME       NOT NULL,
    [ResponsibleName]   NVARCHAR (100) NULL,
    [ResponsibleCUI]    NVARCHAR (50)  NULL,
    [CatTypeActId]      INT            NOT NULL,
    [AuthorizationDate] DATETIME       NULL,
    [RowStatus]         BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]      NVARCHAR (50)  NOT NULL,
    [DateCreated]       DATETIME       NOT NULL,
    [TokenUpdated]      NVARCHAR (50)  NULL,
    [DateUpdated]       DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdAct] ASC),
    CONSTRAINT [FK_Act_ActType] FOREIGN KEY ([CatTypeActId]) REFERENCES [dbo].[CatTypeAct] ([IdCatTypeAct]),
    CONSTRAINT [FK_Act_CatRoute] FOREIGN KEY ([CatRouteId]) REFERENCES [dbo].[CatRoute] ([IdRoute])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de autorización de acta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'AuthorizationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de tipo de acta | Tabla CatTypeAct', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'CatTypeActId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificación del responsable del incidente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'ResponsibleCUI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del resposable del incidente (OPCIONAL)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'ResponsibleName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de la ruta con incidente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'DateOfRoute';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la ruta con incidente | Tabla CatRoute', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'CatRouteId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'IdAct';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de encabezado de actas (justificaciones) asignadas a un proceso de despacho, liquidación de linehaul o recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act';

