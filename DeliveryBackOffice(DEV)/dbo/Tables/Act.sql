CREATE TABLE [dbo].[Act] (
    [IdAct]             INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
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
    CONSTRAINT [PK_Act] PRIMARY KEY CLUSTERED ([IdAct] ASC)
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de registro de actas de piezas faltantes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la persona responsable del acta y la ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'ResponsibleName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificación de la persona responsable del acta y la ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'ResponsibleCUI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'IdAct';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de la ruta cuando se creo el acta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'DateOfRoute';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de acta de la tabla CatTypeAct.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'CatTypeActId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la ruta de la tabla CatRoute.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'CatRouteId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de autorización de acta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Act', @level2type = N'COLUMN', @level2name = N'AuthorizationDate';

