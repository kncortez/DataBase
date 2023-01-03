CREATE TABLE [dbo].[CatIncidenceReview] (
    [IdCatIncidenceReview]  INT          IDENTITY (1, 1) NOT NULL,
    [IncidenceReviewOrigin] VARCHAR (50) NOT NULL,
    [RowStatus]             BIT          NOT NULL,
    [TokenCreated]          VARCHAR (50) NOT NULL,
    [DateCreated]           DATETIME     NOT NULL,
    [TokenUpdated]          VARCHAR (50) NULL,
    [DateUpdated]           DATETIME     NULL,
    CONSTRAINT [PK__CatIncid__E3768DAC5F3EDF40] PRIMARY KEY CLUSTERED ([IdCatIncidenceReview] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de quien modifica el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceReview', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de modificación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceReview', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceReview', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de quien crea el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceReview', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'indicador de estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceReview', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador nombre de la incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceReview', @level2type = N'COLUMN', @level2name = N'IncidenceReviewOrigin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatIncidenceReview', @level2type = N'COLUMN', @level2name = N'IdCatIncidenceReview';

