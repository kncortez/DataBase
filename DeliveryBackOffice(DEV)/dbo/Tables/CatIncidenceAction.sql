CREATE TABLE [dbo].[CatIncidenceAction] (
    [IdCatIncidenceAction] INT          IDENTITY (1, 1) NOT NULL,
    [IncidenceActionName]  VARCHAR (50) NOT NULL,
    [RowStatus]            BIT          NOT NULL,
    [TokenCreated]         VARCHAR (50) NOT NULL,
    [DateCreated]          DATETIME     NOT NULL,
    [TokenUpdated]         VARCHAR (50) NULL,
    [DateUpdated]          DATETIME     NULL,
    CONSTRAINT [PK__CatIncid__BBC3EC1EC91611DE] PRIMARY KEY CLUSTERED ([IdCatIncidenceAction] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de quien modifica el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceAction', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de modificación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceAction', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceAction', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token usuario que crea el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceAction', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'indicador de estado activo o inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceAction', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador nombre de la incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceAction', @level2type = N'COLUMN', @level2name = N'IncidenceActionName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceAction', @level2type = N'COLUMN', @level2name = N'IdCatIncidenceAction';

