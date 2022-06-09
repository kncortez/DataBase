CREATE TABLE [dbo].[CatIncidenceTransfer] (
    [IdCatIncidenceTransfer] INT           NOT NULL,
    [IncidenceName]          VARCHAR (50)  NOT NULL,
    [RowStatus]              BIT           DEFAULT ((1)) NULL,
    [TokenCreated]           NVARCHAR (50) NOT NULL,
    [DateCreated]            DATETIME      NOT NULL,
    [TokenUpdate]            NVARCHAR (50) NULL,
    [DateUpdate]             DATETIME      NULL,
    CONSTRAINT [Pk_CatIncidenceTransfer] PRIMARY KEY CLUSTERED ([IdCatIncidenceTransfer] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar catálogo de incidencias de traslados.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceTransfer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatIncidenceTransfer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceTransfer', @level2type = N'COLUMN', @level2name = N'IdCatIncidenceTransfer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceTransfer', @level2type = N'COLUMN', @level2name = N'IncidenceName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceTransfer', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceTransfer', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceTransfer', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceTransfer', @level2type = N'COLUMN', @level2name = N'TokenUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceTransfer', @level2type = N'COLUMN', @level2name = N'DateUpdate';

