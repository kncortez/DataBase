CREATE TABLE [dbo].[CatTypeConfirmationOfIncidence] (
    [IdCatTypeConfirmationOfIncidence] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                             NVARCHAR (20)  NOT NULL,
    [Description]                      NVARCHAR (100) NULL,
    [RowStatus]                        BIT            CONSTRAINT [DF_CatTypeConfirmationOfIncidence_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                     NVARCHAR (50)  NOT NULL,
    [DateCreated]                      DATETIME       NOT NULL,
    [TokenUpdated]                     NVARCHAR (50)  NULL,
    [DateUpdated]                      DATETIME       NULL,
    CONSTRAINT [PK_CatTypeConfirmationOfIncidence] PRIMARY KEY CLUSTERED ([IdCatTypeConfirmationOfIncidence] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de actualización de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de creación de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de la incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de la incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de tabla CatTypeConfirmationOfIncidence.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeConfirmationOfIncidence', @level2type = N'COLUMN', @level2name = N'IdCatTypeConfirmationOfIncidence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Almacena los tipos de una incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeConfirmationOfIncidence';

