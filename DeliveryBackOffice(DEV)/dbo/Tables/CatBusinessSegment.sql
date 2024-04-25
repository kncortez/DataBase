CREATE TABLE [dbo].[CatBusinessSegment] (
    [IdBusinessSegment]          INT            IDENTITY (1, 1) NOT NULL,
    [BusinessSegmentName]        NVARCHAR (75)  NOT NULL,
    [BusinessSegmentDescription] NVARCHAR (200) NOT NULL,
    [RowStatus]                  BIT            NOT NULL,
    [TokenCreated]               NVARCHAR (50)  NOT NULL,
    [DateCreated]                DATETIME       NOT NULL,
    [TokenUpdated]               NVARCHAR (50)  NULL,
    [DateUpdated]                DATETIME       NULL,
    CONSTRAINT [PK_CatBusinessSegment] PRIMARY KEY CLUSTERED ([IdBusinessSegment] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que contiene la informacion del segmento de negocio al que pertenece el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBusinessSegment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion de fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBusinessSegment', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBusinessSegment', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 activo, 0 inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBusinessSegment', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del segmento de negocio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBusinessSegment', @level2type = N'COLUMN', @level2name = N'IdBusinessSegment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion de fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBusinessSegment', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion de fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBusinessSegment', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del segmento de negocio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBusinessSegment', @level2type = N'COLUMN', @level2name = N'BusinessSegmentName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripcion del segmento de negocio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBusinessSegment', @level2type = N'COLUMN', @level2name = N'BusinessSegmentDescription';

