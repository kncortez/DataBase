CREATE TABLE [dbo].[CatLinehaulStatus] (
    [IdCatLinehaulStatus] INT            IDENTITY (1, 1) NOT NULL,
    [StatusName]          NVARCHAR (50)  NOT NULL,
    [StatusDescription]   NVARCHAR (200) NULL,
    [RowStatus]           BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]        NVARCHAR (50)  NOT NULL,
    [DateCreated]         DATETIME       NOT NULL,
    [TokenUpdated]        NVARCHAR (50)  NULL,
    [DateUpdated]         DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdCatLinehaulStatus] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLinehaulStatus', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLinehaulStatus', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLinehaulStatus', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLinehaulStatus', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLinehaulStatus', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del estado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLinehaulStatus', @level2type = N'COLUMN', @level2name = N'StatusDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del estado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLinehaulStatus', @level2type = N'COLUMN', @level2name = N'StatusName';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de estados para rutas de linehaul.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLinehaulStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLinehaulStatus', @level2type = N'COLUMN', @level2name = N'IdCatLinehaulStatus';

