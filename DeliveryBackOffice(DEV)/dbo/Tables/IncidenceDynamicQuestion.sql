CREATE TABLE [dbo].[IncidenceDynamicQuestion] (
    [IdIncidenceDynamicQuestion] INT            IDENTITY (1, 1) NOT NULL,
    [QuestionTrue]               NVARCHAR (150) NOT NULL,
    [QuestionFalse]              NVARCHAR (150) NOT NULL,
    [SpecialInstructions]        NVARCHAR (250) NULL,
    [CatTypeIncidenceId]         INT            NOT NULL,
    [RowStatus]                  BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]               NVARCHAR (50)  NOT NULL,
    [DateCreated]                DATETIME       NOT NULL,
    [TokenUpdated]               NVARCHAR (50)  NULL,
    [DateUpdated]                DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdIncidenceDynamicQuestion] ASC),
    CONSTRAINT [FK_IncidenceDynamicQuestion_CatTypeIncidence] FOREIGN KEY ([CatTypeIncidenceId]) REFERENCES [dbo].[CatTypeIncidence] ([IdIncidenceType])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicQuestion', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que actualizó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicQuestion', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicQuestion', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que generó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicQuestion', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicQuestion', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Incidencia relacionada.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicQuestion', @level2type = N'COLUMN', @level2name = N'CatTypeIncidenceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Texto de instrucciones especiales.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicQuestion', @level2type = N'COLUMN', @level2name = N'SpecialInstructions';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Texto para rechazar la incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicQuestion', @level2type = N'COLUMN', @level2name = N'QuestionFalse';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Texto para aceptar la incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicQuestion', @level2type = N'COLUMN', @level2name = N'QuestionTrue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicQuestion', @level2type = N'COLUMN', @level2name = N'IdIncidenceDynamicQuestion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para guardar preguntas que aceptan o rechazan la incidencia desde landing page', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IncidenceDynamicQuestion';

