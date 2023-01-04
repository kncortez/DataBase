CREATE TABLE [dbo].[CatIncidenceClasification] (
    [IdCatIncidenceClasification] INT           IDENTITY (1, 1) NOT NULL,
    [IncidenceTypeName]           NVARCHAR (50) NOT NULL,
    [RowStatus]                   BIT           NOT NULL,
    [TokenCreated]                NVARCHAR (50) NOT NULL,
    [DateCreated]                 DATETIME      NOT NULL,
    [DateUpdated]                 DATETIME      NULL,
    [TokenUpdated]                NVARCHAR (50) NULL,
    CONSTRAINT [PK__CatIncid__3E4FDC1E079BE122] PRIMARY KEY CLUSTERED ([IdCatIncidenceClasification] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de modificación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceClasification', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de quien modifica el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceClasification', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceClasification', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de quien crea el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceClasification', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'indicador de estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceClasification', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador nombre de la incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceClasification', @level2type = N'COLUMN', @level2name = N'IncidenceTypeName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceClasification', @level2type = N'COLUMN', @level2name = N'IdCatIncidenceClasification';

