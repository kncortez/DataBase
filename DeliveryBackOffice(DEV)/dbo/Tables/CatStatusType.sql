CREATE TABLE [dbo].[CatStatusType] (
    [IdCatStatusType] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [StatusType]      NVARCHAR (25) NOT NULL,
    [RowStatus]       BIT           NOT NULL,
    [TokenCreated]    NVARCHAR (50) NOT NULL,
    [DateCreated]     DATETIME      NOT NULL,
    [TokenUpdated]    NVARCHAR (50) NULL,
    [DateUpdated]     DATETIME      NULL,
    CONSTRAINT [PK_CatStatusType] PRIMARY KEY CLUSTERED ([IdCatStatusType] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que indica el tipo de visibilidad de un estado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusType', @level2type = N'COLUMN', @level2name = N'IdCatStatusType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de visibilidad.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusType', @level2type = N'COLUMN', @level2name = N'StatusType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusType', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusType', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusType', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusType', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusType', @level2type = N'COLUMN', @level2name = N'DateUpdated';

