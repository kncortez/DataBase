CREATE TABLE [dbo].[ScoreServiceGuide] (
    [IdScoreGuide] INT            IDENTITY (1, 1) NOT NULL,
    [Score]        DECIMAL (5, 2) NOT NULL,
    [GuideSerie]   NVARCHAR (4)   NOT NULL,
    [GuideNumber]  BIGINT         NOT NULL,
    [Comment]      NVARCHAR (255) NULL,
    [IdSystem]     INT            NOT NULL,
    [RowStatus]    BIT            NOT NULL,
    [UserCreated]  NVARCHAR (50)  NOT NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [UserUpdated]  NVARCHAR (50)  NULL,
    [DateUpdated]  DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdScoreGuide] ASC),
    CONSTRAINT [FK_ScoreServiceGuide_System] FOREIGN KEY ([IdSystem]) REFERENCES [dbo].[CatSystem] ([SysIdSystem])
);


GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que contiene el puntaje de calificación por el servicio de su guía.'
, @level0type = N'SCHEMA', @level0name = 'dbo'
, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único para la calificación de servicio.'
, @level0type = N'SCHEMA', @level0name = 'dbo'
, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
, @level2type = N'COLUMN', @level2name = 'IdScoreGuide';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Puntaje que se le estará dando de calificación al servicio.'
, @level0type = N'SCHEMA', @level0name = 'dbo'
, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
, @level2type = N'COLUMN', @level2name = 'Score';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guía.'
, @level0type = N'SCHEMA', @level0name = 'dbo'
, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
, @level2type = N'COLUMN', @level2name = 'GuideSerie';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía.'
, @level0type = N'SCHEMA', @level0name = 'dbo'
, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
, @level2type = N'COLUMN', @level2name = 'GuideNumber';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Comentario no obligatorio que el usuario desea dejar.'
, @level0type = N'SCHEMA', @level0name = 'dbo'
, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
, @level2type = N'COLUMN', @level2name = 'Comment';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Sistema en el cual fue ingresado la calificación del servicio.'
, @level0type = N'SCHEMA', @level0name = 'dbo'
, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
, @level2type = N'COLUMN', @level2name = 'IdSystem';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.'
, @level0type = N'SCHEMA', @level0name = 'dbo'
, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
, @level2type = N'COLUMN', @level2name = 'RowStatus';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación.'
, @level0type = N'SCHEMA', @level0name = 'dbo'
, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
, @level2type = N'COLUMN', @level2name = 'UserCreated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.'
, @level0type = N'SCHEMA', @level0name = 'dbo'
, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
, @level2type = N'COLUMN', @level2name = 'DateCreated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario modificación.'
, @level0type = N'SCHEMA', @level0name = 'dbo'
, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
, @level2type = N'COLUMN', @level2name = 'UserUpdated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación.'
, @level0type = N'SCHEMA', @level0name = 'dbo'
, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
, @level2type = N'COLUMN', @level2name = 'DateUpdated';

GO
CREATE NONCLUSTERED INDEX [idx_ScoreServiceGuideSerie]
    ON [dbo].[ScoreServiceGuide]([GuideSerie] ASC, [GuideNumber] ASC);

