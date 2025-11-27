CREATE TABLE [dbo].[Tutorial] (
    [IdTutorial]          INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TutorialName]        NVARCHAR (50)  NOT NULL,
    [TutorialDescription] NVARCHAR (200) NULL,
    [RowStatus]           BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]         DATETIME       NOT NULL,
    [TokenCreated]        NVARCHAR (50)  NOT NULL,
    [DateUpdated]         DATETIME       NULL,
    [TokenUpdated]        NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdTutorial] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tutorial', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tutorial', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tutorial', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tutorial', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tutorial', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tutorial.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tutorial', @level2type = N'COLUMN', @level2name = N'TutorialDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tutorial.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tutorial', @level2type = N'COLUMN', @level2name = N'TutorialName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tutorial', @level2type = N'COLUMN', @level2name = N'IdTutorial';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de tutoriales para despelgar a usuarios.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Tutorial';

